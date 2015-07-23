//
//  NSObject+Certification.m
//  JU
//
//  Created by zeha fu on 12-4-17.
//  Copyright (c) 2012年 ju.taobao.com. All rights reserved.
//

#import "NSObject+Certification.h"
//#import "TBMTopLoginRequest.h"
//#import "TBLoginViewController.h"
#import "RDAppDelegate.h"
#import "JULog.h"

@implementation NSObject (Certification)
@dynamic needPushViewAfterFinished ;

- (BOOL) needPushViewAfterFinished {
    return NO;
}

- (void) setNeedPushViewAfterFinished:(BOOL)needPushViewAfterFinished {
    
}

IMPLEMENT_SINGLETON(NSObject);

static SEL _didFinishSelector;
static id _delegate;
static UIViewController* _loginBaseController;


static bool needPushViewAfterFinished = NO;

static int autoloopLoginCount = 0;

- (void) resetAutoLoopLoginCount {
    autoloopLoginCount = 0;
}

- (void) loadLogin {
//    JUAppDelegate* delegate = (JUAppDelegate*)[[UIApplication sharedApplication] delegate];
//    [TBLoginViewController presentLoginControllerInController:delegate.rootNavigationViewController delegate:_delegate finishSelector:_didFinishSelector];
}

#pragma mark - 检测登录状态，如果没有登录，则弹出登录界面

- (void) loginRequestDidFinished:(TOPRequest *)request {
//    TBLoginResult* loginResult = (TBLoginResult*)[TBLoginResult mapping:[request responseJSON]];
//    DDLogVerbose(@"login result %@",loginResult);
//    
//    if ([loginResult isLoginSuccess]) {
//        [TBTop setUserSession:loginResult];
//        
//        autoloopLoginCount++;
//        
//        //单次使用自动登陆超过50次认为自动登陆过多，普通使用认为不会这么多
//        if (autoloopLoginCount < 50) {
//            if ([_delegate respondsToSelector:_didFinishSelector]) {
//                [_delegate performSelectorOnMainThread:_didFinishSelector withObject:nil waitUntilDone:NO];
//            }
//        } else {
//            SHOW_ALERT(@"登陆系统异常", @"请稍后重试");
//        }
//    } else {
//        //        [TBTop sharedInstance].sessionRunLoopSync = YES;
//        //        [self performSelector:@selector(loadLogin:) withObject:nil];
//        //        while ([TBTop sharedInstance].session == nil && [TBTop sharedInstance].sessionRunLoopSync) {
//        //            [[NSRunLoop mainRunLoop] runMode:UITrackingRunLoopMode beforeDate:[NSDate distantFuture]];
//        //        }
//        //        if (![TBTop sharedInstance].sessionRunLoopSync) {
//        //            return;
//        //        }
//        //        [NSThread sleepForTimeInterval:0.3];
//        //        if ([_delegate respondsToSelector:_didFinishSelector]) {
//        //            [_delegate performSelector:_didFinishSelector];
//        //        }
//        [self performSelectorOnMainThread:@selector(loadLoginView) withObject:nil waitUntilDone:NO];
//    }
//    
//    RELEASE_REQUEST_SAFELY(request);
}

- (void) loginRequestDidFailed:(TOPRequest *)request {
//    [NetworkDetect showNetworkInfo];
//    RELEASE_REQUEST_SAFELY(request);
}

- (void) loadLoginView{
//    if ([NSThread isMainThread]) {
//        if (_loginBaseController != nil) {
//            @try {
//                TBLoginViewController* loginViewController = [TBLoginViewController presentLoginControllerInController:_loginBaseController delegate:_delegate finishSelector:_didFinishSelector]; 
//                        
//            }
//            @catch (NSException *exception) {
//                SHOW_ALERT(@"系统错误，请稍后重试", @"");
//                DDLogError(@"ERROR:Login View fail present on %@",[exception callStackSymbols]);                
//            } 
//        } else {
//            DDLogError(@"ERROR:Login View fail present on %@",_loginBaseController);
//        }
//    } else {
//        [self performSelectorOnMainThread:@selector(loadLoginView) withObject:nil waitUntilDone:NO];
//    }
}

