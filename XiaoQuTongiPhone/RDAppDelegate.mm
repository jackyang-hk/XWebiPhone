//
//  RDAppDelegate.m
//  XiaoQuTongiPhone
//
//  Created by redcat on 14-7-21.
//  Copyright (c) 2014年 redcat. All rights reserved.
//

#import "RDAppDelegate.h"
//viewcontrollers for regist
#import "SplashViewController.h"
#import "WebViewControllerBase.h"
#import "JUSDKJUWebUtile.h"
#import "BaseTabbarController.h"
#import "BaseNavigationController.h"
#import "UMessage.h"
#import "MobClick.h"
#import <AlipaySDK/AlipaySDK.h>
#import "SDGWebImageURLProtocol.h"
#import "JMWebResourceURLProtocol.h"
#import "JMWebResourceInterceptor.h"
#import "AppCacheUtil.h"
#import "QRScanViewController.h"




@implementation RDAppDelegate

#define WXKey @" [input] "

#pragma mark -
#pragma mark private methods

- (void)_setupURLNavigatorMapping {
    JMNavigator *navigator = [JMNavigator sharedNavigator];
    navigator.delegate = self;
    
    JMURLMap *map = navigator.URLMap;
    
    [map from:SplashViewControllerURL toController:[SplashViewController class]];
    [map from:CommonWebViewControllerURL toController:[WebViewControllerBase class]];
    
}

#pragma mark -
//#pragma mark JMNavigator delegate methods
//
- (Class)navigator:(JMNavigator *)navigator navigationControllerClassForController:(UIViewController *)controller {
    return [UINavigationController class];
}

//本版本集成友盟 数据统计|自动更新|消息发送 SDK
- (void) registUmessage:(NSDictionary *)launchOptions {
    //umeng track 接入
    [MobClick startWithAppkey:@" [input] " reportPolicy:BATCH   channelId:@""];
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [MobClick setAppVersion:version];
    [MobClick setLogEnabled:NO];
    
    //umeng 自动更新
    [MobClick checkUpdate];
    
    //umeng push 接入
    //set AppKey and AppSecret
    [UMessage startWithAppkey:@" [input] " launchOptions:launchOptions];
    
    //register remoteNotification types
    
    //register remoteNotification types (iOS 8.0以下)
    [UMessage registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge
     |UIRemoteNotificationTypeSound
     |UIRemoteNotificationTypeAlert];
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings
                                                                             settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                                                             categories:nil]];
        
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    
    
    //for log（optional）
    [UMessage setLogEnabled:NO];
    
    [UMessage setChannel:@"App Store"];
    

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //初始化JULocationManager自有定位模块
    [JULocationManager sharedInstance];
    _mapManager = [[BMKMapManager alloc]init];
    // 如果要关注网络及授权验证事件，请设定     generalDelegate参数
    BOOL ret = [_mapManager start:@" [input] "  generalDelegate:nil];
    if (!ret) {
        NSLog(@"manager start failed!");
    }
    
    // register web image interceptor protocol
//    [NSURLProtocol registerClass:[SDGWebImageURLProtocol class]];
    [NSURLProtocol registerClass:[JMWebResourceURLProtocol class]];
    [[JMWebResourceInterceptor globalWebResourceInterceptor] setupDefaultWebResourceInterceptorSettings];
    
    [WXApi registerApp:WXKey withDescription:@"闪电购"];
    
    [self registUmessage:launchOptions];
    
    
    [ISDiskCache sharedCache].limitOfSize = 200 * 1024 * 1024;
    
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    

    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor lightGrayColor];
    [self _setupURLNavigatorMapping];

    self.navigator = [JMNavigator sharedNavigator];
    
    //更新cookie信息
    [JUSDKJUWebUtile updateHttpCookies];
    
    [self changeUA];
    
    [self.window makeKeyAndVisible];
    
    [self refreshApp:nil];
    
    [self insertMainButton];
    
    if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey] != nil) {
        [self parseNotification:[launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]];
    }

    
//    NSHTTPCookieStorage *sharedHTTPCookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
//    NSArray *cookies = [sharedHTTPCookieStorage cookiesForURL:[NSURL URLWithString:@"http://www.52shangou.com"]];
//    NSEnumerator *enumerator = [cookies objectEnumerator];
//    NSHTTPCookie *cookie;
//    while (cookie = [enumerator nextObject]) {
//        NSLog(@"COOKIE{name: %@, value: %@}", [cookie name], [cookie value]);
//    }

    
    return YES;
}

