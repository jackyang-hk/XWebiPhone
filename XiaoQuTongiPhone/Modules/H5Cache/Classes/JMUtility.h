//
//  JMUtility.h
//  JoyMapsKit
//
//  Created by laijiandong on 13-5-12.
//  Copyright (c) 2013年 laijiandong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface JMUtility : NSObject

/**
 *  主线程执行指定的操作。
 *  如果当前调用线程是主线程，则isAsync参数将忽略。
 *  @param async  当前线程是否需要等待执行结果
 *  @param action 具体操作定义
 */
+ (void)performActionOnMainThreadAsync:(BOOL)async
                                action:(dispatch_block_t)action;

/**
 *  子线程执行指定的操作。
 *  如果当前调用线程是子线程，则isAsync参数将忽略，将在子线程同步执行。
 *  @param async  当前线程是否需要等待执行结果
 *  @param action 具体操作定义
 */
+ (void)performActionOnSubThreadAsync:(BOOL)async
                               action:(dispatch_block_t)action;

/**
 *  从URL中获取到查询参数，返回单个参数的键值对会做解码(url decode)。
 *  比如：http://domain.com/index.html?a=b&c=d
 *
 *  返回：{
 *        "a" : "b"
 *        "c" : "d"
 *       }
 *
 *  @param url 传入url
 *
 *  @return 返回参数集
 */
+ (NSDictionary *)queryParamsDictionaryFromURL:(NSURL *)url;

/**
 *  把编码字符串中转换成查询参数对集合。
 *  比如：a=b&c=d
 *
 *  返回：{
 *        "a" : "b"
 *        "c" : "d"
 *       }
 *
 *  @param encodedString 编码的查询参数字符串
 *
 *  @return 返回查询参数集
 */
+ (NSDictionary *)dictionaryByParsingURLQueryPart:(NSString *)encodedString;

/**
 *  系列化参数集并且编码参数键值对。
 *
 *  比如：{
 *        "a" : "b"
 *        "c" : "d"
 *       }
 *
 *  返回：a=b&c=d
 *
 *  @param queryParameters 查询参数集
 *
 *  @return 返回编码后的查询字符串
 */
+ (NSString *)stringBySerializingQueryParameters:(NSDictionary *)queryParameters;

/**
 *  url解码字符串
 *
 *  @param escapedString 编码过的字符串
 *
 *  @return 返回解码后的字符串
 */
+ (NSString *)stringByURLDecodingString:(NSString *)escapedString;

/**
 *  url编码字符串
 *
 *  @param unescapedString 普通字符串
 *
 *  @return 返回编码后的字符串
 */
+ (NSString *)stringByURLEncodingString:(NSString *)unescapedString;

@end
