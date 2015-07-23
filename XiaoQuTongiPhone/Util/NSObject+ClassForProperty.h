//
//  NSObject+ClassForProperty.h
//  JSONTest
//
//  Created by zeha fu on 12-4-1.
//  Copyright (c) 2012年 ju.taobao.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (ClassForProperty)

+ (Class)classForProperty:(const char *)propertyName;

@end