- (void) doAction:(NSDictionary*) operation {
    NSString* action = [operation objectForKey:@"action"];
    NSDictionary* params = [operation objectForKey:@"params"];
    if ([action isEqualToString:@"tabPage"]) {
        NSArray* urlMaps = [params objectForKey:@"pages"];
        if ([urlMaps count] > 1) {
            [ViewControllerBase loadNextTabbarControllerWithGeneralPagesParams:urlMaps fromNavigationController:self.mainNavigationController];
        } else {
            
        }
    } else if ([action isEqualToString:@"page"]) {
        NSString* url = [params objectForKey:@"url"];
        if ([params isKindOfClass:[NSDictionary class]] && url) {
            [[[ViewControllerBase alloc]init] loadNextPageUrlWithPreLoad:url];
        } else {
            
        }
    } else {
        SHOW_ALERT(@"版本太低", @"抱歉，请升级版本");
    }
}


- (void) parseCallUrl:(NSURL*)url {
    if (self.finishInitProgress == false || self.mainNavigationController == nil || self.mainNavigationController.view == nil || self.mainNavigationController.view.superview == nil) {
        [self performSelector:@selector(parseCallUrl:) withObject:url afterDelay:3.0];
    } else if ([url.absoluteString hasPrefix:WXKey]) {
        [WXApi handleOpenURL:url delegate:self];
    } else {
        NSError* error;
        id operation = [[url.query stringByURLDecodingStringParameter] objectFromJSONStringWithParseOptions:JKSerializeOptionPretty error:&error];
        [self doAction:operation];
    }
    

}

- (void) parseNotification:(NSDictionary *)userInfo {
    if (self.finishInitProgress == false || self.mainNavigationController == nil || self.mainNavigationController.view == nil || self.mainNavigationController.view.superview == nil) {
        [self performSelector:@selector(parseNotification:) withObject:userInfo afterDelay:3.0];
    } else {
        id operation = [userInfo objectForKey:@"data"];
        [self doAction:operation];
    }
}


//4.0以上版本OS,从进入该分支获得安全支付返回信息
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    [self parseCallUrl:url];
	return YES;
}

- (BOOL) application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    //跳转支付宝钱包进行支付，需要将支付宝钱包的支付结果回传给SDK
    if ([url.host isEqualToString:@"safepay"]) {
        [[AlipaySDK defaultService]
         processOrderWithPaymentResult:url
         standbyCallback:^(NSDictionary *resultDic) {
             
             NSString* resultStatus = [resultDic objectForKey:@"resultStatus"];
//             if ([resultStatus isEqualToString:@"9000"]) {
//                 SHOW_ALERT(@"闪电购", @"订单支付成功");
//             } else if ([resultStatus isEqualToString:@"8000"]) {
//                 SHOW_ALERT(@"闪电购", @"支付正在处理中");
//             } else if ([resultStatus isEqualToString:@"4000"]) {
//                 SHOW_ALERT(@"闪电购", @"订单支付失败");
//             } else if ([resultStatus isEqualToString:@"6001"]) {
//                 SHOW_ALERT(@"闪电购", @"用户中途取消");
//             } else if ([resultStatus isEqualToString:@"6002"]) {
//                 SHOW_ALERT(@"闪电购", @"网络连接出错");
//             }
             NSMutableDictionary* param = [[NSMutableDictionary alloc]init];
             if ([resultStatus isEqualToString:@"9000"]) {
                 [param setObject:@"success" forKey:@"payback"];
             } else if ([resultStatus isEqualToString:@"8000"]) {
                 [param setObject:@"inprocess" forKey:@"payback"];
             } else if ([resultStatus isEqualToString:@"4000"]) {
                 [param setObject:@"fail" forKey:@"payback"];
             } else if ([resultStatus isEqualToString:@"6001"]) {
                 [param setObject:@"cancelbyuser" forKey:@"payback"];
             } else if ([resultStatus isEqualToString:@"6002"]) {
                 [param setObject:@"networkfail" forKey:@"payback"];
             }

             [[NSNotificationCenter defaultCenter] postNotificationName:@"alipaycallback" object:param];
         }];
    } else {
        [self parseCallUrl:url];
    }

    return YES;
}

-(void) onReq:(BaseReq*)req
{
    if([req isKindOfClass:[GetMessageFromWXReq class]])
    {
//        // 微信请求App提供内容， 需要app提供内容后使用sendRsp返回
//        NSString *strTitle = [NSString stringWithFormat:@"微信请求App提供内容"];
//        NSString *strMsg = @"微信请求App提供内容，App要调用sendResp:GetMessageFromWXResp返回给微信";
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        alert.tag = 1000;
//        [alert show];
    }
    else if([req isKindOfClass:[ShowMessageFromWXReq class]])
    {
//        ShowMessageFromWXReq* temp = (ShowMessageFromWXReq*)req;
//        WXMediaMessage *msg = temp.message;
//        
//        //显示微信传过来的内容
//        WXAppExtendObject *obj = msg.mediaObject;
//        
//        NSString *strTitle = [NSString stringWithFormat:@"微信请求App显示内容"];
//        NSString *strMsg = [NSString stringWithFormat:@"标题：%@ \n内容：%@ \n附带信息：%@ \n缩略图:%u bytes\n\n", msg.title, msg.description, obj.extInfo, msg.thumbData.length];
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
    }
    else if([req isKindOfClass:[LaunchFromWXReq class]])
    {
//        //从微信启动App
//        NSString *strTitle = [NSString stringWithFormat:@"从微信启动"];
//        NSString *strMsg = @"这是从微信启动的消息";
//        
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:strTitle message:strMsg delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
//        [alert show];
    }
}

