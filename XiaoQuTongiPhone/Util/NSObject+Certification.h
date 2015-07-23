//
//  NSObject+Certification.h
//  JU
//
//  Created by zeha fu on 12-4-17.
//  Copyright (c) 2012年 ju.taobao.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Macros.h"
#import "TOPRequest.h"

@interface NSObject (Certification)
@property (nonatomic, assign) BOOL needPushViewAfterFinished;

DECLARE_SINGLETON(NSObject);

- (void) resetAutoLoopLoginCount ;

#pragma mark - 检测登录状态，如果没有登录，则弹出登录界面
- (void) performAutoLoginCheckDidFinishSelector:(SEL)didFinishSelector target:(id)target presentLoginViewInController:(UIViewController*)controller ;

#pragma mark - 如果可以登录并未登陆，自动登录
- (void) performAutoLoginCheck ;

#pragma mark - 如果可以登录，自动登录
- (void) performAutoLogin;

#pragma mark - 测试循环登录
- (void) performAutoLoginCheckLoopDidFinishSelector:(SEL)didFinishSelector target:(id)target presentLoginViewInController:(UIViewController*)controller ;

@end
