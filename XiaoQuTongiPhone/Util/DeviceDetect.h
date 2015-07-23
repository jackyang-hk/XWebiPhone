//
//  DeviceDetect.h
//  JU
//
//  Created by zeha fu on 12-6-12.
//  Copyright (c) 2012年 ju.taobao.com. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceDetect : NSObject

+ (BOOL) isLowPerformenceDevice ;
//判断是否单任务系统
+ (BOOL) isSingleTask;

//判断是否小于5.0的系统
+ (BOOL) isUnder5xVersion ;

@end

@interface UIDevice (UIDeviceHelper)

- (double)availableMemory ;

- (NSString*) uniqueIdentifier;

@end
