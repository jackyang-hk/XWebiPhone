//
//  JMNavigator.h
//  JoyMaps
//
//  Created by laijiandong on 13-5-12.
//  Copyright (c) 2013年 taobao inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define KEY_PRE_DATA_STATE @"pre_data_state_key"
#define KEY_PRE_DATA @"pre_data"

@protocol JMNavigatorDelegate;
@class JMURLMap;
@class JMURLAction;

typedef NS_ENUM(NSUInteger, JMNavigationMode) {
    JMNavigationModeNone,
    JMNavigationModeCreate,
    JMNavigationModeModal,
    JMNavigationModeExternal,
};

// used on view controller did created
typedef void (^JUControllerInitializationBlcok) (UIViewController *);

typedef void (^JUControllerInitializationDataFetchBlock) (JMURLAction * action);

FOUNDATION_EXTERN UIViewController* JMOpenURL(NSString *URL);

FOUNDATION_EXTERN UIViewController* JMOpenURLWithPreDataFetch(NSString *URL, JUControllerInitializationDataFetchBlock dataFetchBlock);

FOUNDATION_EXTERN UIViewController* JMOpenURLWithMode(NSString *URL, JMNavigationMode mode, BOOL animated);

FOUNDATION_EXTERN UIViewController* JMOpenURLWithBlock(NSString *URL, JUControllerInitializationBlcok block);

FOUNDATION_EXTERN UIViewController* JMOpenURLWithQuery(NSString *URL, NSDictionary *query, BOOL animated);
FOUNDATION_EXTERN UIViewController* JMOpenURLWithQueryAndBlock(NSString *URL, NSDictionary *query, BOOL animated, JUControllerInitializationBlcok block);


@interface JMNavigator : NSObject

@property (nonatomic, unsafe_unretained) id<JMNavigatorDelegate> delegate;
@property (nonatomic, strong) UIWindow *window;
@property (nonatomic, strong) UIViewController *rootViewController;

@property (nonatomic, strong, readonly) UIViewController *visibleViewController;

@property (nonatomic, strong, readonly) JMURLMap *URLMap;

+ (instancetype)sharedNavigator;

- (UIViewController *)openURL:(NSString *)URL;
- (UIViewController *)openURLs:(NSString *)URL,...;
- (UIViewController *)openURLAction:(JMURLAction *)URLAction;
- (UIViewController *)openURLAction:(JMURLAction *)URLAction block:(JUControllerInitializationBlcok)block;

- (UIViewController *)getViewControllerByURL:(NSString *)URL;


+ (BOOL)findAnyViewControllerInClasses:(NSArray *)classes target:(UIViewController **)target;

@end


@protocol JMNavigatorDelegate <NSObject>
@required

- (Class)navigator:(JMNavigator *)navigator
           navigationControllerClassForController:(UIViewController *)controller;

@end
