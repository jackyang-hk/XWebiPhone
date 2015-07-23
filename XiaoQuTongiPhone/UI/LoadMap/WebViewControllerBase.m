//
//  WebViewControllerBase.m
//  XiaoQuTongiPhone
//
//  Created by redcat on 14-8-3.
//  Copyright (c) 2014年 redcat. All rights reserved.
//

#import "WebViewControllerBase.h"
#import "NSString+URLEncode.h"
#import "JSBadgeView.h"
#import "JMURLAction.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import "WXApi.h"
#import "WXApiObject.h"
#import "NetworkDetect.h"
#import "LocationTestViewController.h"
#import <AlipaySDK/AlipaySDK.h>
#import "Order.h"
#import "DataSigner.h"
#import "QRScanViewController.h"
#import "AppCacheUtil.h"
#import "JUMLNavigationController.h"
#import <JavaScriptCore/JavaScriptCore.h>
@import AdSupport;



static const double  kCameraIncreRate  = 1;
@implementation WebViewControllerBase


// 给没有 http 前缀的URL加上 http://
// 没有http或者https做前作，webview无法打开网页
- (NSString *)addHTTPPrefixToURLString:(NSString *)strURL
{
    if (![strURL hasPrefix:@"http://"] && ![strURL hasPrefix:@"https://"] && ![strURL hasPrefix:@"daguanjia://"])
    {
        return [NSString stringWithFormat:@"http://%@", strURL];
    }
    
    return strURL;
}

- (id) init {
    if (self = [super init]) {
        self.disableRefreshHeaderView = true;
    }
    return self;
}

- (id)initWithNavigatorURL:(NSURL *)URL query:(NSDictionary *)query {
    if ([query objectForKey:@"url"]) {
        self.originUrl = [self addHTTPPrefixToURLString:[[query objectForKey:@"url"] stringByURLDecodingStringParameter]];
        
        if ([self.originUrl rangeOfString:@"withOutBack=true"].location != NSNotFound) {
            self.noBackButton = YES;
        }
        
        if ([self.originUrl rangeOfString:@"disableCache=true"].location != NSNotFound) {
            self.disableCache = YES;
        }
        
        
        if ([self disableNavigationBar:[NSURL URLWithString:self.originUrl]]) {
            self.noNavigation = YES;
        }
        
        self.disableRefreshHeaderView = true;
        
        if ([self.originUrl rangeOfString:@"disableRefreshHeaderView=false"].location != NSNotFound) {
            self.disableRefreshHeaderView = false;
        }
        
        
        NSString* state = [query objectForKey:KEY_PRE_DATA_STATE];
        if ([state isEqualToString:@"start"]) {
            _isPreloading = YES;
        }
    }
    
    if ([query objectForKey:@"title"]) {
        self.title = [query objectForKey:@"title"];
    }
    
    if ([[query objectForKey:@"withOutBack"] isEqualToString:@"true"]) {
        self.noBackButton = YES;
    }
    
//    if ([[query objectForKey:@"fullscreen"] isEqualToString:@"true"]) {
        self.noNavigation = YES;
//    }
    
        self.wantsFullScreenLayout = true;
    
    return [self init];
}

- (void) dataHasFetched:(JMURLAction*)action {
    NSString* htmlDate = [action.query objectForKey:KEY_PRE_DATA];
    if (htmlDate && self.disableCache == false) {
        if (_webView) {
            [_webView loadHTMLString:htmlDate baseURL:nil];
        } else {
            self.htmlData = htmlDate;
        }
    } else {
        if (_webView) {
            [self loadWebView];
        } else {
            _isPreloading = NO;
        }
        
    }
}

