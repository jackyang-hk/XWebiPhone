//
//  JMNavigator.m
//  JoyMaps
//
//  Created by laijiandong on 13-5-12.
//  Copyright (c) 2013年 taobao inc. All rights reserved.
//

#import "JMNavigator.h"
#import "JMURLAction.h"
#import "JMURLMap.h"
#import "JMURLNavigatorPattern.h"
#import "UIViewController+JMNavigator.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "JMNavigator requires ARC support."
#endif


@interface JMNavigator ()

@property (nonatomic, strong) JMURLMap *URLMap;

@end

@implementation JMNavigator

@synthesize delegate = delegate_;
@synthesize window = window_;
@synthesize rootViewController = rootViewController_;

@synthesize URLMap = URLMap_;

- (id)init {
    self = [super init];
    if (self) {
        URLMap_ = [[JMURLMap alloc] init];
    }
    
    return self;
}

+ (instancetype)sharedNavigator {
    static JMNavigator *navigator = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        navigator = [[JMNavigator alloc] init];
    });
    
    return navigator;
}

- (UIViewController *)presentedViewControllerIn:(UIViewController *)vc {
    static NSInteger flags = 0x00;
    if (flags == 0x00) {
        flags |= 0x0F;
        if ([vc respondsToSelector:@selector(presentedViewController)]) {
            flags |= 0xF0;
        }
    }
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    
    UIViewController *target = (flags & 0xF0) ? vc.presentedViewController : vc.modalViewController;
    
#pragma clang diagnostic pop
    
    return target;
}

- (UIViewController *)visibleViewController {
    UIViewController *tvc = rootViewController_;
    UIViewController *temp = nil;
    while (YES) {
        temp = nil;
        if ([tvc isKindOfClass:[UINavigationController class]]) {
            temp = ((UINavigationController *)tvc).visibleViewController;
            
        } else if ([tvc isKindOfClass:[UITabBarController class]]) {
            temp = ((UITabBarController *)tvc).selectedViewController;
            
        } else if ([self presentedViewControllerIn:tvc] != nil) {
            temp = [self presentedViewControllerIn:tvc];
        }
        
        if (temp != nil) {
            tvc = temp;
            
        } else {
            break;
        }
    }
    
    return tvc;
}

