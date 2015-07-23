//
//  TBMTOPRequest.m
//  TBMockSDK
//
//  Created by zeha fu on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TOPRequest.h"
#import "NSString+URLEncode.h"
#import "JULog.h"
#import "NSString+Compare.h"
#import "NSObject+Certification.h"
#import "TBTop.h"
#import "NetworkDetect.h"



@interface TOPRequest (Private)

@end

@implementation TOPRequest
@synthesize repeatCount = _repeatCount;

@synthesize apiMethod = _apiMethod;
@synthesize params = _params;
@synthesize needsUserSession = _needsUserSession;
@synthesize usePOST = _usePOST;
@synthesize ecode = _ecode;
@synthesize delegate = _delegate;
@synthesize sentData = _sentData;
//@synthesize userInfo = _userInfo;
@synthesize responseData = _responseData;
@synthesize responseJSON = _responseJSON;
@synthesize responseString = _responseString;
@synthesize responseObj = _responseObj;
@synthesize requestDidFailedSelector = _requestDidFailedSelector;
@synthesize requestDidFinishSelector = _requestDidFinishSelector;
@synthesize v = _v;
@synthesize requestTimeout = _requestTimeout;


- (void) prepareCommonParams {
    //改造以兼容其他应用和业务
    if (self.v == nil) {
        self.v = @"default_api_version";
    }
    if (self.apiMethod == nil) {
        self.apiMethod = @"default_api_method";
    }
    if ([TBTop sharedInstance].wapTTID == nil) {
        [TBTop sharedInstance].wapTTID = @"appstore";
    }
    if ([TBTop sharedInstance].appKey == nil) {
        [TBTop sharedInstance].appKey = @"this_is_a_appkey";
    }
    
    if ([TBTop sharedInstance].secretCode == nil) {
        [TBTop sharedInstance].secretCode = @"this_is_a_secretcode";
    }
    
    
//    [_params setObject:_v forKey:@"v"];
//    [_params setObject:[TBTop sharedInstance].wapTTID forKey:@"ttid"];
//    [_params setObject:[TBTop imei] forKey:@"imei"];
//    [_params setObject:[TBTop imsi] forKey:@"imsi"];
    [_params setObject:[TBTop timestamp] forKey:@"timestamp"];
//    [_params setObject:_apiMethod forKey:@"method"];
    [_params setObject:[TBTop sharedInstance].appKey forKey:@"app_key"];
    
    
//    [_params setObject:@"json" forKey:@"format"];
//    [_params setObject:@"md5" forKey:@"sign_method"];
    
//    if ([TBTop sharedInstance].topSession != nil) {
//        [_params setObject:[TBTop sharedInstance].topSession forKey:@"session"];
//    }
//    
//    [self addParam:@"iPhone" forKey:@"terminal_type"];
//    [self addParam:@"1001" forKey:@"platform_id"];
    
    if ([TBTop sharedInstance].session != nil) {

        [_params setObject:[TBTop sharedInstance].session forKey:@"session"];
    }
    
    if ([TBTop sharedInstance].communityId != nil) {

        [_params setObject:[TBTop sharedInstance].communityId forKey:@"communityId"];
    }
    
    if ([TBTop sharedInstance].mobile != nil) {
        
        [_params setObject:[TBTop sharedInstance].mobile forKey:@"mobile"];
    }
    

}

- (NSMutableDictionary*) dicFromQuery:(NSString*) query {
    if (query == nil || [query isEqualToString:@""]) {
        return [[NSMutableDictionary alloc]init];
    }
    NSArray* list = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary* queryDic = [[NSMutableDictionary alloc]init];
    for (NSString* em in list) {
        if (em != nil && ![em isEqualToString:@""]) {
            NSArray* el = [em componentsSeparatedByString:@"="];
            if ([el count] > 1) {
                [queryDic setObject:[el objectAtIndex:1] forKey:[el objectAtIndex:0]];
            }
        }
    }
    return queryDic;
}


- (id) initWithAbsoluteUrl:(NSString*) absoluteUrl {
    self = [super init];
    if (self != nil) {

        _v = @"1.0";
        _params = [[NSMutableDictionary alloc]init];
        
        NSURL* url = [NSURL URLWithString:absoluteUrl];
        NSMutableDictionary* paramDic = [self dicFromQuery:url.query];
        [_params addEntriesFromDictionary:paramDic];
        
        if ([absoluteUrl rangeOfString:@"?"].location != NSNotFound) {
            self.absoluteUrl = [absoluteUrl substringToIndex:[absoluteUrl rangeOfString:@"?"].location];
        } else {
            self.absoluteUrl = absoluteUrl;
        }
        
        
        if ([NetworkDetect isStateWiFi]) {
            self.requestTimeout = ASIHTTP_TIMEOUT_WIFI;
        } else {
            self.requestTimeout = ASIHTTP_TIMEOUT_NOT_WIFI;
        }
        self.repeatCount = TOP_REQUEST_FAILED_REPEATCOUNT;
    }
    return self;
}