- (void) loadView {
    
    UIView* view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view = view;
    self.view.backgroundColor = COLOR_PAGE_BACK;
    
    CGFloat _heightPadding = 64;
    if (self.noNavigation) {
        _heightPadding = -1;
    }
    
    if (self.isInTabbarController) {
        _webView = [[UIWebView alloc]initWithFrame:CGRectMake(-1, _heightPadding, IPHONE_WIDTH+2, IPHONE_HEIGHT + 2 - _heightPadding - 48)];
    } else {
        _webView = [[UIWebView alloc]initWithFrame:CGRectMake(-1, _heightPadding, IPHONE_WIDTH+2, IPHONE_HEIGHT + 2 - _heightPadding)];
    }

    [_webView setAutoresizesSubviews:YES];
    [_webView setAutoresizingMask:UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin];
    [_webView setDelegate:self];
    [_webView.scrollView setDelegate:self];
    [_webView setScalesPageToFit:YES];
    [_webView.scrollView setDecelerationRate:UIScrollViewDecelerationRateNormal];
    _webView.layer.borderColor = COLOR_APP_FOCUS_WITH_ALPHA(0.5).CGColor;
    _webView.layer.borderWidth = 1;
    _webView.scrollView.bounces = false;
    [self.view addSubview:_webView];

    
    [self setUpCustomNavigationBarForTitle:self.title compatibleForBackTitle:@"    "];

    [_webView.scrollView setBackgroundColor:[UIColor whiteColor]];
    if (_refreshTableHeaderView == nil ) {
        
        _refreshTableHeaderView = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0.0f, 0.0f - _webView.bounds.size.height, _webView.frame.size.width, _webView.bounds.size.height)];
        [_refreshTableHeaderView setStatusText:@"加载中..." forStatus:EGOOPullRefreshLoading];
        [_refreshTableHeaderView setStatusText:@"下拉刷新数据..." forStatus:EGOOPullRefreshNormal];
        [_refreshTableHeaderView setStatusText:@"释放刷新数据..." forStatus:EGOOPullRefreshPulling];
        
        _refreshTableHeaderView.delegate = self;
        
        if (self.disableRefreshHeaderView) {
            _refreshTableHeaderView.canTriggerRefresh = false;
        }
        
        [_webView.scrollView addSubview:_refreshTableHeaderView];

    } else {
        UIView* view = [[UIView alloc]initWithFrame:CGRectMake(0.0f, 0.0f - _webView.bounds.size.height, _webView.frame.size.width, _webView.bounds.size.height)];
        view.backgroundColor = [UIColor clearColor];
        [_webView.scrollView addSubview:view];
    }
    
    _rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rightButton setFrame:CGRectMake(240,iOS7?20:0,80,44)];
    [_rightButton.titleLabel setTextAlignment:NSTextAlignmentRight];
    [_rightButton setTitleColor:COLOR_APP_FOCUS forState:UIControlStateNormal];
    [_rightButton setTitleColor:COLOR_APP_NORMAL forState:UIControlStateHighlighted];
    [_rightButton.titleLabel setFont:[UIFont boldSystemFontOfSize:16.0f]];
    [_rightButton addTarget:self action:@selector(toRightButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    [_navigationView addSubview:_rightButton];
    [_rightButton setHidden:YES];
    

    
    _trImageView = [[UIImageView alloc]initWithFrame:CGRectMake(285,iOS7?35:15,15,15)];
    [_navigationView addSubview:_trImageView];
    
    _titleImageView = [[UIImageView alloc]initWithFrame:CGRectMake(136, iOS7?30:10, 48, 20)];
    [_titleImageView setImage:[UIImage imageNamed:@"title@2x.png"]];
    [_navigationView addSubview:_titleImageView];
    [_titleImageView setHidden:YES];

    if (!_isPreloading || self.htmlData != nil) {
        [self loadWebView];
    } else {
        [self showLoadingView:YES];
    }
    
    _locService = [[BMKLocationService alloc]init];
    _webView.keyboardDisplayRequiresUserAction = NO;
    

    
}

- (void) toRightButtonAction:(id) sender {
    if (self.rightButtonFunction != nil && [self.rightButtonFunction compare:@""] != NSOrderedSame) {
        
        if (self.trOpen == nil) {
            [_webView stringByEvaluatingJavaScriptFromString:self.rightButtonFunction];
        } else {
            if ([self.trOpen isEqualToString:@"close"]) {
                self.trOpen = @"open";
                [self trRotateWithExpands:true];
                [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@('%@')",self.rightButtonFunction,self.trOpen]];
            } else {
                self.trOpen = @"close";
                [self trRotateWithExpands:false];
                [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@('%@')",self.rightButtonFunction,self.trOpen]];
            }
        }
    }
    
}

- (void)trRotateWithExpands:(BOOL)expands {
    
//    POPSpringAnimation *rotate = [POPSpringAnimation animationWithPropertyNamed:kPOPLayerRotation];
//    
//    rotate.toValue = (expands)?@(M_PI_4 * 3):@(0);
//    rotate.removedOnCompletion = YES;
//    
//    [iconView_.layer pop_addAnimation:rotate forKey:@"rotate"];

    [UIView animateWithDuration:0.3 animations:^(void){
        _trImageView.transform = expands ? CGAffineTransformMakeRotation(M_PI_4 * 3)
                                          : CGAffineTransformIdentity;
    }];
}





- (void) updateRightButton:(NSString*) title jsFunction:(NSString*) jsFunction type:(NSString*)type badge:(NSString*)badge{
    
    
    self.rightButtonFunction = jsFunction;
    [_rightButton setTitle:title forState:UIControlStateNormal];
    
    if (badge) {
        if (badgeView == nil) {
            badgeView = [[JSBadgeView alloc] initWithParentView:_rightButton alignment:JSBadgeViewAlignmentTopRight];
            badgeView.badgeBackgroundColor = [UIColor clearColor];
            badgeView.badgeTextColor = [UIColor whiteColor];
        }
        badgeView.badgeText = [NSString stringWithFormat:@"%@",badge];
    } else {
        [badgeView removeFromSuperview];
        badgeView = nil;
    }
    
    if (type == nil || [type isEqualToString:@"normal"]) {
        [_trImageView setImage:nil];
        [_rightButton setImage:nil forState:UIControlStateNormal];
        [_rightButton setTitle:title forState:UIControlStateNormal];
        self.trOpen = nil;
    } else if ([type isEqualToString:@"push"]) {
        [_trImageView setImage:nil];
        [_rightButton setImage:[UIImage imageNamed:@"sms"] forState:UIControlStateNormal];
        [_rightButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0.0, 0.0, -30)];
        [_rightButton setTitle:nil forState:UIControlStateNormal];
        self.trOpen = nil;
    } else if ([type isEqualToString:@"pluse"]) {
        [_trImageView setImage:[UIImage imageNamed:@"pluse"]];
        [_rightButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0.0, 0.0, -30)];
        [_rightButton setTitle:nil forState:UIControlStateNormal];
        self.rightButtonFunction = jsFunction;
        self.trOpen = @"close";
    }
    
    if (self.title == nil || [self.title compare:@""] == NSOrderedSame) {
        [_rightButton setHidden:YES];
        self.rightButtonFunction = jsFunction;
    } else {
        [_rightButton setHidden:NO];
    }
    
}

- (void)doneLoadingWebView{
	_isNativeBridging = NO;
	//  model should call this when its done loading
	_isloading = NO;
    [self showLoadingView:NO];
	[_refreshTableHeaderView egoRefreshScrollViewDataSourceDidFinishedLoading:_webView.scrollView];
	
}

- (void) loadWebView {

    if (self.htmlData != nil && self.disableCache != true) {
        [_webView loadHTMLString:self.htmlData baseURL:nil];
        self.htmlData = nil;
        return;
    }
    
    if (![self.originUrl hasPrefix:@"daguanjia://"]) {
        self.originUrl = [self reConstructCommonQuery:self.originUrl];
    }

//    NSLog(@"loading web page %@",self.originUrl);
    
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.originUrl] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0f];
    [_webView loadRequest:request];
}

#pragma mark - web view delegate

- (BOOL) needNewPage:(NSURL*) url {
    NSString* query = [url query];
    if (query != nil && ([query rangeOfString:@"page=new-app-page" options:NSCaseInsensitiveSearch].location != NSNotFound)) {
        return true;
    }
    return false;
    
}