- (UIViewController *)frontViewControllerForController:(UIViewController *)controller {
    if ([controller isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController*)controller;
        
        if (tabBarController.selectedViewController) {
            controller = tabBarController.selectedViewController;
            
        } else {
            controller = [tabBarController.viewControllers objectAtIndex:0];
        }
        
    } else if ([controller isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navController = (UINavigationController*)controller;
        controller = navController.topViewController;
    }
    
    UIViewController *mvc = [self presentedViewControllerIn:controller];
    if (mvc != nil) {
        return [self frontViewControllerForController:mvc];
        
    } else {
        return controller;
    }
}

- (UINavigationController*)frontNavigationController {
    UIViewController *rvc = rootViewController_;
    UINavigationController *target = nil;
    
    if ([rvc isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController*)rootViewController_;
        
        UIViewController *temp = nil;
        if (tabBarController.selectedViewController != nil) {
            temp = tabBarController.selectedViewController;
            
        } else {
            temp = [tabBarController.viewControllers objectAtIndex:0];
        }
        
        if (temp != nil && [temp isKindOfClass:[UINavigationController class]]) {
            target = (UINavigationController *)temp;
        }
        
    } else if ([rvc isKindOfClass:[UINavigationController class]]) {
        target = (UINavigationController *)rvc;
    }
    
    return target;
}


- (UIViewController*)frontViewController {
    UINavigationController *nc = [self frontNavigationController];
    if (nc != nil) {
        return [self frontViewControllerForController:nc];
        
    } else {
        return [self frontViewControllerForController:rootViewController_];
    }
}

- (Class)windowClass {
    return [UIWindow class];
}

- (Class)navigationControllerClassForController:(UIViewController *)controller {
    if (delegate_ != nil) {
        return [delegate_ navigator:self navigationControllerClassForController:controller];
    }
    
    return [UINavigationController class];
}

- (UIWindow *)window {
    if (window_ == nil) {
        UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
        if (keyWindow != nil) {
            self.window = keyWindow;
            
        } else {
            window_ = [[[self windowClass] alloc] initWithFrame:[UIScreen mainScreen].bounds];
            window_.backgroundColor = [UIColor whiteColor];
            
            [window_ makeKeyAndVisible];
        }
    }
    
    return window_;
}

- (void)setRootViewController:(UIViewController *)controller {
    if (rootViewController_ != controller) {
        rootViewController_ = controller;
        
        // make sure create new window when it is nil
        UIWindow *window = [self window];
        window.rootViewController = rootViewController_;
    }
}

- (UIViewController *)parentForController:(UIViewController *)controller {
    if (controller == rootViewController_) {
        return nil;
        
    } else {
        UIViewController *parent = [self visibleViewController];
        if (parent != controller) {
            return parent;
            
        } else {
            return nil;
        }
    }
}

- (BOOL)presentModalController:(UIViewController *)controller
              parentController:(UIViewController *)parentController
                      animated:(BOOL)animated {
    
    if ([controller isKindOfClass:[UINavigationController class]]) {
        [parentController presentViewController:controller animated:animated completion:nil];
        
    } else {
        Class clazz = [self navigationControllerClassForController:controller];
        UINavigationController *nc = [[clazz alloc] initWithRootViewController:controller];
        [parentController presentViewController:nc animated:animated completion:nil];
    }
    
    return YES;
}

// 页面的跳转方式 参数暴露
- (BOOL)presentController:(UIViewController *)controller withPattern:(JMURLNavigatorPattern *)pattern action:(JMURLAction *)action mode:(JMNavigationMode) mode{
    
    BOOL presented = NO;
    if (nil != controller) {
        UIViewController *tvc = [self visibleViewController];
        switch (mode) {
            case JMNavigationModeNone:
                if (tvc.navigationController != nil) {
                    // url 里未设置时，采用页面注册时的跳转方式
                    
                    if (pattern.mode == JMNavigationModeModal) {
                        presented = [self presentModalController:controller parentController:tvc animated:action.animated];
                    }else if(pattern.mode == JMNavigationModeExternal){
                        presented = YES;
                        [self.window addSubview:controller.view];
                        [self.window bringSubviewToFront:controller.view];
                        controller.view.frame = self.window.bounds;
                    }else {
                        presented = YES;
                        [tvc.navigationController pushViewController:controller animated:action.animated];
                    }
                }
                break;
                
            case JMNavigationModeCreate:
                if (tvc.navigationController != nil) {
                    presented = YES;
                    [tvc.navigationController pushViewController:controller animated:action.animated];
                }
                break;
                
            case JMNavigationModeModal:
                presented = [self presentModalController:controller parentController:tvc animated:action.animated];
                break;
                
            case JMNavigationModeExternal:
                presented = YES;
                [self.window addSubview:controller.view];
                [self.window bringSubviewToFront:controller.view];
                controller.view.frame = self.window.bounds;
                break;
                
            default:
                if (tvc.navigationController != nil) {
                    presented = YES;
                    [tvc.navigationController pushViewController:controller animated:action.animated];
                }
                break;
        }
        
//        if (pattern.mode == JMNavigationModeModal) {
//            presented = [self presentModalController:controller parentController:tvc animated:action.animated];
//            
//        } else {
//            if (tvc.navigationController != nil) {
//                presented = YES;
//                [tvc.navigationController pushViewController:controller animated:action.animated];
//            }
//        }
    }
    
    return presented;
}

- (UIViewController *)openURL:(NSString *)URL {
    JMURLAction *action = [[JMURLAction actionWithURLPath:URL] applyAnimated:YES];
    return [self openURLAction:action];
}

- (UIViewController *)openURLs:(NSString*)URL,... {
    UIViewController *vc = nil;
    va_list ap;
    va_start(ap, URL);
    while (URL) {
        vc = [self openURLAction:[JMURLAction actionWithURLPath:URL]];
        URL = va_arg(ap, id);
    }
    va_end(ap);
    
    return vc;
}

- (UIViewController *)openURLAction:(JMURLAction *)action {
    return [self openURLAction:action block:nil];
}

- (UIViewController *)openURLAction:(JMURLAction *)action block:(JUControllerInitializationBlcok)block {
//    if (action == nil || action.urlPath == nil) {
//        return nil;
//    }
//    
//    JMURLNavigatorPattern *pattern = nil;
//    UIViewController *vc = [self viewControllerForURL:action.urlPath query:action.query pattern:&pattern];
//    if (vc != nil) {
//        if (block != nil) {
//            block(vc);
//        }
//        
//        [self presentController:vc withPattern:pattern action:action];
//    }
//    
//    return vc;
    return [self openURLAction:action block:block mode:JMNavigationModeNone];
}

- (UIViewController *)openURLAction:(JMURLAction *)action dataFetchBlock:(JUControllerInitializationDataFetchBlock)dataFetchBlock {
    //    if (action == nil || action.urlPath == nil) {
    //        return nil;
    //    }
    //
    //    JMURLNavigatorPattern *pattern = nil;
    //    UIViewController *vc = [self viewControllerForURL:action.urlPath query:action.query pattern:&pattern];
    //    if (vc != nil) {
    //        if (block != nil) {
    //            block(vc);
    //        }
    //
    //        [self presentController:vc withPattern:pattern action:action];
    //    }
    //
    //    return vc;
    return [self openURLAction:action block:nil dataFetchBlock:dataFetchBlock mode:JMNavigationModeNone];
}

// 页面的跳转方式 参数暴露
- (UIViewController *)openURLAction:(JMURLAction *)outAction block:(JUControllerInitializationBlcok)block dataFetchBlock:(JUControllerInitializationDataFetchBlock)dataFetchBlock mode:(JMNavigationMode)mode{
    if (outAction == nil || outAction.urlPath == nil) {
        return nil;
    }
    __block JMURLAction* action = outAction;
    
    static NSMutableDictionary* preLoadStock = nil;
    //增加预加载
    if (dataFetchBlock != nil) {
        if (preLoadStock == nil) {
            preLoadStock = [[NSMutableDictionary alloc]init];
        }
        
        //保证query不会空
        if (action.query == nil) {
            action.query = @{KEY_PRE_DATA_STATE:@"true"};
        } else {
            [action.query setValue:@"start" forKey:KEY_PRE_DATA_STATE];
        }
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
            
            dataFetchBlock(action);
            [action.query setValue:@"finishloading" forKey:KEY_PRE_DATA_STATE];
            
            UIViewController* vc = [preLoadStock objectForKey:[action description]];
            NSString* state = [action.query objectForKey:KEY_PRE_DATA_STATE];
            //back call to vc
            if (vc && [vc respondsToSelector:@selector(dataHasFetched:)] && [state isEqualToString:@"finishloading"]) {
                [vc performSelector:@selector(dataHasFetched:) withObject:action];
                [action.query setValue:@"finishcall" forKey:KEY_PRE_DATA_STATE];
                [preLoadStock removeObjectForKey:[action description]];
            }
            
        });
    }
    
    JMURLNavigatorPattern *pattern = nil;
    UIViewController *vc = [self viewControllerForURL:action.urlPath query:action.query pattern:&pattern];
    
    //preloaddata记录vc
    if (dataFetchBlock) {
        [preLoadStock setObject:vc forKey:[action description]];
        
        UIViewController* vc = [preLoadStock objectForKey:[action description]];
        NSString* state = [action.query objectForKey:KEY_PRE_DATA_STATE];
        //back call to vc
        if (vc && [vc respondsToSelector:@selector(dataHasFetched:)] && [state isEqualToString:@"finishloading"]) {
            [vc performSelector:@selector(dataHasFetched:) withObject:action];
            [action.query setValue:@"finishcall" forKey:KEY_PRE_DATA_STATE];
            [preLoadStock removeObjectForKey:[action description]];
        }
    }
    
    if (vc != nil) {
        if (block != nil) {
            block(vc);
        }
        
        [self presentController:vc withPattern:pattern action:action mode:mode];
    }
    
    return vc;
}


