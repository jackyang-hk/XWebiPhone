//
//  JMWebResourceInterceptor.m
//  JoyMapsKit
//
//  Created by laijiandong on 12/24/14.
//  Copyright (c) 2014 laijiandong. All rights reserved.
//

//#import "JMCore.h"

#import "JMWebResourceInterceptor.h"
#import "JMWebResourceURLProtocol.h"
#import "JMWebResourceCache.h"

static JMWebResourceInterceptor *gWebResourceInterceptor = nil;

@interface JMWebResourceInterceptor ()

@property (nonatomic, strong) id<JMWebResourceInterceptorSettings> settings;
@property (nonatomic, strong) JMWebResourceCache *cache;

// external did update interceptor settings
@property (atomic, assign) BOOL didUpdateInceptorSettings;

@end

@implementation JMWebResourceInterceptor {
 @private
    struct {
        unsigned int didRegisterURLProtocol:1; // did register custom url protocol
    }_interceptorFlags;
}

- (id)init {
    self = [super init];
    if (self) {
        [self commonInit];
    }
    
    return self;
}

+ (instancetype)globalWebResourceInterceptor {
    @synchronized([self class]) {
        if (gWebResourceInterceptor == nil) {
            gWebResourceInterceptor = [[JMWebResourceInterceptor alloc] init];
        }
    }
    
    return gWebResourceInterceptor;
}

+ (void)setGlobalWebResourceInterceptor:(JMWebResourceInterceptor *)interceptor {
    @synchronized([self class]) {
        if (gWebResourceInterceptor != interceptor) {
            gWebResourceInterceptor = interceptor;
        }
    }
}


//////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark private methods

- (void)commonInit {
    // update flags
    _interceptorFlags.didRegisterURLProtocol = 0;
    self.didUpdateInceptorSettings = NO;
    
    // create web cache
    _cache = [[JMWebResourceCache alloc] init];
}

- (void)registerWebResourceInterceptorURLProtocol {
    if (_settings.enabled
        && !_interceptorFlags.didRegisterURLProtocol) {
        _interceptorFlags.didRegisterURLProtocol = 1; // update flags
        
        // register url protocol handle class
        [NSURLProtocol registerClass:[JMWebResourceURLProtocol class]];
    }
}

- (void)unregisterWebResourceInterceptorURLProtocol {
    if (_interceptorFlags.didRegisterURLProtocol) {
        _interceptorFlags.didRegisterURLProtocol = 0; // update flags
        
        // unregister url protocol handle class
        [NSURLProtocol unregisterClass:[JMWebResourceURLProtocol class]];
    }
}

- (void)notifyDidChangeInterceptorSettings {
    if (_settings != nil && _settings.enabled) {
        // open web resource interceptor
        [self registerWebResourceInterceptorURLProtocol];
        
    } else {
        // close web resource interceptor
        [self unregisterWebResourceInterceptorURLProtocol];
    }
}


//////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark public methods

- (void)setupDefaultWebResourceInterceptorSettings {
    id<JMWebResourceInterceptorSettings> settings =
        [JMWebResourceInterceptorSettings defaultInterceptorSettings];
    
    // update with default interceptor settings
    [self updateInterceptorSettings:settings isDefaultSettings:YES];
}

// NOTICE: Not thread safety
- (BOOL)isCacheWhitelistHost:(NSString *)host {
    if (host == nil || [host length] == 0) return NO;
    
    BOOL isValid = NO;
    
    // for performance issue, not synchronized thread to do whitelist checking.
    NSArray *whitelist = _settings.whitelist;
    if (whitelist != nil) {
        for (NSString *domain in whitelist) {
            // check the domain or sub domain has same suffix
            if (NSNotFound != [host rangeOfString:domain].location) {
                isValid = YES;
                
                break;
            }
        }
    }
    
    return isValid;
}

// NOTICE: Not thread safety
- (BOOL)isGlobalNetworkOutWhitelistHost:(NSString *)host {
    if (host == nil || [host length] == 0) return NO;
    
    // 51xianqu.com 和 52shangou.com 默认匹配
    if (NSNotFound != [host rangeOfString:@"52shangou.com"].location) {
        return YES;
    } else if (NSNotFound != [host rangeOfString:@"51xianqu.com"].location) {
        return YES;
    }

    
    BOOL isValid = NO;
    
    // for performance issue, not synchronized thread to do whitelist checking.
    NSArray *whitelist = _settings.outwhitelist;
    if (whitelist != nil) {
        if ([whitelist count] < 2) {
            //小于2默认判定文件有问题，默认有效
            return YES;
        }
        for (NSString *domain in whitelist) {
            // check the domain or sub domain has same suffix
            if (NSNotFound != [host rangeOfString:domain].location) {
                isValid = YES;
                
                break;
            }
        }
    } else {
        //配置文件为空，默认有效
        isValid = YES;
    }
    
    return isValid;
}

// NOTICE: Not thread safety
- (BOOL)isBlacklistWithRequestPath:(NSString *)path {
    if (path == nil || [path length] == 0) return NO;
    
    BOOL exists = NO;
    
    // for performance issue, not synchronized thread to do blacklist checking.
    NSArray *blacklist = _settings.blacklist;
    if (blacklist != nil) {
        for (NSString *domain in blacklist) {
            // check the domain or sub domain has same suffix
            if (NSNotFound != [path rangeOfString:domain].location) {
                exists = YES;
                
                break;
            }
        }
    }
    
    return exists;
}

// NOTICE: Not thread safety
- (BOOL)isSupportedPathExtension:(NSString *)extension {
    if (extension == nil || [extension length] == 0) return NO;
    
    BOOL isSupported = NO;
    if (_settings.extensions
        && [_settings.extensions rangeOfString:extension].location != NSNotFound) {
        
        isSupported = YES;
    }
    
    return isSupported;
}

- (void)updateInterceptorSettings:(id<JMWebResourceInterceptorSettings>)settings {
    [self updateInterceptorSettings:settings isDefaultSettings:NO];
}

- (void)updateInterceptorSettings:(id<JMWebResourceInterceptorSettings>)settings
               isDefaultSettings:(BOOL)isDefaultSettings {
    
    // update flags
    if (!isDefaultSettings && !self.didUpdateInceptorSettings) {
        self.didUpdateInceptorSettings = YES;
    }
    
    @synchronized(self) {
        _settings = settings; // update interceptor settings
    }
    
    // notify did change interceptor settings
    [self notifyDidChangeInterceptorSettings];
}

@end
