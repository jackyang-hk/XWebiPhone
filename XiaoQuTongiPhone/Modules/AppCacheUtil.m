//
//  NSObject+AppCacheUtil.m
//  BridgeLabiPhone
//
//  Created by redcat on 15/5/29.
//  Copyright (c) 2015年 redcat. All rights reserved.
//

#import "AppCacheUtil.h"

@implementation AppCacheUtil

+ (float) fileSizeAtPath:(NSString *)path{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if([fileManager fileExistsAtPath:path]){
        long long size=[fileManager attributesOfItemAtPath:path error:nil].fileSize;
        return size/1024.0/1024.0;
    }
    return 0;
}

+ (float) folderSizeAtPath:(NSString *)path{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    float folderSize;
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childerFiles=[fileManager subpathsAtPath:path];
        for (NSString *fileName in childerFiles) {
            NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
            folderSize +=[AppCacheUtil fileSizeAtPath:absolutePath];
        }
        　　　　　//SDWebImage框架自身计算缓存的实现
//        folderSize+=[[SDImageCache sharedImageCache] getSize]/1024.0/1024.0;
        return folderSize;
    }
    return 0;
}

+ (void)clearCachePath:(NSString *)path{
    NSFileManager *fileManager=[NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        NSArray *childerFiles=[fileManager subpathsAtPath:path];
        for (NSString *fileName in childerFiles) {
            //如有需要，加入条件，过滤掉不想删除的文件
            NSString *absolutePath=[path stringByAppendingPathComponent:fileName];
            [fileManager removeItemAtPath:absolutePath error:nil];
        }
    }
//    [[SDImageCache sharedImageCache] cleanDisk];
}

+ (float) appCacheSize {
    NSArray *cacPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    float folderSize = 0.0f;
    if ([cacPath count] > 0) {
        NSString *cachePath = [cacPath objectAtIndex:0];
        cachePath = [cachePath stringByAppendingString:@"/WebCaches"];
        folderSize += [AppCacheUtil folderSizeAtPath:cachePath];
    }
    
    folderSize +=[[SDImageCache sharedImageCache] getSize]/1024.0/1024.0;

    return folderSize;
}

+ (void) clearCache {
    NSArray *cacPath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    if ([cacPath count] > 0) {
        NSString *cachePath = [cacPath objectAtIndex:0];
        cachePath = [cachePath stringByAppendingString:@"/WebCaches"];
        [AppCacheUtil clearCachePath:cachePath];
    }
    [[SDImageCache sharedImageCache] cleanDisk];
}

@end