- (id) initWithMethod:(NSString *)method {
    self = [super init];
    if (self != nil) {
        self.apiMethod = method;
        self.absoluteUrl = nil;
        _v = @"2.0";
        _params = [[NSMutableDictionary alloc]init];
        
        if ([NetworkDetect isStateWiFi]) {
            self.requestTimeout = ASIHTTP_TIMEOUT_WIFI;        
        } else {
            self.requestTimeout = ASIHTTP_TIMEOUT_NOT_WIFI;        
        }
        self.repeatCount = TOP_REQUEST_FAILED_REPEATCOUNT;
    }
    return self;
}

- (void)addParam:(NSObject *)param forKey:(NSString*)key {
    if (param != nil && key != nil) {
        [_params setObject:param forKey:key];
    }
}

- (void)removeParam:(NSString *)key {
    [_params removeObjectForKey:key];
}

- (NSString *)sign {
//    NSLog(@"sign with App key %@ ------ secret %@",[TBTop sharedInstance].appKey,[TBTop sharedInstance].secretCode);
    NSString* sign = nil;
    NSArray* keys = [[_params allKeys] sortedArrayUsingSelector:@selector(normalCompare:)];
    
    NSMutableString* signal_source = [[NSMutableString alloc]initWithFormat:@"%@",[TBTop sharedInstance].secretCode];
    for (NSString* key in keys) {
        
        //不需要cache
        if ([key isEqualToString:@"disableCache"]) {
            self.disableCache = true;
        }
        
        [signal_source appendFormat:@"%@%@",key,[_params objectForKey:key]];
    }
    [signal_source appendFormat:@"%@",[TBTop sharedInstance].secretCode];
    sign = [[MD5EX md5_string:signal_source] uppercaseString];
    return sign;
}

- (NSString*) requestHost {
    if (self.absoluteUrl != nil) {
        return self.absoluteUrl;
    }
    return [TBTop topHostURL];
}

- (NSURL*) requestURL {
    NSMutableArray* _paramsArray = [[NSMutableArray alloc]init];
    for (NSString* key in [_params allKeys]) {
        
        [_paramsArray addObject:[NSString stringWithFormat:@"%@=%@",key,[[NSString stringWithFormat:@"%@",[_params objectForKey:key]] stringByURLEncodingStringParameter]]];
        
    }
    DDLogInfo(@"TOP Method: Params %@",_paramsArray);
    NSString* paramUrl = [_paramsArray componentsJoinedByString:@"&"];
    
    NSString* requestPath = nil;
    if ([_paramsArray count] > 0) {
        requestPath = [NSString stringWithFormat:@"%@?%@",[self requestHost],paramUrl];
    } else {
        requestPath = [self requestHost];
    }
    
    DDLogInfo(@"TOP Method: %@ \nRequest: %@ ",self.apiMethod,requestPath);
    DDLogInfo(@"TOP Method: %@ \nRequest: %@ ",self.apiMethod,[requestPath stringByURLDecodingStringParameter]);
    return [NSURL URLWithString:requestPath];
}

- (void) setDelegate:(id)delegate {
    _delegate = delegate;
}

- (void) setCommonHTTPHeader:(ASIHTTPRequest*) request {
//    if ([JULocationManager userDefaultCity] != nil && ![[JULocationManager userDefaultCity] isEqualToString:@""]) {
//        [request addRequestHeader:@"city" value:[JULocationManager userDefaultCity]];
//    }
    
    if ([JULocationManager sharedInstance].isLatestLocateSuccess) {
        NSString *lng = [NSString stringWithFormat:@"%f",[JULocationManager sharedInstance].latestLocation.coordinate.longitude] ;
        NSString *lat = [NSString stringWithFormat:@"%f",[JULocationManager sharedInstance].latestLocation.coordinate.latitude] ;
        
        
        [request addRequestHeader:@"latitude" value:lat];
//        [request setValue:lat forKey:@"latitude"];
        
        [request addRequestHeader:@"longitude" value:lng];
//        [request setValue:lng forKey:@"longitude"];
    }
   
    if ([TBTop sharedInstance].session != nil) {
        [request addRequestHeader:@"session" value:[TBTop sharedInstance].session];
//        [request setValue:[TBTop sharedInstance].session forKey:@"session"];
    }
    
    if ([TBTop sharedInstance].communityId != nil) {
        [request addRequestHeader:@"communityId" value:[TBTop sharedInstance].communityId];
//        [request setValue:[TBTop sharedInstance].communityId forKey:@"communityId"];
    }
    
    if ([TBTop sharedInstance].token != nil) {
        [request addRequestHeader:@"token" value:[TBTop sharedInstance].token];
//        [request setValue:[TBTop sharedInstance].token forKey:@"token"];
    }
}

