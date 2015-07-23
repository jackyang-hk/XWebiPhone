//
//  JMUtility.h
//  JoyMaps
//
//  Created by laijiandong on 13-5-12.
//  Copyright (c) 2013年 taobao inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JMUtility : NSObject

+ (NSDictionary *)queryParamsDictionaryFromURL:(NSURL *)url;
+ (NSDictionary *)dictionaryByParsingURLQueryPart:(NSString *)encodedString;
+ (NSString *)stringBySerializingQueryParameters:(NSDictionary *)queryParameters;
+ (NSString *)stringByURLDecodingString:(NSString *)escapedString;
+ (NSString *)stringByURLEncodingString:(NSString *)unescapedString;

@end
