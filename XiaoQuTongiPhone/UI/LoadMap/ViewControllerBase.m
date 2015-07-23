//
//  ViewControllerBase.m
//  XiaoQuTongiPhone
//
//  Created by redcat on 14-7-26.
//  Copyright (c) 2014年 redcat. All rights reserved.
//
#import <UIKit/UIKit.h>
#import "ViewControllerBase.h"
#import "HUDActivityView.h"
#import "NSString+URLEncode.h"
#import "BaseTabbarController.h"
#import "WebViewControllerBase.h"
#import "UIImage+EGOCache.h"
#import "MobClick.h"
#import "UIImage+JoyMapsAdditions.h"

@implementation ViewControllerBase

- (void) viewDidDisappear:(BOOL)animated {
    [self showLoadingView:NO];
    [super viewDidDisappear:YES];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [MobClick beginLogPageView:self.title];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:self.title];
}

- (UIView*) setUpCustomNavigationBarForTitle:(NSString*) title compatibleForBackTitle:(NSString*) backTitle {
    self.title = title;
    [self.navigationController setNavigationBarHidden:YES];
    
    //主bar
    _navigationView = [[UIView alloc] init];
    
    if (iOS7) {
        [_navigationView setFrame:CGRectMake(0,0,IPHONE_WIDTH,64)];
    } else {
        [_navigationView setFrame:CGRectMake(0,0,IPHONE_WIDTH,44)];
    }
    
    _navigationView.backgroundColor = COLOR_APP_BASE;
    
    if (backTitle == nil) {
        backTitle = @"返回";
    } else {
        backTitle = [NSString stringWithFormat:@"%@",backTitle];
    }
    
    _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    if (iOS7) {
        [_backButton setFrame:CGRectMake(0,20,80,44)];
    } else {
        [_backButton setFrame:CGRectMake(0,0,80,44)];
    }
    [_backButton setTitle:backTitle forState:UIControlStateNormal&UIControlStateHighlighted&UIControlStateSelected];
    [_backButton setImage:[UIImage ipMaskedImageNamed:@"icon_back" color:COLOR_APP_FOCUS] forState:UIControlStateNormal];
    [_backButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0.0, 0.0, 15)];
    
    [_backButton setTitleColor:COLOR_APP_FOCUS forState:UIControlStateNormal];
    [_backButton setTitleColor:COLOR_APP_FOCUS forState:UIControlStateHighlighted];
    [_backButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
    [_backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    [_navigationView addSubview:_backButton];
    
    if (self.noBackButton) {
        [_backButton setHidden:YES];
    }
    
//    if (self.noNavigation) {
    //默认全局取消Navigation头部
        [_navigationView setHidden:YES];
//    }
    
    _titleLabel = [[UILabel alloc]init];
    if (iOS7) {
        [_titleLabel setFrame:CGRectMake(80,20,160,44)];
    } else {
        [_titleLabel setFrame:CGRectMake(80,0,160,44)];
    }
    [_titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
    //use default title
    if (title == nil) {
        title = self.title;
    }
    [_titleLabel setText:title];
    [_titleLabel setTextColor:COLOR_APP_FOCUS];
    [_titleLabel setBackgroundColor:[UIColor clearColor]];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_navigationView addSubview:_titleLabel];
    
    [self.view addSubview:_navigationView];
    
    return _navigationView;
}

- (void) viewdidload {
    self.automaticallyAdjustsScrollViewInsets = NO;
}

- (void) disableBackButton {
    if (_backButton) {
        [_backButton setHidden:YES];
    }
}


- (NSString*)  queryFromDic:(NSDictionary*) paramDic {
    NSMutableArray* _paramsArray = [[NSMutableArray alloc]init];
    for (NSString* key in [paramDic allKeys]) {
        
        [_paramsArray addObject:[NSString stringWithFormat:@"%@=%@",key,[[NSString stringWithFormat:@"%@",[paramDic objectForKey:key]] stringByURLEncodingStringParameter]]];
        
    }
    
    NSString* paramUrl = [_paramsArray componentsJoinedByString:@"&"];
    
    return paramUrl;
}

- (NSMutableDictionary*) dicFromQuery:(NSString*) query {
    if (query == nil || [query isEqualToString:@""]) {
        return [[NSMutableDictionary alloc]init];
    }
    NSArray* list = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary* queryDic = [[NSMutableDictionary alloc]init];
    for (NSString* em in list) {
        if (em != nil && ![em isEqualToString:@""]) {
            NSArray* el = [em componentsSeparatedByString:@"="];
            if ([el count] > 1) {
                [queryDic setObject:[el objectAtIndex:1] forKey:[el objectAtIndex:0]];
            }
        }
    }
    return queryDic;
}



/**
 * 废弃重建URL功能，暂时不去掉重建入口
 */
- (NSString*) reConstructCommonQuery:(NSString*) urlString {
    NSURL* url = [NSURL URLWithString:urlString];
    if (url == nil) {
        url = [NSURL URLWithString:[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    }
    return urlString;
    
    //decepranted
    NSMutableDictionary* paramDic = [self dicFromQuery:url.query];
    
    if ([JULocationManager userDefaultCity] != nil && ![[JULocationManager userDefaultCity] isEqualToString:@""]) {
        [paramDic setObject:[JULocationManager userDefaultCity] forKey:@"city"];
    }
    
    if ([JULocationManager sharedInstance].isLatestLocateSuccess) {
        NSString *lng = [NSString stringWithFormat:@"%f",[JULocationManager sharedInstance].latestLocation.coordinate.longitude] ;
        NSString *lat = [NSString stringWithFormat:@"%f",[JULocationManager sharedInstance].latestLocation.coordinate.latitude] ;
        
        
        [paramDic setObject:lat forKey:@"latitude"];
        
        [paramDic setObject:lng forKey:@"longitude"];
    }
    
    if ([TBTop sharedInstance].session != nil) {
        [paramDic setObject:[TBTop sharedInstance].session forKey:@"session"];
    }
    
    if ([TBTop sharedInstance].communityId != nil) {
        [paramDic setObject:[TBTop sharedInstance].communityId forKey:@"communityId"];
    }
    
    if ([TBTop sharedInstance].mobile != nil) {
        [paramDic setObject:[TBTop sharedInstance].mobile forKey:@"mobile"];
    }
    
    if ([TBTop sharedInstance].token != nil) {
        [paramDic setObject:[TBTop sharedInstance].token forKey:@"token"];
    }
    
    [paramDic setObject:@"iOS" forKey:@"appenv"];
    
    NSString* query = [self queryFromDic:paramDic];
    
    if ([urlString rangeOfString:@"?"].location != NSNotFound) {
        return [NSString stringWithFormat:@"%@?%@",[urlString substringToIndex:[urlString rangeOfString:@"?"].location],query];
    } else {
        return [NSString stringWithFormat:@"%@?%@",urlString,query];
    }
    
}

- (NSString*) addQuery:(NSDictionary*) params toUrl:(NSString*) urlString  {
    NSURL* url = [NSURL URLWithString:urlString];
    NSMutableDictionary* paramDic = [self dicFromQuery:url.query];
    
    if ([params isKindOfClass:[NSDictionary class]]) {
        [paramDic addEntriesFromDictionary:params];
    }
    
    NSString* query = [self queryFromDic:paramDic];
    
    if ([urlString rangeOfString:@"?"].location != NSNotFound) {
        return [NSString stringWithFormat:@"%@?%@",[urlString substringToIndex:[urlString rangeOfString:@"?"].location],query];
    } else {
        return [NSString stringWithFormat:@"%@?%@",urlString,query];
    }
}

- (NSString*) constructUrl:(NSString*) originUrl withParam:(NSDictionary*) params {
    if (![params isKindOfClass:[NSDictionary class]]) {
        return originUrl;
    }
    NSString* query = [self queryFromDic:params];
    
    if ([originUrl rangeOfString:@"?"].location != NSNotFound) {
        return [NSString stringWithFormat:@"%@?%@",[originUrl substringToIndex:[originUrl rangeOfString:@"?"].location],query];
    } else {
        return [NSString stringWithFormat:@"%@?%@",originUrl,query];
    }
}

- (NSString*) commonQuery {
    NSMutableDictionary* paramDic = [[NSMutableDictionary alloc]init];
    if ([JULocationManager userDefaultCity] != nil) {
        [paramDic setObject:[JULocationManager userDefaultCity] forKey:@"city"];
    }
    
    if ([JULocationManager sharedInstance].isLatestLocateSuccess) {
        NSString *lng = [NSString stringWithFormat:@"%f",[JULocationManager sharedInstance].latestLocation.coordinate.longitude] ;
        NSString *lat = [NSString stringWithFormat:@"%f",[JULocationManager sharedInstance].latestLocation.coordinate.latitude] ;
        
        
        [paramDic setObject:lat forKey:@"latitude"];
        
        [paramDic setObject:lng forKey:@"longitude"];
    }
    
    if ([TBTop sharedInstance].session != nil) {
        [paramDic setObject:[TBTop sharedInstance].session forKey:@"session"];
    }
    
    if ([TBTop sharedInstance].communityId != nil) {
        [paramDic setObject:[TBTop sharedInstance].communityId forKey:@"communityId"];
    }
    
    [paramDic setObject:@"iOS" forKey:@"appenv"];
    
    return [self queryFromDic:paramDic];

}

- (void) navigationBack {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) back {
//    NSLog(@"NavigationBack from %@",self);
    [_backButton setEnabled:NO];
    [self performSelector:@selector(navigationBack) withObject:nil afterDelay:0.1];
    
}

// 切换到NSURLConnection体系
- (void) doCommonUploadWithUrl:(NSString *)url finish:(SEL)finishAction {
    _isUploading = YES;
    self.finishAction = finishAction;
    //    NSLog(@"doCommonUploadWithUrl - %@",url);
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:url]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    self.internalConnection = [NSURLConnection connectionWithRequest:request delegate:self];
}

//////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark NSURLConenction delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    self.internalResponse = response;
    self.responseData = [[NSMutableData alloc] init];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    
    [self.responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
 
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    if ([self.internalResponse isKindOfClass:[NSHTTPURLResponse class]] && ((NSHTTPURLResponse*)self.internalResponse).statusCode == 200) {
        _isUploading = NO;
        if ([self respondsToSelector:self.finishAction]) {
            NSString* result = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
            [self performSelectorOnMainThread:self.finishAction withObject:result waitUntilDone:NO];
            return;
        }
    } else {
        
    }
}




/**
 * ASIHTTPRequest无法被NSURLProtocol监控到，我们暂时不在支持这块
 */
- (void) doCommonUploadWithUrl:(NSString*)url param:(NSDictionary*)paramDics finish:(SEL) finishAction {
    _isUploading = YES;
    self.finishAction = finishAction;
//    NSLog(@"doCommonUploadWithUrl - %@",url);
    self.request = [[TOPRequest alloc]initWithAbsoluteUrl:url];
    self.request.requestTimeout = 10;
    NSArray* allkeys = paramDics.allKeys;
    for (NSString* key in allkeys) {
        [self.request addParam:[paramDics objectForKey:key] forKey:key];
    }
    [self.request setDelegate:self];
    [self.request setRequestDidFinishSelector:@selector(commonUploadSuccess:)];
    [self.request setRequestDidFailedSelector:@selector(commonUploadFailed:)];
    [self.request sendAsyncRequest];

}

- (void)showLoadingView:(BOOL)show {
    if (show) {
        if (_hudUpLoadingView == nil) {
            _hudUpLoadingView = [[HUDActivityView alloc] initWithFrame:self.view.bounds];
            UIImageView* imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"webview_loading"]];
            [_hudUpLoadingView setImageView:imageView];
        }
//        _hudUpLoadingView.textLabel.text = @"加载中...";
        [self.view addSubview:_hudUpLoadingView];
    } else {
        [_hudUpLoadingView removeFromSuperview];
    }
}

