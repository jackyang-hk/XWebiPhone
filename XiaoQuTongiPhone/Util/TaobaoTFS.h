//
//  TaobaoTFS.h
//  JU
//
//  Created by zeha fu on 12-5-8.
//  Copyright (c) 2012年 ju.taobao.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TaobaoTFS : NSObject

+ (void) resetServers ;
// 除了图片预加在，其余部分废弃
+ (NSString*) getSmallImagePath:(NSString*)path ;
// 除了图片预加在，其余部分废弃
+ (NSString*) getMiddleImagePath:(NSString*) path ;

+ (NSString*) getOriginImagePath:(NSString*) path ;

+ (NSString*) normalImagePathForSmallPath:(NSString*) smallPath ;

// 大图模式分辨率按照优先级从高到低
+ (NSArray*) getMiddleImagePathsInDifferentNetwork:(NSString*)path ;

// 小图模式分辨率按照优先级从高到低
+ (NSArray*) getSmallImagePathsInDifferentNetwork:(NSString*)path ;

@end
