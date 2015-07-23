//
//  Log.h
//  JHS
//
//  Created by zeha fu on 12-4-5.
//  Copyright (c) 2012年 ju.taobao.com/. All rights reserved.
//



#import "Foundation/Foundation.h"
#import "DDLog.h"
#import "Macros.h"

extern int ddLogLevel;

@interface JULog : NSObject

DECLARE_SINGLETON(JULog);

- (void) configuration;

@end