- (BOOL) disableNavigationBar:(NSURL*) url {
    NSString* query = [url query];
    if (query != nil && ([query rangeOfString:@"fullscreen=true" options:NSCaseInsensitiveSearch].location != NSNotFound)) {
        return true;
    }
    return false;
    
}

- (void) doWebBridgeOperation :(NSString*) operationData {
    NSError* error;
    id operation = [operationData objectFromJSONStringWithParseOptions:JKSerializeOptionPretty error:&error];
    if ([operation isKindOfClass:[NSDictionary class]]) {
        NSString* action = [operation objectForKey:@"action"];
        NSDictionary* params = [operation objectForKey:@"params"];
        if ([action isEqualToString:@"tabPage"]) {
            NSArray* urlMaps = [params objectForKey:@"pages"];
            if ([urlMaps count] > 1) {
                [self loadNextTabbarControllerWithGeneralPagesParams:urlMaps];
            }
        } else if ([action isEqualToString:@"page"]) {
            NSString* url = [params objectForKey:@"url"];
            if (url) {
                [self loadNextPageUrlWithPreLoad:url];
            }
        } else if ([action isEqualToString:@"displayReload"]) {
            self.needDidAppearReload = true;
            displayReloadCallback = [params objectForKey:@"callback"];
        } else if ([action isEqualToString:@"showAlert"]) {
            NSString* title = [params objectForKey:@"title"];
            NSString* content = [params objectForKey:@"content"];
            SHOW_ALERT(title, content);
        } else if ([action isEqualToString:@"getSystemLocation"]) {
            [JULocationManager startUpLocate];
            NSString* callback = [params objectForKey:@"callback"];
            if ([JULocationManager sharedInstance].isLatestLocateSuccess) {
                NSString* jsexe = [NSString stringWithFormat:@"%@('%.8f','%.8f');",callback,[JULocationManager sharedInstance].latestLocation.coordinate.longitude,[JULocationManager sharedInstance].latestLocation.coordinate.latitude];
                [_webView stringByEvaluatingJavaScriptFromString:jsexe];
            } else {
                NSString* jsexe = [NSString stringWithFormat:@"%@('0','0');",callback];
                [_webView stringByEvaluatingJavaScriptFromString:jsexe];
                [JULocationManager startUpLocate];
            }
            
        } else if ([action isEqualToString:@"backNavigation"]) {
            if ([[params objectForKey:@"animation"] isEqualToString:@"false"]) {
                [self.navigationController popViewControllerAnimated:NO];
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        } else if ([action isEqualToString:@"updateNTitle"]) {
            NSString* title = [params objectForKey:@"title"];
            [self _updateCurrentTitle:title];
        } else if ([action isEqualToString:@"updateNTRButton"]) {
            NSString* title = [params objectForKey:@"title"];
            NSString* jsfunction = [params objectForKey:@"clicked"];
            NSString* badge = [params objectForKey:@"badge"];;
            
            [self updateRightButton:title jsFunction:jsfunction type:nil badge:badge];
        } else if ([action isEqualToString:@"updateNTRPlus"]) {
            NSString* title = [params objectForKey:@"title"];
            NSString* jsfunction = [params objectForKey:@"clicked"];
            NSString* badge = [params objectForKey:@"badge"];
            NSString* close = [params objectForKey:@"close"];
            
            [self updateRightButton:title jsFunction:jsfunction type:@"pluse" badge:badge];
            
            if ([close isEqualToString:@"true"]) {
                [self trRotateWithExpands:false];
            }
            
        } else if ([action isEqualToString:@"save"]) {
            for (NSString* key in [params allKeys]) {
                NSString* value = [params objectForKey:key];
                if (value == nil || [value isEqualToString:@""]) {
                    [[ISDiskCache sharedCache] removeObjectForKey:key];
                    //目前先加三个钩子，便于数据存放到PARAMS
                    if ([key isEqualToString:@"mobile"]) {
                        [TBTop sharedInstance].mobile = nil;
                    } else if ([key isEqualToString:@"communityId"]) {
                        [TBTop sharedInstance].communityId = nil;
                    } else if ([key isEqualToString:@"session"]) {
                        [TBTop sharedInstance].session = nil;
                    }
                } else {
                    [[ISDiskCache sharedCache] setObject:value forKey:key];
                    //目前先加三个钩子，便于数据存放到PARAMS
                    if ([key isEqualToString:@"mobile"]) {
                        [TBTop sharedInstance].mobile = value;
                    } else if ([key isEqualToString:@"communityId"]) {
                        [TBTop sharedInstance].communityId = value;
                    } else if ([key isEqualToString:@"session"]) {
                        [TBTop sharedInstance].session = value;
                    }
                }
            }
        } else if ([action isEqualToString:@"get"]) {
            NSString* key = [params objectForKey:@"key"];
            NSString* backFunction = [params objectForKey:@"callback"];
            NSString* value = [[ISDiskCache sharedCache] objectForKey:key];
            
            if ((value == nil || [value isEqualToString:@""]) && [key isEqualToString:@"identifierForVendor"]) {
                value = [[UIDevice currentDevice].identifierForVendor UUIDString];
//            } else if ((value == nil || [value isEqualToString:@""]) && [key isEqualToString:@"identifierForAdvertising"]) {
//                value = [[ASIdentifierManager sharedManager].advertisingIdentifier UUIDString];
            }
            
            NSString* jsexe = [NSString stringWithFormat:@"%@('%@','%@');",backFunction,key,value!=nil?value:@""];
            [_webView stringByEvaluatingJavaScriptFromString:jsexe];
        } else if ([action isEqualToString:@"sendPost"]) {
            NSString* url = [params objectForKey:@"url"];
            NSDictionary* query = [params objectForKey:@"data"];
            NSString* backFunction = [params objectForKey:@"callback"];
            NSString* sequence = [params objectForKey:@"sequence"];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
                TOPRequest* request = [[TOPRequest alloc]initWithAbsoluteUrl:[self constructUrl:url withParam:query]];
                [request setBackFunction:backFunction];
                [request setSequence:sequence];
                [request setDelegate:self];
                [request setRequestDidFinishSelector:@selector(requestDidFinished:)];
                [request setRequestDidFailedSelector:@selector(requestDidFailed:)];
                [request sendSynchronousRequest];
                NSString* result = request.responseString;
                NSString* jsexe = [NSString stringWithFormat:@"%@('%@','%@');",backFunction,sequence,result!=nil?[result stringByURLEncodingStringParameter]:@""];
                
                [_webView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:jsexe waitUntilDone:NO];
//                    [_webView stringByEvaluatingJavaScriptFromString:jsexe];
                
            });
            
        } else if ([action isEqualToString:@"sendGet"]) {
            NSString* url = [params objectForKey:@"url"];
            NSDictionary* query = [params objectForKey:@"data"];
            NSString* backFunction = [params objectForKey:@"callback"];
            NSString* sequence = [params objectForKey:@"sequence"];
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
                TOPRequest* request = [[TOPRequest alloc]initWithAbsoluteUrl:[self constructUrl:url withParam:query]];
                [request setBackFunction:backFunction];
                [request setSequence:sequence];
                [request setDelegate:self];
                [request setRequestDidFinishSelector:@selector(requestDidFinished:)];
                [request setRequestDidFailedSelector:@selector(requestDidFailed:)];
                [request sendSynchronousRequest];
                NSString* result = request.responseString;
                NSString* jsexe = [NSString stringWithFormat:@"%@('%@','%@');",backFunction,sequence,result!=nil?[result stringByURLEncodingStringParameter]:@""];
                
                [_webView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:jsexe waitUntilDone:NO];
            });

        } else if ([action isEqualToString:@"openPicPicker"]) {
            self.imagePickerFinishFunction = [params objectForKey:@"callback"];
            
            //初始化UIImagePickerController 指定代理
            UIImagePickerController * imagePicker = [[UIImagePickerController alloc] init];
            //选择类型相机，相册还是什么
            imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            /*enum {
             UIImagePickerControllerSourceTypePhotoLibrary,
             UIImagePickerControllerSourceTypeCamera,
             UIImagePickerControllerSourceTypeSavedPhotosAlbum
             };
             typedef NSUInteger UIImagePickerControllerSourceType;
             */
            //指定代理 因此我们要实现 IImagePickerControllerDelegate,UINavigationControllerDelegate 协议
            imagePicker.delegate = self;
            //允许编辑
            imagePicker.allowsEditing = YES;
            //显示相册
            [self presentViewController:imagePicker animated:YES completion:^(void){
                
            }];
            
        } else if ([action isEqualToString:@"openNativeUrl"]) {
            NSString* nativeUrl = [params objectForKey:@"nativeUrl"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:nativeUrl]];
         } else if ([action isEqualToString:@"openScan"]) {
            self.scanPickerFinishFunction = [params objectForKey:@"callback"];
            [self startReading];
        } else if ([action isEqualToString:@"weixin"]) {
            NSString* type = [params objectForKey:@"type"];
            if ([type isEqualToString:@"sharelink"]) {
                NSString* title = [params objectForKey:@"title"];
                NSString* description = [params objectForKey:@"description"];
                NSString* url = [params objectForKey:@"url"];
                [self respTimeLineLinkContent:title description:description url:url];
            } else if ([type isEqualToString:@"shareFriend"]) {
                NSString* title = [params objectForKey:@"title"];
                NSString* description = [params objectForKey:@"description"];
                NSString* url = [params objectForKey:@"url"];
                [self respLinkContent:title description:description url:url];
            }
        } else if ([action isEqualToString:@"setStatusBar"]) {
            NSString* type = [params objectForKey:@"type"];
            if ([type isEqualToString:@"setDefault"]) {
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            } else if ([type isEqualToString:@"setWhite"]) {
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            } else if ([type isEqualToString:@"setBlackTranslucent"]) {
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];
            } else if ([type isEqualToString:@"setBlackOpaque"]) {
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
            }
        } else if ([action isEqualToString:@"locationTest"]) {
            LocationTestViewController* viewController = [[LocationTestViewController alloc] initWithNibName:nil bundle:nil];
            [self.navigationController pushViewController:viewController animated:YES];

        } else if ([action isEqualToString:@"showLoading"]) {
            [self showLoadingView:YES];
        } else if ([action isEqualToString:@"hideLoading"]) {
            [self showLoadingView:NO];
        } else if ([action isEqualToString:@"alipay"]) {
            NSString* tradeNO = [params objectForKey:@"tradeNO"];
            NSString* productName = [params objectForKey:@"productName"];
            NSString* productDescription = [params objectForKey:@"productDescription"];
            NSString* amount = [params objectForKey:@"amount"];
            NSString* notifyURL = [params objectForKey:@"notifyURL"];
            NSString* callbackURL = [params objectForKey:@"callbackURL"];
            self.alipayCallBackUrl = callbackURL;
            
            //老版本Callback不区分成功还是失败
            if (callbackURL != nil && ![callbackURL isEqualToString:@""]) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alipayBack:) name:@"alipaycallback" object:nil];
            }
            //新版本成功返回
            
            
            /*============================================================================*/
            /*=======================需要填写商户app申请的===================================*/
            /*============================================================================*/
            NSString *partner = @" input ";
            NSString *seller = @" input ";
            NSString *privateKey = @" input ";
            /*============================================================================*/
            /*============================================================================*/
            /*============================================================================*/
            /*
             *生成订单信息及签名
             */
            //将商品信息赋予AlixPayOrder的成员变量
            Order *order = [[Order alloc] init];
            order.partner = partner;
            order.seller = seller;
            order.tradeNO = tradeNO; //订单ID（由商家自行制定）
            order.productName = productName; //商品标题
            order.productDescription = productDescription; //商品描述
            order.amount = amount; //商品价格
            order.notifyURL =  notifyURL; //回调URL
            
            order.service = @"mobile.securitypay.pay";
            order.paymentType = @"1";
            order.inputCharset = @"utf-8";
            order.itBPay = @"30m";
            order.showUrl = @"m.alipay.com";
            
            //应用注册scheme,在AlixPayDemo-Info.plist定义URL types
            NSString *appScheme = @"daguanjia";
            
            //将商品信息拼接成字符串
            NSString *orderSpec = [order description];
            NSLog(@"orderSpec = %@",orderSpec);
            
            //获取私钥并将商户信息签名,外部商户可以根据情况存放私钥和签名,只需要遵循RSA签名规范,并将签名字符串base64编码和UrlEncode
            id<DataSigner> signer = CreateRSADataSigner(privateKey);
            NSString *signedString = [signer signString:orderSpec];
            
            //将签名成功字符串格式化为订单字符串,请严格按照该格式
            NSString *orderString = nil;
            if (signedString != nil) {
                orderString = [NSString stringWithFormat:@"%@&sign=\"%@\"&sign_type=\"%@\"",
                               orderSpec, signedString, @"RSA"];
                
                [[AlipaySDK defaultService] payOrder:orderString fromScheme:appScheme callback:^(NSDictionary *resultDic) {
                    NSString* resultStatus = [resultDic objectForKey:@"resultStatus"];
                    
                    if (callbackURL != nil && ![callbackURL isEqualToString:@""]) {
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
                        
                        self.originUrl = [self addQuery:param toUrl:callbackURL];
                        [self loadWebView];
                    } else {
                        if ([resultStatus isEqualToString:@"9000"]) {
                            SHOW_ALERT(@"闪电购", @"订单支付成功");
                        } else if ([resultStatus isEqualToString:@"8000"]) {
                            SHOW_ALERT(@"闪电购", @"支付正在处理中");
                        } else if ([resultStatus isEqualToString:@"4000"]) {
                            SHOW_ALERT(@"闪电购", @"订单支付失败");
                        } else if ([resultStatus isEqualToString:@"6001"]) {
                            SHOW_ALERT(@"闪电购", @"用户中途取消");
                        } else if ([resultStatus isEqualToString:@"6002"]) {
                            SHOW_ALERT(@"闪电购", @"网络连接出错");
                        }
                    }

                }];
                
            }
        } else if ([action isEqualToString:@"weixinpay"]) {
            //调起微信支付
            PayReq* req             = [[PayReq alloc] init];
            req.openID              = [params objectForKey:@"appid"];
            req.partnerId           = [params objectForKey:@"partnerid"];
            req.prepayId            = [params objectForKey:@"prepayid"];
            req.nonceStr            = [params objectForKey:@"noncestr"];
            NSMutableString *stamp  = [params objectForKey:@"timestamp"];
            req.timeStamp           = stamp.intValue;
            req.package             = [params objectForKey:@"package"];
            req.sign                = [params objectForKey:@"sign"];
            NSString* callbackURL = [params objectForKey:@"callbackURL"];
            self.weixinPayCallBackUrl = callbackURL;
            
            if (callbackURL != nil && ![callbackURL isEqualToString:@""]) {
                [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(weixinPayBack:) name:@"weixinpaycallback" object:nil];
            }
            
            [WXApi safeSendReq:req];
        } else if ([action isEqualToString:@"getLocation"]) {
            self.startTime = [[NSDate date] timeIntervalSince1970]*1000;
            NSString* callback = [params objectForKey:@"callback"];
            self.bmLocationCallBackUrl = callback;
            [_locService startUserLocationService];
        } else if ([action isEqualToString:@"getCacheSize"]) {
            NSString* callback = [params objectForKey:@"callback"];
            NSString* appCacheSize = [NSString stringWithFormat:@"%0.2f",[AppCacheUtil appCacheSize]];
            NSString* jsexe = [NSString stringWithFormat:@"%@('%@');",callback,appCacheSize];
            [_webView stringByEvaluatingJavaScriptFromString:jsexe];
        } else if ([action isEqualToString:@"clearCache"]) {
            NSString* callback = [params objectForKey:@"callback"];
            [AppCacheUtil clearCache];
            NSString* jsexe = [NSString stringWithFormat:@"%@('%@');",callback,@"success"];
            [_webView stringByEvaluatingJavaScriptFromString:jsexe];
        } else if ([action isEqualToString:@"reloadCurrentPage"]) {
            [self loadWebView];
        }

    }
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    self.endTime = [[NSDate date] timeIntervalSince1970]*1000;
    if (self.bmLocationCallBackUrl != nil && userLocation.location != nil) {
        //本地记录最近的位置
        [JULocationManager sharedInstance].isLatestLocateSuccess = YES;
        [[JULocationManager sharedInstance] setLatestLocation:userLocation.location];
        
        //执行JS返回
        NSString* jsexe = [NSString stringWithFormat:@"%@('%.8f','%.8f');",self.bmLocationCallBackUrl,userLocation.location.coordinate.longitude,userLocation.location.coordinate.latitude];
        [_webView stringByEvaluatingJavaScriptFromString:jsexe];
        self.bmLocationCallBackUrl = nil;
        [_locService stopUserLocationService];
    }
}