- (void) autoLoginCheckInBackground {
//    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
//    if (([TBTop sharedInstance].usernick == nil || [TBTop sharedInstance].password == nil) && [TBTop sharedInstance].topSession == nil) {
//        [TBTop sharedInstance].sessionRunLoopSync = YES;
//        [self performSelectorOnMainThread:@selector(loadLoginView) withObject:nil  waitUntilDone:NO];
//    } else if ([TBTop sharedInstance].usernick != nil && [TBTop sharedInstance].password != nil && [TBTop sharedInstance].topSession == nil) {
//        TBMTopLoginRequest* request = nil;
//        request = [[TBMTopLoginRequest alloc]init];
//        [request setDelegate:self];
//        [request setRequestDidFinishSelector:@selector(loginRequestDidFinished:)];
//        [request setRequestDidFailedSelector:@selector(loginRequestDidFailed:)];
//        [request sendRequest];
//    }
//    [pool release];
}

- (void) performAutoLoginCheckDidFinishSelector:(SEL)didFinishSelector target:(id)target presentLoginViewInController:(UIViewController*)controller {
    _didFinishSelector = didFinishSelector;
    _delegate = target;
    _loginBaseController = controller;
    
    [self performSelectorInBackground:@selector(autoLoginCheckInBackground) withObject:nil];
}

#pragma mark - 如果可以登录，自动登录

- (void) autologinRequestDidFinished:(TOPRequest *)request {
//    TBLoginResult* loginResult = (TBLoginResult*)[TBLoginResult mapping:[request responseJSON]];
//    DDLogVerbose(@"autologin result %@",loginResult);
//    
//    if ([loginResult isLoginSuccess]) {
//        [TBTop setUserSession:loginResult];
//    } else {
//        [TBTop resetUserAccount];
//    }
//    
//    RELEASE_REQUEST_SAFELY(request);
}

- (void) autologinRequestDidFailed:(TOPRequest *)request {
//    RELEASE_REQUEST_SAFELY(request);
}

- (void) autoLoginCheckInBackgroundWithoutLoadLoginView {
//    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
//    if ([TBTop sharedInstance].usernick != nil && [TBTop sharedInstance].session == nil) {
//        TBMTopLoginRequest* request = nil;
//        request = [[TBMTopLoginRequest alloc]init];
//        [request setDelegate:self];
//        [request setRequestDidFinishSelector:@selector(autologinRequestDidFinished:)];
//        [request setRequestDidFailedSelector:@selector(autologinRequestDidFailed:)];
//        [request sendRequest];
//    }
//    [pool release];
}

- (void) performAutoLoginCheck {
    [self performSelectorInBackground:@selector(autoLoginCheckInBackgroundWithoutLoadLoginView) withObject:nil];
}

- (void) autoLoginInBackgroundWithoutLoadLoginView {
//    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
//    if ([TBTop sharedInstance].usernick != nil) {
//        TBMTopLoginRequest* request = nil;
//        request = [[TBMTopLoginRequest alloc]init];
//        [request setDelegate:self];
//        [request setRequestDidFinishSelector:@selector(autologinRequestDidFinished:)];
//        [request setRequestDidFailedSelector:@selector(autologinRequestDidFailed:)];
//        [request sendRequest];
//    }
//    [pool release];
}

- (void) performAutoLogin {
    [self performSelectorInBackground:@selector(autoLoginInBackgroundWithoutLoadLoginView) withObject:nil];
}

#pragma mark - 测试循环登录

- (void) autoLoginLoopCheckInBackground {
//    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
//    if ([TBTop sharedInstance].usernick == nil) {
//        [TBTop sharedInstance].sessionRunLoopSync = YES;
//        [self performSelectorOnMainThread:@selector(loadLoginView) withObject:nil  waitUntilDone:NO];
//    } else if ([TBTop sharedInstance].usernick != nil) {
//        TBMTopLoginRequest* request = nil;
//        request = [[TBMTopLoginRequest alloc]init];
//        [request setDelegate:self];
//        [request setRequestDidFinishSelector:@selector(loginRequestDidFinished:)];
//        [request setRequestDidFailedSelector:@selector(loginRequestDidFailed:)];
//        [request sendRequest];
//    }
//    [pool release];
}

- (void) performAutoLoginCheckLoopDidFinishSelector:(SEL)didFinishSelector target:(id)target presentLoginViewInController:(UIViewController*)controller {
    _didFinishSelector = didFinishSelector;
    _delegate = target;
    _loginBaseController = controller;
    
    [self performSelectorInBackground:@selector(autoLoginLoopCheckInBackground) withObject:nil];
}


@end
