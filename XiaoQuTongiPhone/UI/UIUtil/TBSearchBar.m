//
//  TBSearchBar.m
//  taobao4iphone
//
//  Created by chenyan on 11-9-7.
//  Copyright 2011 Taobao.com. All rights reserved.
//

#import "TBSearchBar.h"


@implementation TBSearchBar


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}


- (void)setCloseButtonTitle:(NSString *)title forState:(UIControlState)state {
    UIButton    *cancelButton = nil;
    for(UIView *subView in self.subviews){
        if([subView isKindOfClass:UIButton.class]) {
            cancelButton = (UIButton*)subView;
            break;
        }
    }

    [cancelButton setTitle:title forState:state];        
}


- (void)setCloseButtonTitleColor:(UIColor *)color forState:(UIControlState)state {

    UIButton    *cancelButton = nil;
    for(UIView *subView in self.subviews){
        if([subView isKindOfClass:UIButton.class]) {
            cancelButton = (UIButton*)subView;
            break;
        }
    }
    
    [cancelButton setTitleColor:color forState:state];
}


- (void)setCloseButtonTitleShadowColor:(UIColor *)color forState:(UIControlState)state {
    UIButton    *cancelButton = nil;
    for(UIView *subView in self.subviews){
        if([subView isKindOfClass:UIButton.class]) {
            cancelButton = (UIButton*)subView;
            break;
        }
    }
    
    [cancelButton setTitleShadowColor:color forState:state];
    
}


- (void)setCloseButtonBackgroundImage:(UIImage *)image forState:(UIControlState)state {

    UIButton    *cancelButton = nil;
    for(UIView *subView in self.subviews){
        if([subView isKindOfClass:UIButton.class]) {
            cancelButton = (UIButton*)subView;
            break;
        }
    }    
    [cancelButton setBackgroundImage:image forState:state];
}


- (void)setBackgroundImage:(UIImage *)image {
    UIView *searchBarBackgroundView = [self.subviews objectAtIndex:0];
    [searchBarBackgroundView removeFromSuperview];	

    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [imageView setImage:image];
    [self insertSubview:imageView atIndex:0];
}


@end
