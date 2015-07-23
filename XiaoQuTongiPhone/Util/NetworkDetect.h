//
//  NetworkDetect.h
//  JU
//
//  Created by zeha fu on 12-5-9.
//  Copyright (c) 2012年 ju.taobao.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetworkDetect : NSObject

+ (BOOL) isStateWiFi;

+ (BOOL) isStateNotReached;

+ (void) showNetworkInfo ;

+ (void) detectNoNetwork ;

//重置网络提醒计数
+ (void) resetShowInfo ;

@end
