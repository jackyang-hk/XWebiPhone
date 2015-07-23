//
//  UIViewController+JMNavigator.h
//  JoyMaps
//
//  Created by laijiandong on 13-5-12.
//  Copyright (c) 2013年 taobao inc. All rights reserved.
//

#import <UIKit/UIKit.h>




@interface UIViewController (JMNavigator)

/**
 * The default initializer sent to view controllers opened through JMNavigator.
 */
- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query;

/**
 * The default data fetch back call.
 */
- (void) dataHasFetched:(JMURLAction*)action;

@end
