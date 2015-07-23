//
//  JMURLMap.m
//  JoyMaps
//
//  Created by laijiandong on 13-5-12.
//  Copyright (c) 2013年 taobao inc. All rights reserved.
//

#import "JMURLMap.h"
#import "JMURLNavigatorPattern.h"


#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "JMURLMap requires ARC support."
#endif


@interface JMURLMap ()

@property (nonatomic, strong) NSMutableArray *objectPatterns;

@end


@implementation JMURLMap

@synthesize objectPatterns = objectPatterns_;

- (id)init {
    self = [super init];
    if (self) {
        objectPatterns_ = [[NSMutableArray alloc] init];
    }
    
    return self;
}

- (void)_addObjectPatternWithURL:(NSString *)URL target:(Class)target
                          action:(SEL)action mode:(JMNavigationMode)mode {
    JMURLNavigatorPattern *pattern = [[JMURLNavigatorPattern alloc] initWithURL:URL target:target
                                                                         action:action mode:mode];
    [objectPatterns_ addObject:pattern];
}

- (JMURLNavigatorPattern *)_matchObjectPattern:(NSString *)URL {
    JMURLNavigatorPattern *target = nil;
    
    // 对于 http\https 的协议，转换到 webview
    if ([URL hasPrefix:@"http://"] || [URL hasPrefix:@"https://"]) {
        URL = @"http://*";
    }
    
    if ([objectPatterns_ count] > 0) {
        for (JMURLNavigatorPattern *obj in objectPatterns_) {
            if ([obj.pattern stringMatches:URL]) {
                target = obj;
                
                break;
            }
        }
    }
    
    return target;
}

- (void)from:(NSString *)URL toController:(Class)clazz {
    [self _addObjectPatternWithURL:URL target:clazz action:NULL mode:JMNavigationModeCreate];
}

- (void)from:(NSString *)URL toController:(Class)clazz selector:(SEL)selector {
    [self _addObjectPatternWithURL:URL target:clazz action:selector mode:JMNavigationModeCreate];
}

- (void)from:(NSString *)URL toModalController:(Class)clazz {
    [self _addObjectPatternWithURL:URL target:clazz action:NULL mode:JMNavigationModeModal];
}

- (void)from:(NSString *)URL toModalController:(Class)clazz selector:(SEL)selector {
    [self _addObjectPatternWithURL:URL target:clazz action:selector mode:JMNavigationModeModal];
}

- (void)from:(NSString *)URL toExternalController:(Class)clazz {
    [self _addObjectPatternWithURL:URL target:clazz action:NULL mode:JMNavigationModeExternal];
}

- (UIViewController *)controllerForURL:(NSString *)URL query:(NSDictionary *)query pattern:(JMURLNavigatorPattern **)outPattern {
    UIViewController *vc = nil;
    JMURLNavigatorPattern *pattern = [self _matchObjectPattern:URL];
    if (pattern) {
        if (vc == nil) {
            vc = [pattern createObjectFromURL:URL query:query];
        }
        
        if (outPattern) {
            *outPattern = pattern;
        }
    }
    
    return vc;
}

@end