- (void) showLoadingViewWithTitle:(NSString*) title {
    if (_hudUpLoadingView == nil) {
        _hudUpLoadingView = [[HUDActivityView alloc] initWithFrame:self.view.bounds];
        UIImageView* imageView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"webview_loading"]];
        [_hudUpLoadingView setImageView:imageView];
    }
    _hudUpLoadingView.textLabel.text = title;
    [self.view addSubview:_hudUpLoadingView];
}

- (void) showAutoHideViewWithTitle:(NSString*) title hideDuration:(float) duration {
    if (_hudUpLoadingView == nil) {
        _hudUpLoadingView = [[HUDActivityView alloc] initWithFrame:self.view.bounds];
    }
    _hudUpLoadingView.textLabel.text = title;
    [_hudUpLoadingView animateShowInView:self.view autoHideAfter:duration];
}

- (void)commonUploadSuccess:(TOPRequest *)request {
    _isUploading = NO;
    if ([self respondsToSelector:self.finishAction]) {
//        NSLog(@"doCommonUploadWithUrl result - %@",request.responseString);
        [self performSelectorOnMainThread:self.finishAction withObject:request waitUntilDone:NO];
        return;
    }
}

- (void)commonUploadFailed:(TOPRequest *)request {
    _isUploading = NO;
    [self showLoadingView:NO];
//    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
//                                                    message:@"数据加载异常,请检查您的网络"
//                                                   delegate:self
//                                          cancelButtonTitle:@"确定"
//                                          otherButtonTitles:nil];
//    [alert show];
    
}