// 页面的跳转方式 参数暴露
- (UIViewController *)openURLAction:(JMURLAction *)action block:(JUControllerInitializationBlcok)block mode:(JMNavigationMode)mode{
    if (action == nil || action.urlPath == nil) {
        return nil;
    }

    JMURLNavigatorPattern *pattern = nil;
    UIViewController *vc = [self viewControllerForURL:action.urlPath query:action.query pattern:&pattern];
    if (vc != nil) {
        if (block != nil) {
            block(vc);
        }
        
        [self presentController:vc withPattern:pattern action:action mode:mode];
    }
    
    return vc;
}

//
- (UIViewController *)getViewControllerByURL:(NSString *)URL {
    JMURLAction *action = [[JMURLAction actionWithURLPath:URL] applyAnimated:YES];
    return [self viewControllerForURL:action.urlPath query:action.query pattern:nil];
}

- (UIViewController *)viewControllerForURL:(NSString *)URL {
    return [self viewControllerForURL:URL query:nil pattern:nil];
}

- (UIViewController *)viewControllerForURL:(NSString *)URL query:(NSDictionary *)query {
    return [self viewControllerForURL:URL query:query pattern:nil];
}

- (UIViewController *)viewControllerForURL:(NSString *)URL
                                     query:(NSDictionary *)query
                                   pattern:(JMURLNavigatorPattern **)pattern {
    return [URLMap_ controllerForURL:URL query:query pattern:pattern];
}


//////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark utility methods

