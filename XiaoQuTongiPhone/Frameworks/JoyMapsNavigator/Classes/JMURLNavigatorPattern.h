//
//  JMURLNavigatorPattern.h
//  JoyMaps
//
//  Created by laijiandong on 13-5-12.
//  Copyright (c) 2013年 taobao inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JMNavigator.h"

@class SOCPattern;


@interface JMURLNavigatorPattern : NSObject

@property (nonatomic, assign) Class target;
@property (nonatomic, assign) SEL actionSelector;
@property (nonatomic, assign) JMNavigationMode mode;

@property (nonatomic, strong, readonly) SOCPattern *pattern;

- (id)initWithURL:(NSString *)URL target:(Class)target action:(SEL)action mode:(JMNavigationMode)mode;

- (id)createObjectFromURL:(NSString *)URL query:(NSDictionary*)query;

@end
