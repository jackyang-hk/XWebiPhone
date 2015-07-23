//
//  NSObject+AppCacheUtil.h
//  BridgeLabiPhone
//
//  Created by redcat on 15/5/29.
//  Copyright (c) 2015年 redcat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppBridgeUtil : NSObject

/**
 * 是否同步桥接请求
 */
+ (BOOL) isSyncBridgeRequest:(NSURL*) url;

/**
 *  处理同步桥接请求
 */
+ (NSData*) performSyncBridgeRequest:(NSURL*) url;

@end
