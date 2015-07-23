//
//  SDGWebImageSettings.m
//  BridgeLabiPhone
//
//  Created by yanhao on 4/6/15.
//  Copyright (c) 2015 redcat. All rights reserved.
//

#import "SDGWebImageSettings.h"

@implementation SDGWebImageSettings

- (id)init {
    self = [super init];
    if (self) {
        _enabled = YES;
    }
    
    return self;
}

+ (instancetype)defaultWebImageSettings {
    SDGWebImageSettings *settings = [[self alloc] init];
    settings.supportedReferers = [self defaultSupportedReferers];
    settings.supportedImageHosts = [self defaultSupportedImageHosts];
    settings.supportedImageExtensions = [self defaultSupportedImageExtensions];
    
    return settings;
}

+ (NSArray *)defaultSupportedReferers {
    return @[@"52shangou.com",@"51xianqu.com"];
}

+ (NSArray *)defaultSupportedImageHosts {
    return @[@"52shangou.com",@"51xianqu.com"];
}

+ (NSArray *)defaultSupportedImageExtensions {
    // for now, is not supports tiff, tif, bmp, bmpf, ico, cur, xbm.
    // just supports jpg, jpeg, png, gif.
    return @[@"jpg", @"jpeg", @"png", @"gif", @"webp"];
}

@end
