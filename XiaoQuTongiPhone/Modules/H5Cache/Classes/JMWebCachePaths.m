//
//  JMWebCachePaths.m
//  JoyMapsKit
//
//  Created by laijiandong on 12/24/14.
//  Copyright (c) 2014 laijiandong. All rights reserved.
//

//#import "JMCore.h"
#import "JMPaths.h"
#import "JMWebCachePaths.h"

#define JM_WEB_CACHE_PATH_NAME                       @"WebCaches"
#define JM_WEB_PAGE_CACHE_PATH_NAME                  JM_WEB_CACHE_PATH_NAME@"/CachedPages"
#define JM_WEB_INTERCEPTED_RESOURCE_CACHE_PATH_NAME  JM_WEB_CACHE_PATH_NAME@"/InterceptedResources"

@implementation JMWebCachePaths

+ (NSString *)webBundlePath {
    return JMPathForBundleResource(nil, @"JMWeb.bundle");
}

+ (NSString *)webBundleWithRelativePath:(NSString *)path {
    NSString *suffix = path ?: @"";
    NSString *target = [[[self class] webBundlePath] stringByAppendingPathComponent:suffix];
    
    return target;
}

+ (NSString *)webCachePath {
    static NSString *path = nil;
    if (path == nil) {
        path = JMPathForCachesResource(JM_WEB_CACHE_PATH_NAME);
    }
    
    return path;
}

+ (NSString *)webPageCachePath {
    static NSString *path = nil;
    if (path == nil) {
        path = JMPathForCachesResource(JM_WEB_PAGE_CACHE_PATH_NAME);
    }
    
    return path;
}

+ (NSString *)interceptWebResourceCachePath {
    static NSString *path = nil;
    if (path == nil) {
        path = JMPathForCachesResource(JM_WEB_INTERCEPTED_RESOURCE_CACHE_PATH_NAME);
    }
    
    return path;
}

@end
