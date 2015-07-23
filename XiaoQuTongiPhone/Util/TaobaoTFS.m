//
//  TaobaoTFS.m
//  JU
//
//  Created by zeha fu on 12-5-8.
//  Copyright (c) 2012年 ju.taobao.com. All rights reserved.
//

#import "TaobaoTFS.h"
#import "JULog.h"
#import "Reachability.h"
#import "NetworkDetect.h"

#ifdef RELEASE_MODE
static NSArray* servers = nil;
#else
static NSArray* servers = nil;
#endif

@implementation TaobaoTFS

+ (void) resetServers {
	servers = nil;
}

+ (NSString*) getTFSServerPath:(NSString*)path {

    
    if (servers == nil) {
//        int mode = [TBTop getCurrentRequestHostMode];
//        if (mode == RELEASE_REQUEST) {
////#ifdef RELEASE_MODE
//        
//        servers = [[NSArray arrayWithObjects:@"http://img01.taobaocdn.com/bao/uploaded/",@"http://img02.taobaocdn.com/bao/uploaded/",@"http://img03.taobaocdn.com/bao/uploaded/",@"http://img04.taobaocdn.com/bao/uploaded/",nil] retain];
//        
//        } else if (mode == PRERELEASE_REQUEST) {
////#elif PRERELEASE_MODE
//        
//        servers = [[NSArray arrayWithObjects:@"http://img01.taobaocdn.com/bao/uploaded/",@"http://img02.taobaocdn.com/bao/uploaded/",@"http://img03.taobaocdn.com/bao/uploaded/",@"http://img04.taobaocdn.com/bao/uploaded/",nil] retain];
//        
//        } else if (mode == DAILY_REQUEST) {
////#elif DAILY_MODE
//        
//        servers = [[NSArray arrayWithObjects:@"http://img01.daily.taobaocdn.net/bao/uploaded/",@"http://img02.daily.taobaocdn.net/bao/uploaded/",@"http://img03.daily.taobaocdn.net/bao/uploaded/",@"http://img04.daily.taobaocdn.net/bao/uploaded/",nil] retain];
//        
//        }
////#endif
        
        servers = [[NSArray arrayWithObjects:@"http://img.redcat.name:8085/mini-tfs-folder/images",@"http://img.redcat.name:8085/mini-tfs-folder/images",@"http://img.redcat.name:8085/mini-tfs-folder/images",@"http://img.redcat.name:8085/mini-tfs-folder/images",nil] retain];
        
    }
    if (path == nil) {
        return [servers objectAtIndex:0];
    }
    return [servers objectAtIndex:[path hash]%4];
}

+ (NSString*) getImageFullPath:(NSString*)path level:(NSString*) level{
    
    if (path == nil) {
        return nil;
    }
    
    if ([path hasPrefix:@"http://"]) {
        return path;
    }
   
    NSString* type = [path substringFromIndex:[path length] - 4];
    NSString* name = [path substringToIndex:[path length] -4];

    NSString* imageUrl =  [NSString stringWithFormat:@"%@%@%@%@",[TaobaoTFS getTFSServerPath:path],name,type,level];
    
    return imageUrl;
}

+ (NSString*) getSmallImagePath:(NSString *)path {
    if ([[UIScreen mainScreen] scale] == 2) {
        //小图模式以小快浏览为主
        if ([NetworkDetect isStateWiFi]) {
            return [self getImageFullPath:path level:@"_240x240.jpg"];
        } else {
            return [self getImageFullPath:path level:@"_120x120.jpg"];
        }
    } else {
        return [self getImageFullPath:path level:@"_120x120.jpg"];                
    }
}

+ (NSArray*) getSmallImagePathsInDifferentNetwork:(NSString*)path {
    if ([NetworkDetect isStateWiFi]) {
        return [NSArray arrayWithObjects:[NSURL URLWithString:[self getImageFullPath:path level:@"_240x240.jpg"]], nil];
    } else {
        return [NSArray arrayWithObjects:[NSURL URLWithString:[self getImageFullPath:path level:@"_240x240.jpg"]],[NSURL URLWithString:[self getImageFullPath:path level:@"_120x120.jpg"]], nil];
    }
}

