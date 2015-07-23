//
//  JUCookieUtile.m
//  JU
//
//  Created by fangshi on 13-7-29.
//  Copyright (c) 2013年 ju.taobao.com. All rights reserved.
//

#import "JUSDKJUWebUtile.h"
//  

@implementation JUSDKJUWebUtile


+ (void) updateHttpCookies{
    if ([TBTop sharedInstance].cookies == nil){
        return;
    }
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    for (NSDictionary *cookieProperties in [self cookieArrayWithCookieArray]){
        NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperties];
        //set cookies to cookies storage
        [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
    }
//    DDLogInfo(@"%@",[NSHTTPCookieStorage sharedHTTPCookieStorage]);
}

+ (void) deleteHttpCookies{
    return;
//    if ([JuSettings sharedInstance].cookies == nil){
//        return;
//    }
    
    NSHTTPCookieStorage *cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    if (cookieStorage == nil){
        return;
    }

    for (NSHTTPCookie *each in cookieStorage.cookies) {
        [cookieStorage deleteCookie:each];
    }

//    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    if (cookieJar == nil){
//        return;
//    }
//    NSMutableArray *cookies = [JUWebUtile cookieArrayWithCookieArray];
//    NSArray *_tmpArray = [NSArray arrayWithArray:[cookieJar cookies]];
//    for (NSHTTPCookie *obj in _tmpArray) {
//        //NSLog(@"web cookie : %@", [obj name]);
//        for (NSMutableDictionary *dict in cookies){
//            NSString *cookieName =  [dict objectForKey:@"Name"];
//            if ([cookieName isEqualToString:[obj name]]){
//                //NSLog(@"delete cookie : %@",cookieName);
//                [cookieJar deleteCookie:obj];
//            }
//        }
//    }
}

+ (NSMutableArray *)cookieArrayWithCookieArray{
    NSArray *cookieKey = [[NSArray alloc] initWithObjects:NSHTTPCookieName,NSHTTPCookieSecure,NSHTTPCookieMaximumAge,
                          NSHTTPCookieOriginURL,NSHTTPCookiePath,NSHTTPCookiePort,NSHTTPCookieSecure,NSHTTPCookieValue,NSHTTPCookieVersion,NSHTTPCookieDomain,NSHTTPCookieComment,NSHTTPCookieExpires,NSHTTPCookieDiscard,nil];
    
    NSMutableArray *cookieArray = [[NSMutableArray alloc] init];
    if([TBTop sharedInstance].cookies == nil){
        return nil;
    }
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"EEE, dd-MMM-yyyy HH:mm:ss Z"];
//    DDLogInfo(@"Date%@", [dateFormatter stringFromDate:[NSDate date]]);
    
    
    for (NSString *cookieString in [TBTop sharedInstance].cookies){
        NSMutableDictionary *cookieMap = [NSMutableDictionary dictionary];
        NSArray *cookieKeyValueStrings = [cookieString componentsSeparatedByString:@";"];
        for (NSString *cookieKeyValueString in cookieKeyValueStrings) {
            NSArray *kvComponets = [cookieKeyValueString componentsSeparatedByString:@"="];
            if ([kvComponets count] == 2) {
                NSString *key = [[kvComponets objectAtIndex:0] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSString *value = [[kvComponets objectAtIndex:1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if (!key || !value){
//                    DDLogInfo(@"cookie key and value can't be null");
                    continue;
                }
                
                @try{
                    if ([key isEqualToString:NSHTTPCookieExpires]){
                        [cookieMap setObject:[dateFormatter dateFromString:value] forKey:key];
                        continue;
                    }
                }
                @catch(NSException *exception) {
//                    DDLogInfo (@"update cookie exception: %@%@", [exception name], [exception reason]);
                }
                
                if (NSNotFound != [cookieKey indexOfObject:key]){
                    [cookieMap setObject:value forKey:key];
                } else {
                    [cookieMap setObject:key forKey:NSHTTPCookieName];
                    [cookieMap setObject:value forKey:NSHTTPCookieValue];
                }
            }
        }
        [cookieArray addObject:cookieMap];
    }
    
    return cookieArray;
}


+ (BOOL) checkTbLoginUrl:(NSString *)url{
    static NSString* login_regex = @"^http://login\\.(m|wapa)\\.(taobao|tmall)\\.com/login\\.htm.*";
//    int mode = [JUSDKJuSettings getCurrentRequestHostMode];
//    // if daily env
//    if (mode == DAILY_REQUEST) {
//        login_regex = @"^http://login\\.waptest\\.(taobao|tmall)\\.com.*";
//    }
    
    if(!url){
        return NO;
    }
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", login_regex];
    return [pred evaluateWithObject:url];
}

@end
