//
//  JMPaths.m
//  JoyMapsKit
//
//  Created by laijiandong on 12/18/14.
//  Copyright (c) 2014 laijiandong. All rights reserved.
//

#import "JMPaths.h"

NSString* JMPathForBundleResource(NSBundle* bundle, NSString *relativePath) {
    NSString *resourcePath = [(nil == bundle ? [NSBundle mainBundle] : bundle) resourcePath];
    return [resourcePath stringByAppendingPathComponent:relativePath];
}

NSString* JMPathForDocumentsResource(NSString *relativePath) {
    static NSString *documentsPath = nil;
    if (nil == documentsPath) {
        NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                            NSUserDomainMask,
                                                            YES);
        documentsPath = ([dirs count] > 0) ? dirs[0] : nil;
    }
    
    return [documentsPath stringByAppendingPathComponent:relativePath];
}

NSString* JMPathForLibraryResource(NSString *relativePath) {
    static NSString *libraryPath = nil;
    if (nil == libraryPath) {
        NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                                            NSUserDomainMask,
                                                            YES);
        libraryPath = ([dirs count] > 0) ? dirs[0] : nil;
    }
    
    return [libraryPath stringByAppendingPathComponent:relativePath];
}

NSString* JMPathForCachesResource(NSString *relativePath) {
    static NSString *cachesPath = nil;
    if (nil == cachesPath) {
        NSArray *dirs = NSSearchPathForDirectoriesInDomains(NSCachesDirectory,
                                                            NSUserDomainMask,
                                                            YES);
        cachesPath = ([dirs count] > 0) ? dirs[0] : nil;
    }
    
    return [cachesPath stringByAppendingPathComponent:relativePath];
}