//
//  JMURLMap.h
//  JoyMaps
//
//  Created by laijiandong on 13-5-12.
//  Copyright (c) 2013年 taobao inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class JMURLNavigatorPattern;

@interface JMURLMap : NSObject

- (void)from:(NSString *)URL toController:(Class)clazz;
- (void)from:(NSString *)URL toController:(Class)clazz selector:(SEL)selector;

- (void)from:(NSString *)URL toModalController:(Class)clazz;
- (void)from:(NSString *)URL toModalController:(Class)clazz selector:(SEL)selector;

- (void)from:(NSString *)URL toExternalController:(Class)clazz;

- (UIViewController *)controllerForURL:(NSString *)URL query:(NSDictionary *)query
                               pattern:(JMURLNavigatorPattern **)outPattern;

@end
