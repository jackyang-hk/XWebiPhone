//
//  SDGWebImageInterceptor.m
//  BridgeLabiPhone
//
//  Created by yanhao on 4/6/15.
//  Copyright (c) 2015 redcat. All rights reserved.
//

#import "SDGWebImageInterceptor.h"
#import "SDGWebImageSettings.h"
#import "SDGWebImageCache.h"

@implementation SDGWebImageInterceptor

- (id)init {
    self = [super init];
    if (self) {
        _settings = [SDGWebImageSettings defaultWebImageSettings];
        _imageCache = [[SDGWebImageCache alloc] init];
    }
    
    return self;
}

+ (instancetype)sharedWebImageInterceptor {
    static SDGWebImageInterceptor *interceptor = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        interceptor = [[self alloc] init];
    });
    
    return interceptor;
}

@end