+ (BOOL)findAnyViewControllerInClasses:(NSArray *)classes target:(UIViewController **)target {
    __block BOOL found = NO;
    __block UIViewController *t = nil;
    
    UIViewController *rvc = [JMNavigator sharedNavigator].rootViewController;
    [[self class] searchClasses:classes
               inViewController:rvc
                completionBlock:^(UIViewController *vc) {
                    found = vc != nil;
                    t = vc;
                }];
    
    if (found && target != NULL) {
        *target = t;
    }
    
    return found;
}

+ (void)searchClasses:(NSArray *)classes
     inViewController:(UIViewController *)vc
      completionBlock:(void (^)(UIViewController *))completionBlock {
    
    if ([vc isKindOfClass:[UINavigationController class]]) {
        NSUInteger index = 0;
        NSArray *viewControllers = ((UINavigationController *)vc).viewControllers;
        if ([[self class] canMatchAnyTargets:classes inViewControllers:viewControllers atIndex:&index]) {
            completionBlock(viewControllers[index]);
            
        } else {
            UIViewController *tvc = ((UINavigationController *)vc).topViewController;
            UIViewController *mvc = [[JMNavigator sharedNavigator] presentedViewControllerIn:tvc];
            if (mvc != nil) {
                [self searchClasses:classes inViewController:mvc completionBlock:completionBlock];
            }
        }
        
    } else if ([vc isKindOfClass:[UITabBarController class]]) {
        NSUInteger index = 0;
        NSArray *viewControllers = ((UITabBarController *)vc).viewControllers;
        if ([[self class] canMatchAnyTargets:classes inViewControllers:viewControllers atIndex:&index]) {
            completionBlock(viewControllers[index]);
            
        } else {
            UIViewController *svc = ((UITabBarController *)vc).selectedViewController;
            [self searchClasses:classes inViewController:svc completionBlock:completionBlock];
        }
        
    } else {
        if ([[self class] canMatchAnyTargets:classes withViewController:vc]) {
            completionBlock(vc);
        }
    }
}

+ (BOOL)canMatchAnyTargets:(NSArray *)classes withViewController:(UIViewController *)vc {
    BOOL found = NO;
    for (Class clazz in classes) {
        if ([vc class] == clazz) {
            found = YES;
            break;
        }
    }
    
    return found;
}

+ (BOOL)canMatchAnyTargets:(NSArray *)classes inViewControllers:(NSArray *)viewControllers atIndex:(NSUInteger *)atIndex {
    BOOL found = NO;
    NSUInteger index = 0;
    
    for (UIViewController *vc in viewControllers) {
        Class vcClazz = [vc class];
        for (Class clazz in classes) {
            if (clazz == vcClazz) {
                found = YES;
                break;
            }
        }
        
        if (found) {
            if (atIndex != NULL) {
                *atIndex = index;
            }
            
            break;
        }
        
        index++;
    }
    
    return found;
}

- (void)dealloc {
    delegate_ = nil;
}

@end


//////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -
#pragma mark utility methods

UIViewController* JMOpenURL(NSString *URL) {
    return JMOpenURLWithBlock(URL, nil);
}

UIViewController* JMOpenURLWithPreDataFetch(NSString *URL, JUControllerInitializationDataFetchBlock dataFetchBlock) {
    JMURLAction *action = [[JMURLAction actionWithURLPath:URL] applyAnimated:YES];
    return [[JMNavigator sharedNavigator] openURLAction:action dataFetchBlock:dataFetchBlock];
}

UIViewController* JMOpenURLWithMode(NSString *URL, JMNavigationMode mode, BOOL animated) {
    JMURLAction *action = [[JMURLAction actionWithURLPath:URL] applyAnimated:animated];
    return [[JMNavigator sharedNavigator] openURLAction:action block:nil mode:mode];
}

UIViewController* JMOpenURLWithBlock(NSString *URL, JUControllerInitializationBlcok block) {
    JMURLAction *action = [[JMURLAction actionWithURLPath:URL] applyAnimated:YES];
    return [[JMNavigator sharedNavigator] openURLAction:action block:block];
}

UIViewController* JMOpenURLWithQuery(NSString *URL, NSDictionary *query, BOOL animated) {
    return JMOpenURLWithQueryAndBlock(URL, query, animated, nil);
}

UIViewController* JMOpenURLWithQueryAndBlock(NSString *URL, NSDictionary *query,
                                             BOOL animated, JUControllerInitializationBlcok block) {
    JMURLAction *action = [[[JMURLAction actionWithURLPath:URL] applyAnimated:animated] applyQuery:query];
    return [[JMNavigator sharedNavigator] openURLAction:action block:block];
}