-(void) onResp:(BaseResp*)resp
{
    NSString *strMsg = [NSString stringWithFormat:@"errcode:%d", resp.errCode];
    NSString *strTitle;
    
    if([resp isKindOfClass:[SendMessageToWXResp class]])
    {
        strTitle = [NSString stringWithFormat:@"发送媒体消息结果"];
    }
    if([resp isKindOfClass:[PayResp class]]){
        //支付返回结果，实际支付结果需要去微信服务器端查询
        strTitle = [NSString stringWithFormat:@"支付结果"];
        NSMutableDictionary* param = [[NSMutableDictionary alloc]init];
        switch (resp.errCode) {
            case WXSuccess:
                strMsg = @"支付结果：成功！";
                NSLog(@"支付成功－PaySuccess，retcode = %d", resp.errCode);
                [param setObject:@"success" forKey:@"payback"];
                break;
                
            default:
                strMsg = [NSString stringWithFormat:@"支付结果：失败！retcode = %d, retstr = %@", resp.errCode,resp.errStr];
                NSLog(@"错误，retcode = %d, retstr = %@", resp.errCode,resp.errStr);
                [param setObject:@"fail" forKey:@"payback"];
                break;
        }
        [[NSNotificationCenter defaultCenter] postNotificationName:@"weixinpaycallback" object:param];
    }
    
}


- (void) insertMainButton {
    UIButton *_nextButton = [[UIButton alloc]initWithFrame:CGRectMake(10, iOS7?190:170, 300, 49)];
    [_nextButton setBackgroundImage:[UIImage imageNamed:@"btn-red"] forState:UIControlStateNormal&UIControlStateHighlighted&UIControlStateSelected];
    [_nextButton setTitleColor:COLOR_PAGE_BACK forState:UIControlStateNormal&UIControlStateHighlighted&UIControlStateSelected];
    [_nextButton setTitle:@"系统故障，请重试" forState:UIControlStateNormal&UIControlStateHighlighted&UIControlStateSelected];
    [_nextButton addTarget:self action:@selector(refreshApp:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.window addSubview:_nextButton];
    [self.window bringSubviewToFront:self.mainNavigationController.view];
}

- (void) refreshApp:(id)sender {
    self.finishInitProgress = NO;
    SplashViewController* splashViewController = [[SplashViewController alloc]init];
    self.mainNavigationController = [[BaseNavigationController alloc]initWithRootViewController:splashViewController];
    [self.mainNavigationController setNavigationBarHidden:YES];
    
    self.window.rootViewController = self.mainNavigationController;
    
    self.navigator.window = self.window;
    self.navigator.rootViewController = self.mainNavigationController;
    
    [self.window addSubview:self.mainNavigationController.view];
//    [JULocationManager startUpLocate];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    //delete cookie info when app resign
    [JUSDKJUWebUtile deleteHttpCookies];
//    [JULocationManager startUpLocate];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
//    [JULocationManager startUpLocate];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [JUSDKJUWebUtile updateHttpCookies];
//    [JULocationManager startUpLocate];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    [JUSDKJUWebUtile updateHttpCookies];
//    [JULocationManager startUpLocate];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    //删除cookie信息
    [JUSDKJUWebUtile deleteHttpCookies];
//    [JULocationManager startUpLocate];
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    [TBTop sharedInstance].token = [[[[deviceToken description] stringByReplacingOccurrencesOfString: @"<" withString: @""]
                        stringByReplacingOccurrencesOfString: @">" withString: @""]
                       stringByReplacingOccurrencesOfString: @" " withString: @""];
    [UMessage registerDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    [UMessage didReceiveRemoteNotification:userInfo];
    [self parseNotification:userInfo];
}

- (void) changeUA {
    [self performSelectorOnMainThread:@selector(changeUAInMainThread) withObject:nil waitUntilDone:NO];
}



-(void) changeUAInMainThread{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        UIWebView * wv = [[UIWebView alloc] init];
        NSString * rua = [wv stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
        
        if (rua.length > 0) {
            NSDictionary * dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:
                                         [NSString stringWithFormat:@"%@%@", rua,[TBTop constructUA]], @"UserAgent", nil];
            [[NSUserDefaults standardUserDefaults] registerDefaults:dictionary];
            dictionary = nil;
        }
        
        wv = nil;
        rua = nil;
    });
}


@end
