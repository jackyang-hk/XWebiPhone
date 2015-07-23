//
//  JMURLAction.h
//  JoyMaps
//
//  Created by laijiandong on 13-5-12.
//  Copyright (c) 2013年 taobao inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JMURLAction : NSObject <NSCopying>

@property (nonatomic, strong) NSString *urlPath;
@property (nonatomic, strong) NSDictionary *query;
@property (nonatomic, assign) BOOL animated;

- (id)initWithURLPath:(NSString *)urlPath;

+ (instancetype)actionWithURLPath:(NSString*)urlPath;

- (JMURLAction *)applyQuery:(NSDictionary*)query;
- (JMURLAction *)applyAnimated:(BOOL)animated;

@end
