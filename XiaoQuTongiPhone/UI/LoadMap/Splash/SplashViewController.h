//
//  SplashViewController.h
//  XiaoQuTongiPhone
//
//  Created by redcat on 14-7-23.
//  Copyright (c) 2014年 redcat. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SplashViewController : ViewControllerBase {
    UIButton* _registButton;
    UIButton* _loginButton;
    BOOL _initFinished;
}

@property (nonatomic, retain) NSDictionary* nextActionQuery;
@property (nonatomic, retain) UIActivityIndicatorView* indicatorView;


@end