/**
 *在地图View停止定位后，会调用此函数
 *@param mapView 地图View
 */
- (void)didStopLocatingUser
{
    if (self.bmLocationCallBackUrl != nil) {
        NSString* jsexe = [NSString stringWithFormat:@"%@('0','0');",self.bmLocationCallBackUrl];
        [_webView stringByEvaluatingJavaScriptFromString:jsexe];
        self.bmLocationCallBackUrl = nil;
        
    }
}


- (void) weixinPayBack:(NSNotification*) notification {
    if (self.weixinPayCallBackUrl != nil && ![self.weixinPayCallBackUrl isEqualToString:@""]) {
        NSDictionary* param = [notification object];
        self.originUrl = [self addQuery:param toUrl:self.weixinPayCallBackUrl];
        [self loadWebView];
    }
}

- (void) alipayBack:(NSNotification *)notification {
    if (self.alipayCallBackUrl != nil && ![self.alipayCallBackUrl isEqualToString:@""]) {
        NSDictionary* param = [notification object];
        self.originUrl = [self addQuery:param toUrl:self.alipayCallBackUrl];
        [self loadWebView];
    }
}

- (void) requestDidFinished:(TOPRequest*) request {
    [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(%@,%@)",request.backFunction,request.sequence,request.responseString]];
}

- (void) requestDidFailed:(TOPRequest*) request {
     [_webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"%@(%@,%@)",request.backFunction,request.sequence,@"time out"]];
}

- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request navigationType:(UIWebViewNavigationType)navigationType {
    //这个阶段这个版本，不允许自定义Top Bottom Left Right
    [_webView.scrollView setContentInset:UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, 0.0f)];
    
    NSURL *url = [request URL];
//    NSLog(@"loading new url: ->%@",url);
    
    NSString *currentUrl = [url absoluteString];
    
    //内部页面调用优先
    if ([url.absoluteString rangeOfString:@"daguanjia://local"].location != NSNotFound) {
        if ([url.query isEqualToString:@"AppLoadError"]) {
            NSString *errorPagePath = [[NSBundle mainBundle] pathForResource:@"AppLoadError" ofType:@"html" ];
            NSData *htmlData = [NSData dataWithContentsOfFile:errorPagePath];
            NSString* htmlString = [[NSString alloc]initWithData:htmlData encoding:NSUTF8StringEncoding];
            if (htmlData) {
                //        [_webView loadData:htmlData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:@" http://www.52shangou.com" ]];
                [_webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"http://www.51xianqu.com"]];
            }
        } else if ([url.query isEqualToString:@"NetworkInfo"]) {
            NSString *errorPagePath = [[NSBundle mainBundle] pathForResource:@"NetworkInfo" ofType:@"html" ];
            NSData *htmlData = [NSData dataWithContentsOfFile:errorPagePath];
            NSString* htmlString = [[NSString alloc]initWithData:htmlData encoding:NSUTF8StringEncoding];
            if (htmlData) {
                //        [_webView loadData:htmlData MIMEType:@"text/html" textEncodingName:@"UTF-8" baseURL:[NSURL URLWithString:@" http://www.52shangou.com" ]];
                [_webView loadHTMLString:htmlString baseURL:[NSURL URLWithString:@"http://www.51xianqu.com"]];
            }
        }
        return NO;
    }

    
    if ([[[request URL] absoluteString] isEqualToString:@"about:blank"]) {
        return NO;
    }
    
    //首次进入不拦截，直接回调执行
    if (currentUrl == nil || [currentUrl isEqualToString:self.originUrl]){
        return YES;
    }
    
    
    //行为拦截
    /* xiaoqu://operation?{"action":"back","target":"navigation","animation":"true"}
     * xiaoqu://operation?{"action":"update","target":"rightButton","badge":"102","type":"push","title":"购物车","url":"http://www.baidu.com"}
     * xiaoqu://operation?{"action":"delete","target":"rightButton","type":"cart","javascript":"xxxxx"}
     */
    if ([url.absoluteString rangeOfString:@"daguanjia://operation"].location != NSNotFound) {
        _isNativeBridging = YES;
//        NSLog(@"load bridge url :%@",url);
        [self doWebBridgeOperation:[url.query stringByURLDecodingStringParameter]];
        return NO;
    }
    
    
    
