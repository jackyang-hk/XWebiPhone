//
//  JMWebCachePaths.h
//  JoyMapsKit
//
//  Created by laijiandong on 12/24/14.
//  Copyright (c) 2014 laijiandong. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Web容器缓存路径管理类
 */
@interface JMWebCachePaths : NSObject

/**
 *  Web模块bundle路径
 *
 *  @return 返回Web模块bundle路径
 */
+ (NSString *)webBundlePath;

/**
 *  通过相对路径拼接在Web模块下的bundle路径
 *
 *  @param relativePath 相对路径
 *
 *  @return 返回拼接完成的Web模块下资源路径
 */
+ (NSString *)webBundleWithRelativePath:(NSString *)relativePath;

/**
 *  Web容器本地缓存主目录
 *
 *  @return 返回Web容器本地缓存主目录
 */
+ (NSString *)webCachePath;

/**
 *  Web页面缓存主目录
 *
 *  @return 返回Web页面缓存主目录
 */
+ (NSString *)webPageCachePath;

/**
 *  拦截的Web资源缓存目录
 *
 *  @return 返回拦截的Web资源缓存目录
 */
+ (NSString *)interceptWebResourceCachePath;

@end
