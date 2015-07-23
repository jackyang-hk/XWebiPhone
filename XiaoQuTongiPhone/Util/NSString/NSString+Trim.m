//
//  NSString+Trim.m
//  D8
//
//  Created by fu zehua on 11-9-22.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "NSString+Trim.h"


@implementation NSString (Trim)

- (NSString*) trim{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@end