- (void) sendAsyncRequest {
    [self prepareCommonParams];
    [_params setObject:[self sign] forKey:@"sign"];
    
    NSURL* _request_url = [self requestURL];
    
    //From Cache
    if (!self.disableCache) {
        NSString* result = [[ISDiskCache sharedCache] objectForKey:_request_url];
        if (result != nil && [result isEqualToString:@""] != NSOrderedSame) {
            [self fastCacheFinished:result];
            return;
        }
    }
    
    _dataFormRequest = [[ASIHTTPRequest alloc]initWithURL:_request_url];
    [_dataFormRequest setUserAgentString:[TBTop constructUA]];
    [_dataFormRequest setAllowCompressedResponse:YES];
    [_dataFormRequest setShouldWaitToInflateCompressedResponses:YES];
    [self setCommonHTTPHeader:_dataFormRequest];
    
    [_dataFormRequest setDelegate:self];
    [_dataFormRequest setDidFinishSelector:@selector(requestFinished:)];
    [_dataFormRequest setDidFailSelector:@selector(requestFailed:)];
    
    if (self.requestTimeout == 0) {
        self.requestTimeout = 15;
    }
    [_dataFormRequest setTimeOutSeconds:self.requestTimeout];
    
    [self customizeRequest:_dataFormRequest];
    [_dataFormRequest startAsynchronous];
}

- (void) sendRequest {
    //默认是异步请求
    [self sendAsyncRequest];
}

- (TOPRequest*) sendSynchronousRequest {
    [self prepareCommonParams];
    
    [_params setObject:[self sign] forKey:@"sign"];
    
    NSURL* _request_url = [self requestURL];
    
    //From Cache
    if (!self.disableCache) {
        NSString* result = [[ISDiskCache sharedCache] objectForKey:[MD5EX md5_string:[_request_url absoluteString]]];
        if (result != nil && [result isEqualToString:@""] != NSOrderedSame) {
            [self fastCacheFinished:result];
            return self;
        }
    }

    _dataFormRequest = [[ASIHTTPRequest alloc]initWithURL:_request_url];
    [_dataFormRequest setUserAgentString:[TBTop constructUA]];
    [_dataFormRequest setAllowCompressedResponse:YES];
    [_dataFormRequest setShouldWaitToInflateCompressedResponses:YES];
    [self setCommonHTTPHeader:_dataFormRequest];
    if (self.requestTimeout == 0) {
        self.requestTimeout = 15;
    }
    [_dataFormRequest setTimeOutSeconds:self.requestTimeout];
    
    [self customizeRequest:_dataFormRequest];
    [_dataFormRequest startSynchronous];
    
    if ([_dataFormRequest error] == nil) {
//        NSLog(@"TOP Method: %@ \nRESPONDSE %@",self.apiMethod,[_dataFormRequest responseString]);
        self.responseString = [[NSString alloc] initWithData:_dataFormRequest.responseData encoding:NSUTF8StringEncoding]  ;
        self.responseJSON = [self.responseString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
        return self;
    } else {
//        NSLog(@"TOP Method: %@ \nRESPONDSE ERROR %@",self.apiMethod,_dataFormRequest.error);
        return nil;
    }
}

- (void) cancel {
    [_dataFormRequest setDelegate:nil];
    [_dataFormRequest cancel];
}

- (void) customizeRequest:(ASIHTTPRequest *)request {
    // need to override
}

- (id) mappingResponseJson:(NSDictionary*)jsonResponse {
    return nil;
}

//! 判断session是否过期
//{
//    "error_response": {
//        "code": 27,
//        "msg": "Invalid session",
//        "sub_code": "sessionkey-not-generated-by-server",
//        "sub_msg": "RealSession don&apos;t belong app and user ! appKey is : 12610510 , user id is : 63812345"
//    }
//}
// or
- (BOOL)isTopSessionInvalid
{
    id errorData = [[self responseJSON] valueForKeyPath:@"error_response.code"];
    if ([errorData isKindOfClass:[NSNumber class]])
    {
        // session 过期的错误, code: 27
        if ([errorData intValue] == 27)
        {
            return YES;
        }
    }
    
    return NO;
}

//! 判断是否没有session
//{
//    "error_response": {
//        "code": 26,
//        "msg": "Missing session"
//    }
//}
- (BOOL)isTopMissingSession
{
    id errorData = [[self responseJSON] valueForKeyPath:@"error_response.code"];
    if ([errorData isKindOfClass:[NSNumber class]])
    {
        // session 过期的错误, code: 26
        if ([errorData intValue] == 26)
        {
            return YES;
        }
    }
    
    return NO;
}

- (void) responseSuccess {
    [self requestFinished:nil];
}

- (void) responseFailed {
    [self requestFailed:nil];
}

- (void) fastCacheFinished:(NSString*) result {
    
#ifdef USE_BLOCK_JSON_MAPPING
    
    self.responseString = result ;
    //    self.responseJSON = [[request responseString] objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary* json = [result objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
        id obj = [self mappingResponseJson:json];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.responseJSON = json;
            self.responseObj = obj;
            
            if ([_delegate respondsToSelector:_requestDidFinishSelector]) {
                [_delegate performSelectorOnMainThread:_requestDidFinishSelector withObject:self waitUntilDone:NO];
                return;
            }
            if ([_delegate respondsToSelector:@selector(requestDidFinished:)]) {
                [_delegate performSelectorOnMainThread:@selector(requestDidFinished:) withObject:self waitUntilDone:NO];
            }
        });
        
    });
    
