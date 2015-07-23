//
//  SDGWebImageCache.m
//  BridgeLabiPhone
//
//  Created by yanhao on 4/6/15.
//  Copyright (c) 2015 redcat. All rights reserved.
//

#import <MobileCoreServices/MobileCoreServices.h>

#import "SDGWebImageCache.h"

@implementation SDGWebImageCache

- (NSURLResponse *)responseForURL:(NSURL *)url image:(UIImage *)image data:(NSData *)data {
    // custom header fields
    NSMutableDictionary *customFields = [NSMutableDictionary dictionaryWithCapacity:2];
    
    NSString *contentType = [NSData sd_contentTypeForImageData:data];
    if (contentType == nil) {
        // try to match content type from extension from file
        NSString *extension = [url pathExtension];
        contentType = [SDGWebImageCache mimeTypeBaseOnExtension:extension];
    }
    
    if (contentType != nil) {
        customFields[@"Content-Type"] = contentType;
    }
    
    // content length
    customFields[@"Content-Length"] = [NSString stringWithFormat:@"%ld", (unsigned long)[data length]];
    
    NSHTTPURLResponse *response = [[NSHTTPURLResponse alloc] initWithURL:url
                                                              statusCode:200
                                                             HTTPVersion:@"HTTP/1.1"
                                                            headerFields:customFields];
    
    return response;
}

- (BOOL)hasCacheDataForURL:(NSURL *)url {
    if (url == nil) return NO;
    
    BOOL exists = [[SDWebImageManager sharedManager] cachedImageExistsForURL:url];
    return exists;
}

- (NSData *)cacheDataForURL:(NSURL *)url response:(NSURLResponse **)response {
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSString *key = [manager cacheKeyForURL:url];
    NSString *path = [manager.imageCache defaultCachePathForKey:key];
    
    NSData *responseData = [NSData dataWithContentsOfFile:path];
    if (response != NULL && responseData != nil) {
        // build response with image data raw data
        *response = [self responseForURL:url image:nil data:responseData];
    }
    
    return responseData;
}

- (void)storeCacheData:(NSData *)data forURL:(NSURL *)url {
    UIImage *image = [UIImage imageWithData:data];
    [[SDWebImageManager sharedManager] saveImageToCache:image forURL:url];
}


//////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark Utility methods

+ (NSString *)mimeTypeBaseOnExtension:(NSString *)extension {
    NSString *defaultMIMEType = @"application/octet-stream";
    if (extension == nil || [extension length] == 0) {
        return defaultMIMEType;
    }
    
    NSString *mimeType = nil;
    CFStringRef UTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension,
                                                            (__bridge CFStringRef)extension,
                                                            NULL);
    
    if (UTI != NULL) {
        mimeType = (__bridge_transfer NSString *)(UTTypeCopyPreferredTagWithClass(UTI, kUTTagClassMIMEType));
        
        CFRelease(UTI); // dispose UTI
    }
    
    // use default MIME type
    if (mimeType == nil) mimeType = defaultMIMEType;
    
    return mimeType;
}

@end