- (void) loadNextPageUrl:(NSString*) url {
    JMOpenURL([NSString stringWithFormat:@"%@?url=%@",CommonWebViewControllerURL,[url stringByURLEncodingStringParameter]]);
}

- (void) loadNextPageUrlWithPreLoad:(NSString*) url {
    JMOpenURLWithPreDataFetch([NSString stringWithFormat:@"%@?url=%@",CommonWebViewControllerURL,[url stringByURLEncodingStringParameter]], ^(JMURLAction* action){
        if ([url rangeOfString:@"usePreload=true"].location != NSNotFound) {
            TOPRequest* request = [[TOPRequest alloc]initWithAbsoluteUrl:[self reConstructCommonQuery:url]];
            [request sendSynchronousRequest];
            NSString* data = request.responseString;
            if (data) {
                [action.query setValue:data forKey:KEY_PRE_DATA];
            }
        }
    });
}

+ (void) loadNextTabbarControllerWithGeneralPagesParams:(NSArray*) pages fromNavigationController:navigationController {
    BaseTabbarController* tabbarController = [[BaseTabbarController alloc] init];
    
    // 获取选项卡控制器视图的所有子视图，保存到一数组中
    NSArray *array = [tabbarController.view subviews];
    // 索引值为1的应该就是TabBar
    for (id subView in array) {
        if ([subView isKindOfClass:[UIView class]]) {
            ((UIView*)subView).backgroundColor = [UIColor whiteColor];

        }
        if ([subView isKindOfClass:[UITabBar class]]) {
            ((UITabBar*)subView).barTintColor = [UIColor whiteColor];
        }
    }
   
    
    
    NSMutableArray* viewControllers = [[NSMutableArray alloc]init];
    
    for (NSDictionary* page in pages) {
        if ([page isKindOfClass:[NSDictionary class]]) {
            NSString* url = [page objectForKey:@"url"];
            NSString* icon = [page objectForKey:@"icon"];
            NSString* hicon = [page objectForKey:@"hicon"];
            NSString* title = [page objectForKey:@"title"];
            NSString* withOutBack = [page objectForKey:@"withOutBack"];
            WebViewControllerBase* webViewController = [[WebViewControllerBase alloc]init];
            if ([withOutBack isEqualToString:@"true"]) {
                webViewController.noBackButton = YES;
            }
            webViewController.originUrl = url;
            webViewController.isInTabbarController = true;
            
            UIColor *colorSelect=COLOR_APP_FOCUS;
            UIColor *color=COLOR_APP_NORMAL;
            
            UITabBarItem *item = [[UITabBarItem alloc] initWithTitle:title image:[UIImage imageNamed:icon] tag:1];
            webViewController.title = title;
            
            [item setFinishedSelectedImage:[UIImage imageForUrl:hicon] withFinishedUnselectedImage:[UIImage imageForUrl:icon]];
            [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                          color, UITextAttributeTextColor,
                                          nil] forState:UIControlStateNormal];
            [item setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                          colorSelect, UITextAttributeTextColor,
                                          nil] forState:UIControlStateSelected];
            webViewController.tabBarItem = item;
            
            [viewControllers addObject:webViewController];
        }
    }
    
    tabbarController.viewControllers = viewControllers;
    
    for (UIViewController* viewController in tabbarController.viewControllers) {
        [viewController viewWillAppear:YES];
    }
    
    [navigationController pushViewController:tabbarController animated:YES];
}

- (void) loadNextTabbarControllerWithGeneralPagesParams:(NSArray*) pages {
    [ViewControllerBase loadNextTabbarControllerWithGeneralPagesParams:pages fromNavigationController:self.navigationController];
}


@end
