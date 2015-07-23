//
//  SDGWebImageInterceptor.h
//  BridgeLabiPhone
//
//  Created by yanhao on 4/6/15.
//  Copyright (c) 2015 redcat. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SDGWebImageSettings;
@class SDGWebImageCache;

@interface SDGWebImageInterceptor : NSObject

@property (nonatomic, strong, readonly) SDGWebImageSettings *settings;
@property (nonatomic, strong, readonly) SDGWebImageCache *imageCache;

+ (instancetype)sharedWebImageInterceptor;

@end
