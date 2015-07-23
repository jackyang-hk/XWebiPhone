//
//  NSDate+Formatter.h
//  macww
//
//  Created by Xu Jiwei on 10-5-25.
//  Copyright 2010 Taobao.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (FormatString)

- (NSString*)stringWithFormat:(NSString*)fmt;
+ (NSDate*)dateFromString:(NSString*)str withFormat:(NSString*)fmt;
+ (NSDate *)dateFromString:(NSString *)str withFormat:(NSString *)fmt locale:(NSLocale *)locale;

@end
