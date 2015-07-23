//
//  TBSearchBar.h
//  taobao4iphone
//
//  Created by chenyan on 11-9-7.
//  Copyright 2011 Taobao.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface TBSearchBar : UISearchBar {

}

- (void)setBackgroundImage:(UIImage *)image;
- (void)setCloseButtonTitle:(NSString *)title forState:(UIControlState)state ;
- (void)setCloseButtonTitleColor:(UIColor *)color forState:(UIControlState)state;
- (void)setCloseButtonBackgroundImage:(UIImage *)image forState:(UIControlState)state;
- (void)setCloseButtonTitleShadowColor:(UIColor *)color forState:(UIControlState)state;


@end