#else
    
    self.responseString = [request responseString] ;
    self.responseJSON = [[request responseString] objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
    self.responseObj = [self mappingResponseJson:self.responseJSON];
    
    RELEASE_SAFELY(_dataFormRequest);
    
    if ([_delegate respondsToSelector:_requestDidFinishSelector]) {
        [_delegate performSelectorOnMainThread:_requestDidFinishSelector withObject:self waitUntilDone:YES];
        return;
    }
    if ([_delegate respondsToSelector:@selector(requestDidFinished:)]) {
        [_delegate performSelectorOnMainThread:@selector(requestDidFinished:) withObject:self waitUntilDone:YES];
    }
    
#endif
    
}

- (void) requestFinished:(ASIHTTPRequest *)request {
    DDLogInfo(@"\nTOP Method: %@ \nRESPONDSE %@",self.apiMethod,[request responseString]);
    
    if (request != nil && ([request responseString] == nil || [[request responseString] compare:@""] == NSOrderedSame)) {
        [self requestFailed:request];
        return;
    }
    
#ifdef USE_BLOCK_JSON_MAPPING
    
    self.responseString = [[NSString alloc] initWithData:request.responseData encoding:NSUTF8StringEncoding] ;
    
    [[ISDiskCache sharedCache] setObject:self.responseString forKey:[MD5EX md5_string:[request.url absoluteString]]];
    self.responseData = [request responseData];
//    self.responseJSON = [[request responseString] objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSDictionary* json = [[request responseString] objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
        id obj = [self mappingResponseJson:json];
        
        dispatch_async(dispatch_get_main_queue(), ^{

            self.responseJSON = json;
            self.responseObj = obj;
            
            if ([_delegate respondsToSelector:_requestDidFinishSelector]) {
                [_delegate performSelectorOnMainThread:_requestDidFinishSelector withObject:self waitUntilDone:NO];
                return;
            }
            if ([_delegate respondsToSelector:@selector(requestDidFinished:)]) {
                [_delegate performSelectorOnMainThread:@selector(requestDidFinished:) withObject:self waitUntilDone:NO];
            }
        });
        
    });
    
#else
    
    self.responseString = [request responseString] ;
    self.responseJSON = [[request responseString] objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
    self.responseObj = [self mappingResponseJson:self.responseJSON];
    
    RELEASE_SAFELY(_dataFormRequest);
    
    if ([_delegate respondsToSelector:_requestDidFinishSelector]) {
        [_delegate performSelectorOnMainThread:_requestDidFinishSelector withObject:self waitUntilDone:YES];
        return;
    }
    if ([_delegate respondsToSelector:@selector(requestDidFinished:)]) {
        [_delegate performSelectorOnMainThread:@selector(requestDidFinished:) withObject:self waitUntilDone:YES];
    }
    
#endif
    
}

- (void) requestFailed:(ASIHTTPRequest *)request {
//    NSLog(@"\nTOP Method: %@ \nRESPONDSE ERROR %@",self.apiMethod,request.error);
    
    if (self.repeatCount != 0) {
        self.repeatCount -= 1;
//        DDLogInfo(@"\nTOP Method: %@ \nRESPONDSE ERROR %@ REPEAT %i",self.apiMethod,request.error,self.repeatCount);
        [self sendRequest];

        return;
    }
    
    

    if ([_delegate respondsToSelector:_requestDidFailedSelector]) {
        [_delegate performSelectorOnMainThread:_requestDidFailedSelector withObject:self waitUntilDone:YES];
        return;
    }
    if ([_delegate respondsToSelector:@selector(requestDidFailed:)]) {
        [_delegate performSelectorOnMainThread:@selector(requestDidFailed:) withObject:self waitUntilDone:YES];
    }

}

@end