//    NSString *schema = [[url scheme] lowercaseString];
    //拉起Native页面
    if ([self needNewPage:url] && !_isloading) {
        _isloading = YES;
        // stop loading
        [webView stopLoading];
    
        // 当压入视图控制器动画没有结束时，如果马上压入堆栈，
        // 当前navigation controller存在两个动画，页面会错乱，
        // 当视图返回的时候会引发crash，所以延迟打开新视图控制器
        [self performSelector:@selector(_openControllerWithURL:) withObject:url afterDelay:0.1];
        
        _isloading = NO;
        return NO;
    } else if (_isloading) {
        //drop
        if ([url.absoluteString rangeOfString:@"52shangou.com"].location != NSNotFound || [url.absoluteString rangeOfString:@"51xianqu.com"].location != NSNotFound) {
            return NO;
        }

    }
    
    if ([url.absoluteString rangeOfString:@"daguanjia://go"].location != NSNotFound) {
        //        JMOpenURL(LoginViewControllerURL);
        JMOpenURL(url.absoluteString);
        return NO;
    }
    
    self.title = nil;
    
    return YES;
}


- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [self doneLoadingWebView];
    
    //get title from web
    if (self.title == nil) {
        NSString *htmlTitle = [webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        if (htmlTitle != nil && [htmlTitle length] > 0) {
            self.title = htmlTitle;
            [self _updateCurrentTitle:self.title];
        }
    }
    if (self.title == nil) {
        self.title = @"闪电购";
    }
    
//    NSLog(@"cache key -> %@",[[NSUserDefaults standardUserDefaults] objectForKey:@"WebKitCacheModelPreferenceKey"]);
#ifdef DEBUG
    JSContext *ctx = [_webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    ctx[@"console"][@"log"] = ^(JSValue * msg) {
        NSLog(@"JavaScript %@ log message: %@", [JSContext currentContext], msg);
    };
#endif
}


- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    _isloading = NO;
    [NSThread sleepForTimeInterval:1];
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"daguanjia://local?AppLoadError"] cachePolicy:NSURLRequestReloadIgnoringCacheData timeoutInterval:60.0f];
    [_webView loadRequest:request];
    
//    [self doneLoadingWebView];
    [NetworkDetect showNetworkInfo];
    
    
}

- (void) webViewDidStartLoad:(UIWebView *)webView {
//    if (!_isNativeBridging) {
        [self showLoadingView:YES];
//    }
    _isloading = YES;
//    NSLog(@"webViewDidStartLoad %@",webView.request.URL);
}


