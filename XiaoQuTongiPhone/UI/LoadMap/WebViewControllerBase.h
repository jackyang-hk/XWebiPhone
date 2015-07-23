//
//  WebViewControllerBase.h
//  XiaoQuTongiPhone
//
//  Created by redcat on 14-8-3.
//  Copyright (c) 2014年 redcat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EGORefreshTableHeaderView.h"
#import <AVFoundation/AVFoundation.h>
#import <BaiduMapAPI/BMapKit.h>

@class JSBadgeView;
@interface WebViewControllerBase : ViewControllerBase <UIWebViewDelegate,UIScrollViewDelegate,EGORefreshTableHeaderDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,AVCaptureMetadataOutputObjectsDelegate,BMKLocationServiceDelegate>{
    UIWebView* _webView;
    EGORefreshTableHeaderView* _refreshTableHeaderView;
    
    UIButton* _rightButton;
    JSBadgeView *badgeView;
    UIImageView* _trImageView;
    UIImageView* _titleImageView;
    
    BOOL _isloading;
    BOOL _isPreloading;
    BOOL _isNativeBridging;
    
    NSString* displayReloadCallback;
    

    BMKLocationService* _locService;

}
@property (nonatomic, strong) NSString* originUrl;
@property (nonatomic, strong) NSString* alipayCallBackUrl;
@property (nonatomic, strong) NSString* bmLocationCallBackUrl;
@property (nonatomic, strong) NSString* weixinPayCallBackUrl;
@property (nonatomic, retain) NSString* rightButtonFunction;
@property (nonatomic, retain) NSString* imagePickerFinishFunction;
@property (nonatomic, retain) NSString* scanPickerFinishFunction;
@property (nonatomic, retain) NSString* htmlData;
@property (nonatomic, retain) NSString* trOpen;;
@property (nonatomic) BOOL disableRefreshHeaderView;
@property (nonatomic) BOOL isInTabbarController;
@property (nonatomic) BOOL needDidAppearReload;

@property (nonatomic) NSTimeInterval startTime;
@property (nonatomic) NSTimeInterval endTime;

@end
