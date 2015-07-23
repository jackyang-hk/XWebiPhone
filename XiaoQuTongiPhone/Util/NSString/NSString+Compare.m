//
//  NSString+Compare.m
//  D8
//
//  Created by fu zehua on 11-9-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "NSString+Compare.h"

@implementation NSString (Compare)

-(NSComparisonResult) normalCompare:(NSString*)other
{
    return [[self lowercaseString] compare:[other lowercaseString]  options:NSUTF8StringEncoding];
}

@end