#pragma mark -
#pragma mark UIScrollViewDelegate Methods
- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    //EGOPullRefresh
    if (self.disableRefreshHeaderView) {
        [_refreshTableHeaderView removeFromSuperview];
    }
    
    [_refreshTableHeaderView egoRefreshScrollViewDidScroll:scrollView];
    
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
	
	[_refreshTableHeaderView egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark -
#pragma mark EGORefreshTableHeaderDelegate Methods

- (void)egoRefreshTableHeaderDidTriggerRefresh:(EGORefreshTableHeaderView*)view{
    [self loadWebView];
    
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(EGORefreshTableHeaderView*)view{
	return _isloading; // should return if data source model is reloading
	
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	return [NSDate date]; // should return date data source was last changed
	
}


- (void) _updateCurrentTitle:(NSString*) htmlTitle {
    if (htmlTitle == nil || [htmlTitle isEqualToString:@""]) {
        htmlTitle = @"闪电购";
    }
    
    if ([htmlTitle isEqualToString:@"闪电购"]) {
        [_titleImageView setHidden:NO];
        [_titleLabel setHidden:YES];
    } else {
        [_titleImageView setHidden:YES];
        [_titleLabel setHidden:NO];
    }
    
    _titleLabel.text = htmlTitle;
}

- (void)_openControllerWithURL:(NSURL *)url {
//    __block NSString* nextUrl = [url.absoluteString stringByURLEncodingStringParameter];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
//        nextUrl = [self reConstructCommonQuery:nextUrl];
//        loadingHtml = true;
//        htmlData = [NSString stringWithContentsOfURL:[NSURL URLWithString:nextUrl] encoding:NSUTF8StringEncoding error:nil];
//        loadingHtml = false;
//        dispatch_async(dispatch_get_main_queue(), ^(void){
//            [[NSNotificationCenter defaultCenter] postNotificationName:nextUrl object:nil];
//        });
//    });
//    JMOpenURL([NSString stringWithFormat:@"%@?url=%@",CommonWebViewControllerURL,[url.absoluteString stringByURLEncodingStringParameter]]);
    JMOpenURLWithPreDataFetch([NSString stringWithFormat:@"%@?url=%@",CommonWebViewControllerURL,[url.absoluteString stringByURLEncodingStringParameter]], ^(JMURLAction* action){
        if ([url.absoluteString rangeOfString:@"usePreload=true"].location != NSNotFound) {
            TOPRequest* request = [[TOPRequest alloc]initWithAbsoluteUrl:[self reConstructCommonQuery:url.absoluteString]];
            [request sendSynchronousRequest];
            NSString* data = request.responseString;
            if (data) {
                [action.query setValue:data forKey:KEY_PRE_DATA];
            }
        }
    });
    
}


- (void) viewDidLoad {
    [super viewDidLoad];
}


-(void)viewWillAppear:(BOOL)animated {
    _locService.delegate = self;
    
    //控制手势返回
    if ([self.originUrl rangeOfString:@"canDragBack=false"].location != NSNotFound) {
        ((JUMLNavigationController*)self.navigationController).canDragBack = NO;
    } else {
        ((JUMLNavigationController*)self.navigationController).canDragBack = YES;
    }
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    _locService.delegate = nil;
}

- (void) viewDidAppear:(BOOL)animated {
    if (self.needDidAppearReload) {
        self.needDidAppearReload = false;
        NSString* jsexe = [NSString stringWithFormat:@"%@();",displayReloadCallback];
        [_webView stringByEvaluatingJavaScriptFromString:jsexe];
    }
}

#define IOS7 [[[UIDevice currentDevice] systemVersion]floatValue]>=7
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    if (self.scanPickerFinishFunction != nil) {
        if(IOS7)
        {
            QRScanViewController * rt = [[QRScanViewController alloc]init];
            [self presentViewController:rt animated:YES completion:^{
                NSString*data = rt.result;
                NSString* jsexe = [NSString stringWithFormat:@"%@('%@');",self.scanPickerFinishFunction,data];
                self.scanPickerFinishFunction = nil;
                [_webView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:jsexe waitUntilDone:NO];
                [_webView stringByEvaluatingJavaScriptFromString:jsexe];
            }];
            
        }
        else
        {
            //        [self scanBtnAction];
            SHOW_ALERT(@"闪电购提醒您", @"扫码功能需要升级到iOS7");
        }

//        
//        [picker dismissViewControllerAnimated:YES completion:^(void){}];
//        
//        if (self.scanPickerFinishFunction) {
//            NSString* jsexe = [NSString stringWithFormat:@"%@('%@');",self.scanPickerFinishFunction,symbol.data];
//            self.scanPickerFinishFunction = nil;
//            [_webView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:jsexe waitUntilDone:NO];
//            [_webView stringByEvaluatingJavaScriptFromString:jsexe];
//
//        }
        
        return ;
    }
    if (self.imagePickerFinishFunction == nil) {
        [picker dismissViewControllerAnimated:YES completion:^(void){}];
        return;
    }
//    self.imageView.image = [info valueForKey:@"UIImagePickerControllerOriginalImage"];
    
    //通过UIImagePickerControllerMediaType判断返回的是照片还是视频
    NSString* type = [info objectForKey:UIImagePickerControllerMediaType];
    //如果返回的type等于kUTTypeImage，代表返回的是照片,并且需要判断当前相机使用的sourcetype是拍照还是相册
    if ([type isEqualToString:(NSString*)kUTTypeImage]) {
        //获取照片的原图
        UIImage* original = [info objectForKey:UIImagePickerControllerOriginalImage];
        //获取图片裁剪的图
        UIImage* editImage = [info objectForKey:UIImagePickerControllerEditedImage];
//        //获取图片裁剪后，剩下的图
//        UIImage* crop = [info objectForKey:UIImagePickerControllerCropRect];
//        //获取图片的url
////        NSURL* url = [info objectForKey:UIImagePickerControllerMediaURL];
//        //获取图片的metadata数据信息
//        NSDictionary* metadata = [info objectForKey:UIImagePickerControllerMediaMetadata];
//       
        
        CGRect mainbound = [UIScreen mainScreen].bounds;
        double scale = mainbound.size.height/editImage.size.height;
        if (editImage.size.width>editImage.size.height) {
            scale = mainbound.size.height/editImage.size.width;
        }
        //    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        //        scale = scale*[[UIScreen mainScreen] scale];
        //    }
//        UIImage* scaledimage =[self scaleAndRotatePhoto:editImage withRotate:scale];
        UIImage* scaledimage = editImage;
        
//        ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:[NSURL URLWithString:@"http://121.199.39.142/settings/imageUploadPort.php"]];
       
        
        
        //第四个字段
        
        NSData *data = UIImageJPEGRepresentation(scaledimage,1.0);
        
        int size = 512000;//上限500k
        int current_size = 0;
        int actual_size = 0;
        current_size = [data length];
        if (current_size > size)
        {
            actual_size = size/current_size;
            data = UIImageJPEGRepresentation(scaledimage,actual_size);
        }
        
        [self showLoadingViewWithTitle:@"正在上传图片中"];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
            
            
            NSURL* url = [NSURL URLWithString:@"http://www.52shangou.com/settings/imageUploadiPhonePort.php"];
            ASIFormDataRequest *request = [ASIFormDataRequest requestWithURL:url];
            [request setData:data withFileName:@"upload.jpg" andContentType:@"image/jpg" forKey:@"file"];
            [request startSynchronous];
            NSString* result =[request responseString];
            result = [result stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSLog(@"upload result:%@",result);
            

            dispatch_async(dispatch_get_main_queue(), ^(void){
                if (self.imagePickerFinishFunction) {
                    NSString* jsexe = [NSString stringWithFormat:@"%@('%@');",self.imagePickerFinishFunction,result];
                    
                    [_webView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:jsexe waitUntilDone:NO];
                    [_webView stringByEvaluatingJavaScriptFromString:jsexe];
                }
                [self showLoadingView:NO];
            });
            
        });
        
        

        
        
        
        
        
    }else{
        
    }
    
    [picker dismissViewControllerAnimated:YES completion:^(void){}];
    
    // NSValue * cropRect = [info objectForKey:UIImagePickerControllerCropRect];
    // CGRect rect = [cropRect CGRectValue];
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"取消选取");
    [picker dismissViewControllerAnimated:YES completion:^(void){}];
}

