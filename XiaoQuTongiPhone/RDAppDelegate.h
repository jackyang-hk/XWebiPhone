//
//  RDAppDelegate.h
//  XiaoQuTongiPhone
//
//  Created by redcat on 14-7-21.
//  Copyright (c) 2014年 redcat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WXApi.h"
#import <BaiduMapAPI/BMapKit.h>


@interface RDAppDelegate : UIResponder <UIApplicationDelegate,JMNavigatorDelegate,UITabBarControllerDelegate,WXApiDelegate> {
        BMKMapManager* _mapManager;
}

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController* mainNavigationController;
@property (strong, nonatomic) UITabBarController* tabbarController;
@property (nonatomic, retain) JMNavigator *navigator;
@property (nonatomic, assign) BOOL finishInitProgress;

-(void) changeUAInMainThread;

@end
