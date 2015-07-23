//
//  NSObject+AppCacheUtil.h
//  BridgeLabiPhone
//
//  Created by redcat on 15/5/29.
//  Copyright (c) 2015年 redcat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppCacheUtil : NSObject

/**
 * 聚合App当前缓存大小获取
 */
+ (float) appCacheSize ;

/**
 *  清楚当前App缓存
 */
+ (void) clearCache ;

@end
