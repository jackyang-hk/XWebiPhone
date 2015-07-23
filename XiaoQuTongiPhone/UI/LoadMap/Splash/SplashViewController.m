//
//  SplashViewController.m
//  XiaoQuTongiPhone
//
//  Created by redcat on 14-7-23.
//  Copyright (c) 2014年 redcat. All rights reserved.
//

#import "SplashViewController.h"
#import "JULocationManager.h"
#import "WebViewControllerBase.h"
#import "MobClick.h"


@implementation SplashViewController

- (id) init {
    if (self = [super init]) {
//        [self getBridgeData];
        _initFinished = false;
    }
    return self;
}

- (void) loadView {
    UIView* view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view = view;
    self.navigationController.navigationBar.hidden = YES;
    
    
    UIImageView* imageView = [[UIImageView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    if (iPhone5) {
        imageView.image = [UIImage imageNamed:@"Default-iOS7-568h@2x.png"];
    } else {
        imageView.image = [UIImage imageNamed:@"Default@2x.png"];
    }
    [self.view addSubview:imageView];
    
    UIScreen* mainScreen = [UIScreen mainScreen];
    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(0, 0, mainScreen.bounds.size.width, mainScreen.bounds.size.height)];
    [button addTarget:self action:@selector(checkNext) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    self.indicatorView = [[UIActivityIndicatorView alloc]init];
    self.indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhite;
    [self.view addSubview:self.indicatorView];
    self.indicatorView.center = self.view.center;
    [self.indicatorView startAnimating];
    
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
//    [JULocationManager startUpLocate];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear: animated];
    [MobClick beginLogPageView:@"Splash"];
    
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [MobClick endLogPageView:@"Splash"];
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    _initFinished = true;
    
    [self checkNext];
}

- (void) checkNext {
    [self performSelector:@selector(loadFromSaveData) withObject:nil afterDelay:0.1];
    [self performSelector:@selector(getBridgeData) withObject:nil afterDelay:4];
}

- (void) delayFinish {
    RDAppDelegate* delegate = (RDAppDelegate*)[UIApplication sharedApplication].delegate;
    delegate.finishInitProgress = YES;
}

- (void) doNext {
    if (_initFinished) {
        _initFinished = false;
        NSString* action = [self.nextActionQuery objectForKey:@"action"];
        NSDictionary* params = [self.nextActionQuery  objectForKey:@"params"];
        if ([action isEqualToString:@"tabPage"]) {
            NSArray* urlMaps = [params objectForKey:@"pages"];
            if ([urlMaps count] > 1) {
                [self loadNextTabbarControllerWithGeneralPagesParams:urlMaps];
            } else {
                [self loadDefaultIndex];
            }
        } else if ([action isEqualToString:@"page"]) {
            NSString* url = [params objectForKey:@"url"];
            if ([params isKindOfClass:[NSDictionary class]] && url) {
                [self loadNextPageUrlWithPreLoad:url];
            } else {
                [self loadDefaultIndex];
            }
        } else {
            [self loadDefaultIndex];
        }
        
        NSString* appkey = [self.nextActionQuery objectForKey:@"appKey"];
        NSString* secretCode = [self.nextActionQuery objectForKey:@"appSecret"];
        [[TBTop sharedInstance] setAppKey:appkey];
        [[TBTop sharedInstance] setSecretCode:secretCode];
        
        self.nextActionQuery = nil;
        [self.indicatorView stopAnimating];
        
        [self performSelector:@selector(delayFinish) withObject:nil afterDelay:0.5];

    }
}

- (void) getBridgeData {
    _initFinished = true;
    [self doCommonUploadWithUrl:@"http://www.52shangou.com/o2o/app_config/buyerConfig.php" finish:@selector(requestDidFinished:)];
}

- (void) loadFromSaveData {
    if (_initFinished) {
        NSString* result = [[NSUserDefaults standardUserDefaults] objectForKey:@"oldActionQuery"];
        if (result != nil && ![result isEqualToString:@""]) {
            self.nextActionQuery = [result objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
        }
    }
    if (self.nextActionQuery == nil) {
        NSString *confPath = [[NSBundle mainBundle] pathForResource:@"DefaultInit" ofType:@"settings" ];
        NSData *confData = [NSData dataWithContentsOfFile:confPath];
        NSString* confString = [[NSString alloc]initWithData:confData encoding:NSUTF8StringEncoding];
        if (confString != nil && ![confString isEqualToString:@""]) {
            self.nextActionQuery = [confString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
        }
    }
    [self doNext];
}

- (void) requestDidFinished:(NSString*) resultString {
    id result = [resultString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
    [[NSUserDefaults standardUserDefaults] setObject:resultString forKey:@"oldActionQuery"];
    if ([result isKindOfClass:[NSDictionary class]]) {
        self.nextActionQuery = result;
    }
    
    [self doCommonUploadWithUrl:@"http://cdn.52shangou.com/buyer/1.0.1/build/online.json" finish:@selector(webConfigDidFinished:)];
}

- (void) webConfigDidFinished:(NSString*) resultString {
    id result = [resultString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
    if ([result isKindOfClass:[NSDictionary class]]) {
        [[NSUserDefaults standardUserDefaults] setObject:resultString forKey:@"WebViewConfig"];
    }
}

- (void) loadDefaultIndex {
    NSString* indexURlString = @"http://www.52shangou.com/o2o/index.php";
    JMOpenURLWithPreDataFetch([NSString stringWithFormat:@"%@?url=%@",CommonWebViewControllerURL,[indexURlString stringByURLEncodingStringParameter]], ^(JMURLAction* action){
        if ([indexURlString rangeOfString:@"usePreload=true"].location != NSNotFound) {
            TOPRequest* request = [[TOPRequest alloc]initWithAbsoluteUrl:[self reConstructCommonQuery:indexURlString]];
            [request sendSynchronousRequest];
            //        NSString* data = [NSString stringWithContentsOfURL:[NSURL URLWithString:[self reConstructCommonQuery:url.absoluteString]] encoding:NSUTF8StringEncoding error:nil];
            NSString* data = request.responseString;
            if (data) {
                [action.query setValue:data forKey:KEY_PRE_DATA];
            }
        }
    });
}

@end
