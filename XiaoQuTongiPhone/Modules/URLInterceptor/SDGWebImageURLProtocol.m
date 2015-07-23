//
//  SDGWebImageURLProtocol.m
//  BridgeLabiPhone
//
//  Created by yanhao on 4/6/15.
//  Copyright (c) 2015 redcat. All rights reserved.
//

#import "SDGWebImageURLProtocol.h"
#import "SDGWebImageInterceptor.h"
#import "SDGWebImageSettings.h"
#import "SDGWebImageCache.h"

static NSString * const kSDGImageRequestTackingKey = @"sdg_image_req_tracking_key";

@interface SDGWebImageURLProtocol () <NSURLConnectionDelegate>

// resource connection,
@property (nonatomic, strong) NSURLConnection *internalConnection;
@property (nonatomic, strong) NSURLResponse *internalResponse;

// the css and js both tiny text body, so save it in memory directly,
// flush it to disk when all content returns from server.
@property (nonatomic, strong) NSMutableData *responseData;

@end


@implementation SDGWebImageURLProtocol


//////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark private methods

+ (BOOL)isAllowedReferer:(NSString *)referer {
    if (referer == nil || [referer length] == 0) return NO;
    
    NSArray *referers
        = [SDGWebImageInterceptor sharedWebImageInterceptor].settings.supportedReferers;
    
    if (referers != nil && [referers indexOfObject:referer] != NSNotFound) {
        // found it
        return YES;
    }
    
    return NO;
}

+ (BOOL)isAllowedImageRequestHost:(NSString *)host {
    if (host == nil || [host length] == 0) return NO;
    
    NSArray *hosts
        = [SDGWebImageInterceptor sharedWebImageInterceptor].settings.supportedImageHosts;
    
    if (hosts != nil && [hosts indexOfObject:host] != NSNotFound) {
        // found it
        return YES;
    }
    
    return NO;
}

+ (BOOL)isSupportedImageExtension:(NSString *)extension {
    if (extension == nil || [extension length] == 0) return NO;
    
    NSString *lowercaseExtension = [extension lowercaseString];
    NSArray *extensions
        = [SDGWebImageInterceptor sharedWebImageInterceptor].settings.supportedImageExtensions;
    
    if (lowercaseExtension != nil && extensions != nil
        && [extensions indexOfObject:lowercaseExtension] != NSNotFound) {
        // found it
        return YES;
    }
    
    return NO;
}

// search reference url or host from request header fields
+ (NSString *)refererHostInRequest:(NSURLRequest *)request {
    NSString *host = nil;
    NSDictionary *fields = [request allHTTPHeaderFields];
    
    // search 'Referer' field at firstly
    NSString *referer = fields[@"Referer"];
    if (referer != nil && [referer length] > 0) {
        NSURL *url = [NSURL URLWithString:referer];
        host = [url host];
        
    } else {
        host = fields[@"Host"];
    }
    
    host = [self trim3WInRequestHost:host];
    
    return host;
}

+ (NSString *)imageRequesHostWithURL:(NSURL *)url {
    if (url == nil) return nil;
    
    return [self trim3WInRequestHost:[url host]];
}

+ (NSString *)trim3WInRequestHost:(NSString *)host {
    if (host != nil && [host hasPrefix:@"www."]) {
        // remove "www." from host
        return ([host length] > 4) ? [host substringFromIndex:4] : nil;
    }
    
    return host;
}


//////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark public methods

// override
+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
//    NSLog(@"SDGWebImageURLProtocol track url %@",request.URL);
    
    SDGWebImageInterceptor *interceptor = [SDGWebImageInterceptor sharedWebImageInterceptor];
    
    // step 1, check web image interceptor is opening
    if (!interceptor.settings.enabled) return NO; // not support web image interceptor now
    
    // step 2, check the request did marked
    id prop = [NSURLProtocol propertyForKey:kSDGImageRequestTackingKey inRequest:request];
    if (prop != nil) return NO; // aviod loading cycle
    
    // step 3, check the scheme of request
    NSString *scheme = [request.URL scheme];
    if (scheme == nil) return NO; // the request schema can not be nil
    
    scheme = [scheme lowercaseString];
    if (!([scheme isEqualToString:@"http"]
          || [scheme isEqualToString:@"https"])) {
        return NO; // for now, the scheme should be 'http' or 'https'
    }
    
    // step 4, check the path extension of request was supported or not
    NSString *extension = [[[request.URL lastPathComponent] pathExtension] lowercaseString];
    if (![self isSupportedImageExtension:extension]) return NO; // not support
    

    
    NSString *host = [self imageRequesHostWithURL:request.URL];
    if (![self isAllowedImageRequestHost:host]) return NO; // not support
    
    // setp 5, check the reference host is in white list
    NSString *referef = [self refererHostInRequest:request];
    if ([self isAllowedReferer:referef]) {
        return YES; // can handle the request use custom protocol
    }
    
    return NO;
}

// override
+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
    return request;
}

// override
- (void)startLoading {
    NSURL *requestURL = self.request.URL;
    
    SDGWebImageInterceptor *interceptor = [SDGWebImageInterceptor sharedWebImageInterceptor];
    
    NSData *cacheData = nil;
    NSURLResponse *customResponse = nil;
    if ([interceptor.imageCache hasCacheDataForURL:requestURL]) { // check cache data is available
        // load cache data with associated key
        cacheData = [interceptor.imageCache cacheDataForURL:requestURL response:&customResponse];
    }
    
    if (cacheData != nil) {
//        NSLog(@"img cache hint->%@",requestURL);
        // notify did receive response
        [self.client URLProtocol:self
              didReceiveResponse:customResponse
              cacheStoragePolicy:NSURLCacheStorageAllowedInMemoryOnly];
        
        // notify did finish load data
        [self.client URLProtocol:self didLoadData:cacheData];
        
        // notify did finish loading
        [self.client URLProtocolDidFinishLoading:self];
        
    } else {
        NSLog(@"img cache miss->%@",requestURL);
        NSMutableURLRequest *request = [self.request mutableCopy];
        [NSURLProtocol setProperty:@(YES) forKey:kSDGImageRequestTackingKey inRequest:request];
        
        self.internalConnection = [NSURLConnection connectionWithRequest:request delegate:self];
    }
}

// override
- (void)stopLoading {
    [self.internalConnection cancel];
    
    self.responseData = nil;
}


//////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark NSURLConenction delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    [self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
    
    self.internalResponse = response;
    self.responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [self.client URLProtocol:self didLoadData:data];
    
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [self.client URLProtocol:self didFailWithError:error];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [self.client URLProtocolDidFinishLoading:self];
    
    NSURL *requestURL = self.request.URL;
    
    // store cache response data
    SDGWebImageInterceptor *interceptor = [SDGWebImageInterceptor sharedWebImageInterceptor];
    [interceptor.imageCache storeCacheData:_responseData forURL:requestURL];
}

@end
