//
//  JMWebResourceInterceptorSettings.m
//  JoyMapsKit
//
//  Created by laijiandong on 12/24/14.
//  Copyright (c) 2014 laijiandong. All rights reserved.
//

//#import "JMCore.h"
#import "JMWebResourceInterceptorSettings+Internal.h"
#import "JMWebCachePaths.h"

@implementation JMWebResourceInterceptorSettings

@synthesize version = _version;
@synthesize enabled = _enabled;
@synthesize extensions = _extensions;
@synthesize whitelist = _whitelist;
@synthesize blacklist = _blacklist;
@synthesize outwhitelist = _outwhitelist;

+ (instancetype)buildDefaultWebResourceInterceptorSettings {
    JMWebResourceInterceptorSettings *settings = nil;
    
    NSString *path = [JMWebCachePaths webBundleWithRelativePath:@"web_resource_pref.json"];
    NSData *data = [NSData dataWithContentsOfFile:path];
    
    if (data != nil) {
        NSError *error = nil;
        id obj = [NSJSONSerialization JSONObjectWithData:data
                                                 options:0
                                                   error:&error];
        if (error != nil) {
            NSLog(@"Deserialization web resource settings file did fail. \n%@", error);
        }
        
        if ([obj isKindOfClass:[NSDictionary class]]) {
            settings = [JMWebResourceInterceptorSettings modelWithJSON:(NSDictionary *)obj];
        }
    }
    
    //获取默认网络拦截规则
    NSString* result = [[NSUserDefaults standardUserDefaults] objectForKey:@"WebViewConfig"];
    NSDictionary* webViewConfig = nil;
    if (result != nil && ![result isEqualToString:@""]) {
       webViewConfig = [result objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
    }
    
    if (webViewConfig == nil || ![webViewConfig isKindOfClass:[NSDictionary class]]) {
        NSString *confPath = [[NSBundle mainBundle] pathForResource:@"DefaultWebViewConfig" ofType:@"settings" ];
        NSData *confData = [NSData dataWithContentsOfFile:confPath];
        NSString* confString = [[NSString alloc]initWithData:confData encoding:NSUTF8StringEncoding];
        if (confString != nil && ![confString isEqualToString:@""]) {
            webViewConfig = [confString objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode];
        }
    }
    if (webViewConfig != nil && [webViewConfig isKindOfClass:[NSDictionary class]]) {
        settings.outwhitelist = [webViewConfig objectForKey:@"interceptWhitelist"];
    }
    
    return settings;
}


+ (instancetype)defaultInterceptorSettings {
    return [[self class] buildDefaultWebResourceInterceptorSettings];
}

@end
