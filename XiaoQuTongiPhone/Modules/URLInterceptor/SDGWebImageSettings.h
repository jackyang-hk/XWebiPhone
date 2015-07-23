//
//  SDGWebImageSettings.h
//  BridgeLabiPhone
//
//  Created by yanhao on 4/6/15.
//  Copyright (c) 2015 redcat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SDGWebImageSettings : NSObject

// is enabled web image interceptor or not, default is YES.
@property (nonatomic, assign) BOOL enabled;

@property (nonatomic, strong) NSArray *supportedReferers;
@property (nonatomic, strong) NSArray *supportedImageHosts;
@property (nonatomic, strong) NSArray *supportedImageExtensions;

+ (instancetype)defaultWebImageSettings;

@end
