//
//  UIImage+EGOCache.m
//  BridgeLabiPhone
//
//  Created by redcat on 14-9-28.
//  Copyright (c) 2014年 redcat. All rights reserved.
//

#import "UIImage+EGOCache.h"
#import "EGOImageLoader.h"

@implementation UIImage (EGOCache)

+ (UIImage*) imageForUrl:(NSString*) urlString {
    NSURL* url = [NSURL URLWithString:urlString];
    UIImage* anImage = [[EGOImageLoader sharedImageLoader] imageFromCacheForURL:url];
    
    if (anImage) {
        return anImage;
    }
    
    NSData* imageData = [NSData dataWithContentsOfURL:url];
    
    if (imageData) {
        [[EGOImageLoader sharedImageLoader] saveImageData:imageData forURL:url];
        return [UIImage imageWithData:imageData scale:[UIScreen mainScreen].scale];
    }
    
    return nil;
    
}

@end
