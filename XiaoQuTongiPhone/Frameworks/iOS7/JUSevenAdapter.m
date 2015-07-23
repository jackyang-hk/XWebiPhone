//
//  JUSevenAdapter.m
//  JU
//
//  Created by 陈 奕龙 on 13-12-23.
//  Copyright (c) 2013年 ju.taobao.com. All rights reserved.
//

#import "JUSevenAdapter.h"
#import "JUMLNavigationController.h"


@implementation JUSevenAdapter

+(void) adapterNavigationBarBackground{
    UINavigationBar* navBar = [UINavigationBar appearanceWhenContainedIn:[JUMLNavigationController class], nil];
    if (iOS7) {
        [navBar setBackgroundImage:[UIImage imageNamed:@"bg_status_navbar"] forBarPosition:UIBarPositionBottom barMetrics:UIBarMetricsDefault];
    }else{
//        [navBar setBackgroundImage:[UIImage imageNamed:@"bg_topbar"] forBarMetrics:UIBarMetricsDefault];
        [navBar setBackgroundImage:[UIImage imageNamed:@"navigationbar_IOS6"] forBarMetrics:UIBarMetricsDefault];
    
    }
    
}



+(UIBarButtonItem*)adapterBarButtonWithText:(NSString*)text colorAtSeven:(UIColor*)color inViewController:(UIViewController *)viewController actionSEL:(SEL)sel{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    [button setTitleColor:color forState:UIControlStateNormal];
    button.showsTouchWhenHighlighted = YES;
    
    [button setTitle:text forState:UIControlStateNormal];
    [button sizeToFit];
    
    CGRect rect = button.bounds;
    rect.size.width += 16.0;
    rect.size.height = 32.0;
    
    [button addTarget:viewController action:sel forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:button];
}

+(UIBarButtonItem*)adapterBarButtonWithText:(NSString*)text inViewController:(UIViewController *)viewController actionSEL:(SEL)sel{
    return  [self adapterBarButtonWithText:text colorAtSeven:UIColorFromRGB(0x5f5e66) inViewController:viewController actionSEL:sel];
    //[UIColor colorWithRed:242.f/255.f green:0.f blue:80.f/255.f alpha:1.f]
    
   
}


+(UIImageView*) adapterJULog{
    UIImageView* imageView = nil;
//    if (iOS7) {
        imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"navigation_logo"]];
//    }else{
//        imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"pic_tb_logo"]];
//    }
    return imageView;
}

+(UILabel*) adapterTitleLabel:(NSString*)title{
    UILabel* titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 150, 46)];
    titleLabel.font = [UIFont systemFontOfSize:20.0f];
    [titleLabel setText:title];
    if (iOS6) {
        titleLabel.adjustsLetterSpacingToFitWidth = YES;
    }
    
    titleLabel.textAlignment = UITextAlignmentCenter;
    [titleLabel setBackgroundColor:[UIColor clearColor]];
//    if (iOS7) {
        [titleLabel setTextColor:[UIColor colorWithRed:242.f/255.f green:0.f blue:80.f/255.f alpha:1.f]];
//    }else{
//        [titleLabel setTextColor:[UIColor whiteColor]];
//        
//    }
    return titleLabel;
}


+(UIBarButtonItem*)adapterReturnButtonInViewController:(UIViewController *)viewController{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setShowsTouchWhenHighlighted:YES];
    button.frame = CGRectMake(0, 0, 20, 20);
    [button setBackgroundImage:[UIImage imageNamed:@"navigation_back_icon"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"navigation_back_icon"] forState:UIControlStateHighlighted];
    
    if ([viewController respondsToSelector:@selector(back:)]) {
        [button addTarget:viewController action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
    }else if ([viewController respondsToSelector:@selector(pressBack:)]){
        [button addTarget:viewController action:@selector(pressBack:) forControlEvents:UIControlEventTouchUpInside];
    }
    UIBarButtonItem* catBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return catBarItem;
    
}


+(UIBarButtonItem*)adapterShareButtonInViewController:(UIViewController *)viewController shareAction:(SEL)sel{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setShowsTouchWhenHighlighted:YES];
    button.frame = CGRectMake(0, 0, 20, 20);
    [button setBackgroundImage:[UIImage imageNamed:@"navigation_share_icon"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"navigation_share_icon"] forState:UIControlStateHighlighted];
    [button addTarget:viewController action:sel forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* catBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return catBarItem;
    
}

+(UIBarButtonItem*)adapterCategoryButtonInViewController:(UIViewController *)viewController categoryAction:(SEL)sel{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setShowsTouchWhenHighlighted:YES];
    button.frame = CGRectMake(0, 0, 20, 20);
    [button setBackgroundImage:[UIImage imageNamed:@"ic_item_category.png"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"ic_item_category.png"] forState:UIControlStateHighlighted];
    [button addTarget:viewController action:sel forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* catBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return catBarItem;
    
}

+(UIBarButtonItem*)adapterReloadButtonInViewController:(UIViewController *)viewController reloadAction:(SEL)sel{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setShowsTouchWhenHighlighted:YES];
    button.frame = CGRectMake(0, 0, 20, 20);
    [button setBackgroundImage:[UIImage imageNamed:@"ic_nav_reload.png"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"ic_nav_reload.png"] forState:UIControlStateHighlighted];
    [button addTarget:viewController action:sel forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* catBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return catBarItem;
    
}

+(UIBarButtonItem*)adapterSettingButtonInViewController:(UIViewController *)viewController settingAction:(SEL)sel{
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setShowsTouchWhenHighlighted:YES];
    button.frame = CGRectMake(0, 0, 20, 20);
    [button setBackgroundImage:[UIImage imageNamed:@"icon_navbar_setting"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"icon_navbar_setting"] forState:UIControlStateHighlighted];
    [button addTarget:viewController action:sel forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* catBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return catBarItem;
    
}

+(UIBarButtonItem*)adapterCloseButtonInViewController:(UIViewController*)viewController closeAction:(SEL)sel{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setShowsTouchWhenHighlighted:YES];
    button.frame = CGRectMake(0, 0, 20, 20);
    [button setBackgroundImage:[UIImage imageNamed:@"ic_nav_close"] forState:UIControlStateNormal];
    [button setBackgroundImage:[UIImage imageNamed:@"ic_nav_close"] forState:UIControlStateHighlighted];
    [button addTarget:viewController action:sel forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem* closeBarItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    return closeBarItem;
}

+(UIView*)adapterBackgroundViewWithColor:(UIColor*)color{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = color;
    
    return view;
}

@end
