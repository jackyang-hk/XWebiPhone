//
//  NSDate+Formatter.m
//  macww
//
//  Created by Xu Jiwei on 10-5-25.
//  Copyright 2010 Taobao.com. All rights reserved.
//

#import "NSDate+Formatter.h"


@implementation NSDate (FormatString)

- (NSString*)stringWithFormat:(NSString*)fmt {
    static NSDateFormatter *fmtter;
    
    if (fmtter == nil) {
        fmtter = [[NSDateFormatter alloc] init];
    }
    
    if (fmt == nil || [fmt isEqualToString:@""]) {
        fmt = @"HH:mm:ss";
    }
    
    [fmtter setDateFormat:fmt];
    
    return [fmtter stringFromDate:self];
}

+ (NSDate*)dateFromString:(NSString*)str withFormat:(NSString*)fmt {
    static NSDateFormatter *fmtter;
    
    if (fmtter == nil) {
        fmtter = [[NSDateFormatter alloc] init];
    }
    
    if (fmt == nil || [fmt isEqualToString:@""]) {
        fmt = @"HH:mm:ss";
    }
    
    [fmtter setDateFormat:fmt];
    
    return [fmtter dateFromString:str];
}


+ (NSDate *)dateFromString:(NSString*)str withFormat:(NSString*)fmt locale:(NSLocale *)locale {
    static NSDateFormatter *fmtter;
    
    if (fmtter == nil) {
        fmtter = [[NSDateFormatter alloc] init];
    }
    
    if (fmt == nil || [fmt isEqualToString:@""]) {
        fmt = @"HH:mm:ss";
    }
    
    [fmtter setDateFormat:fmt];
    if (locale != nil) {
        [fmtter setLocale:locale];
    }
    
    return [fmtter dateFromString:str];
}


@end
