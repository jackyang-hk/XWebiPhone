//
//  JMURLNavigatorPattern.m
//  JoyMaps
//
//  Created by laijiandong on 13-5-12.
//  Copyright (c) 2013年 taobao inc. All rights reserved.
//

#import "JMURLNavigatorPattern.h"
#import "UIViewController+JMNavigator.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "JMURLNavigatorPattern requires ARC support."
#endif


@implementation JMURLNavigatorPattern

@synthesize target = target_;
@synthesize actionSelector = actionSelector_;
@synthesize mode = mode_;
@synthesize pattern = pattern_;

- (id)initWithURL:(NSString *)URL target:(Class)target action:(SEL)action mode:(JMNavigationMode)mode {
    self = [super init];
    if (self) {
        target_ = target;
        actionSelector_ = action;
        mode_ = mode;
        
        pattern_ = [[SOCPattern alloc] initWithString:URL];
    }
    
    return self;
}

/**
 * 默认调用 initWithNavigatorURL 初始化方法
 * initWithNavigatorURL 未实现时，父类会调用 init 方法
 * init 方法 会自动调用 init
 *
 * modify by gulun
 **/

- (id)_invoke:(Class)clazz withURL:(NSString *)URL query:(NSDictionary *)query {
    __strong id obj = nil;
    SEL action = NULL;
    
    NSURL *url = [NSURL URLWithString:URL];
    
    // always use initWithNavigatorURL:query: as default initialization method
    action = NSSelectorFromString(@"initWithNavigatorURL:query:");
    
    id target = [clazz alloc];
    NSMethodSignature *signature = [target methodSignatureForSelector:action];
    if (signature != nil) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:target];
        [invocation setSelector:action];
        
        [invocation setArgument:&url atIndex:2];
        [invocation setArgument:&query atIndex:3];
        
        [invocation invoke];
        
        if (signature.methodReturnLength) {
            void *pointer = NULL;
            [invocation getReturnValue:&pointer];
            obj = (__bridge id)pointer;
        }
    }
    
    return obj;
}

- (id)createObjectFromURL:(NSString *)URL query:(NSDictionary*)query {
    return [self _invoke:target_ withURL:URL query:query];
}

- (void)dealloc {
    target_ = Nil;
    actionSelector_ = NULL;
}

@end
