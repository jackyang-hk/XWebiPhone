//
//  ViewControllerBase.h
//  XiaoQuTongiPhone
//
//  Created by redcat on 14-7-26.
//  Copyright (c) 2014年 redcat. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@class HUDActivityView;
@interface ViewControllerBase : UIViewController {
    BOOL                            _isUploading;
    HUDActivityView                *_hudUpLoadingView;
    __strong UIButton* _backButton;
    UILabel* _titleLabel;
    UIView* _navigationView;
    
    BOOL _noMore;
}

// resource connection,
@property (nonatomic, strong) NSURLConnection *internalConnection;
@property (nonatomic, strong) NSURLResponse *internalResponse;

// the css and js both tiny text body, so save it in memory directly,
// flush it to disk when all content returns from server.
@property (nonatomic, strong) NSMutableData *responseData;

@property (nonatomic, strong) TOPRequest* request;
@property (nonatomic) int currentPage;
@property (nonatomic) int pageSize;
@property (nonatomic) SEL finishAction;
@property (nonatomic) BOOL noBackButton;
@property (nonatomic) BOOL disableCache;
@property (nonatomic) BOOL noNavigation;



- (UIView*) setUpCustomNavigationBarForTitle:(NSString*) title compatibleForBackTitle:(NSString*) backTitle;

- (void) doCommonUploadWithUrl:(NSString *)url finish:(SEL)finishAction ;

- (void) doCommonUploadWithUrl:(NSString*)url param:(NSDictionary*)paramDics finish:(SEL) finishAction ;

- (NSString*) addQuery:(NSDictionary*) params toUrl:(NSString*) urlString  ;

- (NSString*)  queryFromDic:(NSDictionary*) paramDic ;

- (NSString*) reConstructCommonQuery:(NSString*) urlString ;

- (NSString*) constructUrl:(NSString*) originUrl withParam:(NSDictionary*) params ;

- (void) disableBackButton;

- (void) back ;

- (void)showLoadingView:(BOOL)show ;

- (void) showLoadingViewWithTitle:(NSString*) title;

- (void) showAutoHideViewWithTitle:(NSString*) title hideDuration:(float) duration ;

- (void) loadNextPageUrl:(NSString*) url;

- (void) loadNextPageUrlWithPreLoad:(NSString*) url;

+ (void) loadNextTabbarControllerWithGeneralPagesParams:(NSArray*) pages fromNavigationController:navigationController ;

- (void) loadNextTabbarControllerWithGeneralPagesParams:(NSArray*) pages ;

@end