//#pragma mark Photos take delegate
//
//- (UIImage*)scaleAndRotatePhoto:(UIImage*)image withRotate:(double_t) scale{
//    NSInteger width = image.size.width;
//    NSInteger height = image.size.height;
//    CGRect bounds = CGRectMake(0, 0, width*scale/kCameraIncreRate, height*scale);
//    if (width>height) {
//        bounds.size.width = height*scale/kCameraIncreRate;
//        bounds.size.height = width*scale;
//    }
//    
//    UIGraphicsBeginImageContext(bounds.size);
//    UIImageOrientation orientation = image.imageOrientation;
//    CGContextRef context = UIGraphicsGetCurrentContext();
//    switch (orientation) {
//            //device竖直拍摄的orientation结果 理解为摄像头对device的位置,
//            //与device位置冲突，欢迎拍砖，fu.zehua
//        case UIImageOrientationRight:
//            break;
//        case UIImageOrientationUp://水平左
//            CGContextTranslateCTM(context, height*scale, 0);
//            CGContextRotateCTM(context, M_PI/2.0);
//            break;
//        case UIImageOrientationLeft:
//            CGContextTranslateCTM(context, width*scale, height*scale);
//            CGContextRotateCTM(context, M_PI);
//            break;
//        case UIImageOrientationDown:
//            CGContextTranslateCTM(context, 0, width*scale);
//            CGContextRotateCTM(context, -M_PI/2.0);
//            break;
//        default:
//            break;
//    }
//    [image drawInRect:CGRectMake(0, 0, width*scale, height*scale)];
//    
//    UIImage* imageCopy = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
//    return imageCopy;
//    
//}



- (void)startReading {
//    ZBarReaderViewController *reader = [ZBarReaderViewController new];
//    reader.readerDelegate = self;
//    ZBarImageScanner *scanner = reader.scanner;
//    [scanner setSymbology: ZBAR_I25
//                   config: ZBAR_CFG_ENABLE
//                       to: 0];
//    [self presentViewController:reader
//                            animated: YES completion:^(void){}];
    if(IOS7)
    {
        QRScanViewController * rt = [[QRScanViewController alloc]init];

        rt.completion = ^(NSString* result){
            NSString*data = result;
            NSString* jsexe = [NSString stringWithFormat:@"%@('%@');",self.scanPickerFinishFunction,data];
            self.scanPickerFinishFunction = nil;
            [_webView performSelectorOnMainThread:@selector(stringByEvaluatingJavaScriptFromString:) withObject:jsexe waitUntilDone:NO];
            [_webView stringByEvaluatingJavaScriptFromString:jsexe];
        };
        [self presentViewController:rt animated:YES completion:nil];
        
    }
    else
    {
        //        [self scanBtnAction];
        SHOW_ALERT(@"闪电购提醒您", @"扫码功能需要升级到iOS7");
    }

}

//*** weixin bridge 分享朋友
-(void) respLinkContent:(NSString*) title description:(NSString*) description url:(NSString*) url
{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    [message setThumbImage:[UIImage imageNamed:@"275.png"]];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = url;
    
    message.mediaObject = ext;
    
//    GetMessageFromWXResp* resp = [[GetMessageFromWXResp alloc] init];
//    resp.message = message;
//    resp.bText = NO;
//    
//    [WXApi sendResp:resp];
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneSession;
    
    [WXApi sendReq:req];
}

//*** weixin bridge 分享朋友圈
-(void) respTimeLineLinkContent:(NSString*) title description:(NSString*) description url:(NSString*) url
{
    WXMediaMessage *message = [WXMediaMessage message];
    message.title = title;
    message.description = description;
    [message setThumbImage:[UIImage imageNamed:@"275.png"]];
    
    WXWebpageObject *ext = [WXWebpageObject object];
    ext.webpageUrl = url;
    
    message.mediaObject = ext;
    
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    req.bText = NO;
    req.message = message;
    req.scene = WXSceneTimeline;
    
    [WXApi sendReq:req];
}



@end
