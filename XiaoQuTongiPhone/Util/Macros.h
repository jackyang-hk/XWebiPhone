//
//  Macros.h
//  ZheQLib
//
//  Created by redcat on 11-4-29.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>



#define DECLARE_SINGLETON(classNAME) \
+ (classNAME*)sharedInstance

#define IMPLEMENT_SINGLETON(classNAME) \
+ (classNAME*)sharedInstance {            \
static classNAME* kInstance = nil;    \
\
if (!kInstance) {                     \
kInstance = [[self alloc] init];    \
}                                    \
\
return kInstance;                     \
}

#define AUTOLOGIN_CHECK_LOGIN_CONTROLLER(method,controller) \
if ([TBTop sharedInstance].session == nil) { \
[self performAutoLoginCheckDidFinishSelector:@selector(method) target:self presentLoginViewInController: controller]; \
return; \
}

#define RELOGIN_BACK_CONTROLLER(method,controller) \
[[TBTop sharedInstance] setSession_raw:nil]; \
[self performAutoLoginCheckDidFinishSelector:@selector(method) target:self presentLoginViewInController: controller]; \
return; 

#define RELEASE_SAFELY(__POINTER) { if (__POINTER != nil) {[__POINTER release]; __POINTER = nil;} }
#define RELEASE_REQUEST_SAFELY(__POINTER) { if (__POINTER != nil) {[__POINTER setDelegate:nil]; [__POINTER release]; __POINTER = nil;} }

#define ReleaseSafely(__pointer)            RELEASE_SAFELY(__pointer)
#define ReleaseRequestSafely(__pointer)     RELEASE_REQUEST_SAFELY(__pointer)

#define UIColorFromRGBA(rgbValue, alphaValue) \
[UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:alphaValue]

#define HEXCOLOR(rgbValue) \
[UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:((float)((rgbValue & 0xFF0000) >> 32))/255.0]

#define UIColorFromRGB(rgbValue) \
[UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0x0000FF))/255.0 \
alpha:1.0]



#define UIColorFromRGBFloat(r,g,b) \
[UIColor \
colorWithRed:r/255.0f \
green:g/255.0f \
blue:b/255.0f \
alpha:1.0]

#define UIColorFromRGBAFloat(r,g,b,a) \
[UIColor \
colorWithRed:r/255.0f \
green:g/255.0f \
blue:b/255.0f \
alpha:a/1.0]

#define COLOR_APP_FOCUS UIColorFromRGBAFloat(255, 106, 44, 1)
#define COLOR_APP_FOCUS_WITH_ALPHA(alpha) UIColorFromRGBAFloat(255, 106, 44, alpha)

#define COLOR_APP_NORMAL UIColorFromRGBAFloat(153, 153, 153, 1)

#define COLOR_APP_BASE UIColorFromRGBAFloat(255, 255, 255, 1)

#define COLOR_PAGE_BACK UIColorFromRGBAFloat(233, 233, 233, 1)

#define AppUrlWithPathAndParam(pathAndParams) \
[NSString stringWithFormat:@"http://115.29.109.176:8080%@",pathAndParams]

#define AppPhpServerUrlWithPathAndParam(pathAndParams) \
[NSString stringWithFormat:@"http://115.29.109.176:8081%@",pathAndParams]


// iPhone5兼容
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)

#define iPhone6 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(750, 1334), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size)) : NO)

#define iPhone6plus ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? (CGSizeEqualToSize(CGSizeMake(1125, 2001), [[UIScreen mainScreen] currentMode].size) || CGSizeEqualToSize(CGSizeMake(1242, 2208), [[UIScreen mainScreen] currentMode].size)) : NO)

// iOS7兼容
#define iOS8  ([[[UIDevice currentDevice] systemVersion] compare:@"8.0"] != NSOrderedAscending)
#define iOS7  ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)
#define iOS6  ([[[UIDevice currentDevice] systemVersion] compare:@"6.0"] != NSOrderedAscending)
#define iOS5  ([[[UIDevice currentDevice] systemVersion] compare:@"5.0"] != NSOrderedAscending)
#define XIB_IPHONE_HEIGHT 480
#define IPHONE_HEIGHT [UIScreen mainScreen].bounds.size.height

#define IPHONE_STATUBAR_HEIGHT 20
#define IPHONE_NAVIGATION_HEIGHT 48