+ (NSString*) getMiddleImagePath:(NSString*) path {
    if ([[UIScreen mainScreen] scale] == 2) {
        //TFS有些图片在某些尺寸下没有图片
        if ([NetworkDetect isStateWiFi]) {
            return [self getImageFullPath:path level:@"_640x480.jpg"];
        } else {
            return [self getImageFullPath:path level:@"_400x400.jpg"];
        }
    } else {
        return [self getImageFullPath:path level:@"_400x400.jpg"];
    }
}

+ (NSArray*) getMiddleImagePathsInDifferentNetwork:(NSString*)path {
    if ([NetworkDetect isStateWiFi]) {
        return [NSArray arrayWithObjects:[NSURL URLWithString:[self getImageFullPath:path level:@"_640x480.jpg"]], nil];
    } else {
        return [NSArray arrayWithObjects:[NSURL URLWithString:[self getImageFullPath:path level:@"_640x480.jpg"]],[NSURL URLWithString:[self getImageFullPath:path level:@"_400x400.jpg"]], nil];
    }
}

+ (NSString*) getOriginImagePath:(NSString*) path {
    if ([[UIScreen mainScreen] scale] == 2) {
        return [self getImageFullPath:path level:@""];        
    } else {
        return [self getImageFullPath:path level:@""];        
    }
}

+ (NSString*) normalImagePathForSmallPath:(NSString*) smallPath {
    NSString* originPath = nil;
    NSRange exceptRange ;
    
    exceptRange = [smallPath rangeOfString:@"_120x120.jpg"];
    if (exceptRange.length != 0 && originPath == nil) {
        originPath = [NSString stringWithFormat:@"%@%@",[smallPath substringToIndex:exceptRange.location],[smallPath substringFromIndex:exceptRange.location+exceptRange.length]];
    }
    
    exceptRange = [smallPath rangeOfString:@"_240x240.jpg"];
    if (exceptRange.length != 0 && originPath == nil) {
        originPath = [NSString stringWithFormat:@"%@%@",[smallPath substringToIndex:exceptRange.location],[smallPath substringFromIndex:exceptRange.location+exceptRange.length]];
    }
    
    exceptRange = [smallPath rangeOfString:@"_400x400.jpg"];
    if (exceptRange.length != 0 && originPath == nil) {
        originPath = [NSString stringWithFormat:@"%@%@",[smallPath substringToIndex:exceptRange.location],[smallPath substringFromIndex:exceptRange.location+exceptRange.length]];
    }
    
    exceptRange = [smallPath rangeOfString:@"_640x480.jpg"];
    if (exceptRange.length != 0 && originPath == nil) {
        originPath = [NSString stringWithFormat:@"%@%@",[smallPath substringToIndex:exceptRange.location],[smallPath substringFromIndex:exceptRange.location+exceptRange.length]];
    }
    
//    if ([[UIScreen mainScreen] scale] == 2) {
//        exceptRange = [smallPath rangeOfString:@"_120x120.jpg"];
//    } else {
//        exceptRange = [smallPath rangeOfString:@"_120x120.jpg"];
//    }
//    
//    if (exceptRange.length == 0) {
//        exceptRange = [smallPath rangeOfString:@"_400x400.jpg"];
//        if (exceptRange.length != 0) {
//            originPath = [NSString stringWithFormat:@"%@%@",[smallPath substringToIndex:exceptRange.location],[smallPath substringFromIndex:exceptRange.location+exceptRange.length]];
//        }
//    } else {
//        originPath = [NSString stringWithFormat:@"%@%@",[smallPath substringToIndex:exceptRange.location],[smallPath substringFromIndex:exceptRange.location+exceptRange.length]];
//    }
    
    return originPath;
}


@end
