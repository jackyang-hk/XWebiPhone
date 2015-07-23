//
//  Log.m
//  JHS
//
//  Created by zeha fu on 12-4-5.
//  Copyright (c) 2012年 ju.taobao.com/. All rights reserved.
//

#import "JULog.h"
#import "DDASLLogger.h"
#import "DDTTYLogger.h"
#import "DDFileLogger.h"

/*
 If you set the log level to LOG_LEVEL_ERROR, then you will only see DDLogError statements.
 If you set the log level to LOG_LEVEL_WARN, then you will only see DDLogError and DDLogWarn statements.
 If you set the log level to LOG_LEVEL_INFO, you'll see Error, Warn and Info statements.
 If you set the log level to LOG_LEVEL_VERBOSE, you'll see all DDLog statements.
 If you set the log level to LOG_LEVEL_OFF, you won't see any DDLog statements.
 */
int ddLogLevel;

@implementation JULog

IMPLEMENT_SINGLETON(JULog);

- (void) configuration {
    // define the log level to LOG_LEVEL_WARN
#ifdef RELEASE_MODE
#ifdef DEBUG
    ddLogLevel = LOG_LEVEL_VERBOSE;
#else
    ddLogLevel = LOG_LEVEL_WARN;
#endif
    
#else
    ddLogLevel = LOG_LEVEL_INFO;
#endif
    
    // sends log statements to Xcode console - if available 
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    // sends log statements to Apple System Logger, so they show up on Console.app
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    
    // sends log to a file
//    DDFileLogger* fileLogger = [[[DDFileLogger alloc] init] autorelease];
//    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
//    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
//    
//    [DDLog addLogger:fileLogger];
    
    // log to see the build time and bundle version
    
#ifdef DEBUG
    NSString *buildDate =[[NSBundle mainBundle] objectForInfoDictionaryKey:@"BUILD_TIME"];
    NSString *revision =[[NSBundle mainBundle] objectForInfoDictionaryKey:(NSString*)kCFBundleVersionKey];
    DDLogVerbose(@"build time %@ -- revision %@",buildDate,revision);
#endif
    
}

@end
