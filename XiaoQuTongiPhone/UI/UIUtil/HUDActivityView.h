//
//  UIHUDActivityViewController.h
//  taobao4iphone
//
//  Created by Xu Jiwei on 10-7-12.
//  Copyright 2010 Taobao.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HUDActivityView : UIView <UIScrollViewDelegate> {
    CGFloat     indicatorWidth;
    CGFloat     indicatorHeight;
    
    UIScrollView                *scrollView;
    UIView                      *maskView;
    UIView                      *backView;
    UIActivityIndicatorView     *activityView;
    UILabel                     *textLabel;
    
    UIImageView                 *imageView;
    
    BOOL						needShowTip;
}

- (void)animateToHide;
- (void)animateShowInView:(UIView *)view autoHideAfter:(float)interval;

- (void)sizeToIndicator;

- (void)setIndicatorImage:(UIImage *)image;

- (id)initWithFrame:(CGRect)frame showTip:(BOOL)value;

@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, assign) CGFloat indicatorWidth, indicatorHeight;
@property (nonatomic, retain) UILabel *textLabel;

@end
