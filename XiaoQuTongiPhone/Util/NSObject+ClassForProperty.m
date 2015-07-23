//
//  NSObject+ClassForProperty.m
//  JSONTest
//
//  Created by zeha fu on 12-4-1.
//  Copyright (c) 2012年 ju.taobao.com. All rights reserved.
//

#import "NSObject+ClassForProperty.h"
#import <objc/runtime.h>

@implementation NSObject (ClassForProperty)

+ (Class)classForProperty:(const char *)propertyName {
    objc_property_t property = class_getProperty([self class], propertyName);
    if (property == NULL) {
        return nil;
    }
    const char *attributes = property_getAttributes(property);
    NSString *attributesString = [NSString stringWithCString:attributes encoding:NSASCIIStringEncoding];
    NSArray *parts = [attributesString componentsSeparatedByString:@","];
    NSString *typeString = [[parts objectAtIndex:0] substringFromIndex:1];
    
    if ([typeString hasPrefix:@"@"] && [typeString length] > 1) {
        NSString *name = [typeString substringWithRange:NSMakeRange(2, [typeString length]-3)];
        Class theClass = NSClassFromString(name);
        return theClass;
    }
    
    return nil;
}

@end
