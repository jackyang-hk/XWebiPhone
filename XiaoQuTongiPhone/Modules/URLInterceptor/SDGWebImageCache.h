//
//  SDGWebImageCache.h
//  BridgeLabiPhone
//
//  Created by yanhao on 4/6/15.
//  Copyright (c) 2015 redcat. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Web图片资源缓存管理类
 */
@interface SDGWebImageCache : NSObject

- (BOOL)hasCacheDataForURL:(NSURL *)url;
- (NSData *)cacheDataForURL:(NSURL *)url response:(NSURLResponse **)response;
- (void)storeCacheData:(NSData *)data forURL:(NSURL *)url;

@end

