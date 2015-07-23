//
//  JUCookieUtile.h
//  JU
//
//  Created by fangshi on 13-7-29.
//  Copyright (c) 2013年 ju.taobao.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JUSDKJUWebUtile : NSObject

+ (NSMutableArray *)cookieArrayWithCookieArray;

//delete cookie information
+ (void) deleteHttpCookies;

//update cookie information
+ (void) updateHttpCookies;

//check url is taobao login url
+ (BOOL) checkTbLoginUrl:(NSString *)url;

@end
