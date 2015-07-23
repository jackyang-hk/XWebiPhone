//
//  JULocalPath.h
//  JU
//
//  Created by zeha fu on 12-5-27.
//  Copyright (c) 2012年 ju.taobao.com. All rights reserved.
//

#ifndef JU_JULocalPath_h
#define JU_JULocalPath_h



#endif

static NSString* _CommonDirectory;

static NSString* CommonCacheDirectory() {
	if(!_CommonDirectory) {
		NSString* cachesDirectory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		_CommonDirectory = [[[cachesDirectory stringByAppendingPathComponent:[[NSProcessInfo processInfo] processName]] stringByAppendingPathComponent:@"JHSCommon"] copy];
	}
	
	return _CommonDirectory;
}

static NSString* JUCachePathForKey(NSString* key) {
	return [CommonCacheDirectory() stringByAppendingPathComponent:key];
}
