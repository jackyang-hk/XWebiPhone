//
//  UIImageView+EGOCache.h
//  JU
//
//  Created by zeha fu on 12-4-29.
//  Copyright (c) 2012年 ju.taobao.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EGOImageLoader.h"

#define kImageProgressView 43919
#define kImageProgressViewStyle 101

@protocol UIImageLoaderEGOCacheDelegate;
@interface UIImageView (EGOCache) <EGOImageLoaderObserver>

@property (nonatomic, assign) id <UIImageLoaderEGOCacheDelegate> delegate;

//延时显示进度条，delay只有在usingIndicator = YES的情况下生效
- (void)loadImageURL:(NSURL *)aURL placeHolderImage:(UIImage*)placeholderImage usingIndicator:(BOOL)usingIndicator delay:(float) delay;

//按优先级加载缓存图片,都没有,加载最后一张
- (void) loadImageURLs:(NSArray*) urls placeHolderImage:(UIImage*) placeHolderImage usingIndicator:(BOOL) usingIndicator delay:(float)delay ;

- (void)cancelImageLoad;

- (void)imageLoaderDidLoad:(NSNotification*)notification;

- (void)imageLoaderDidFailToLoad:(NSNotification*)notification;

- (void) removeIndicator;

@end

@protocol UIImageLoaderEGOCacheDelegate <NSObject>

- (void) didFinishLoadImage:(UIImage*) image ;

- (void) didFailLoadImage;



@end
