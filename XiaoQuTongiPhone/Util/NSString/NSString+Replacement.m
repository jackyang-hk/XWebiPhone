//
//  NSString+Replecement.m
//  JU
//
//  Created by fu zeha on 12-7-24.
//  Copyright (c) 2012年 ju.taobao.com. All rights reserved.
//

#import "NSString+Replacement.h"

@implementation NSString (Replacement)

- (NSString*) replace:(NSString*)target by:(NSString*)replace {
    NSMutableString* source = [NSMutableString stringWithFormat:@"%@",self];
    [source replaceOccurrencesOfString:target withString:replace options:NSCaseInsensitiveSearch range:NSMakeRange(0, [source length])];
    return source;
}

@end
