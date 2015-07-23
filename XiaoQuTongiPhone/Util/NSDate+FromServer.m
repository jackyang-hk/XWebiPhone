//
//  NSDate+FromServer.m
//  JU
//
//  Created by zeha fu on 12-6-8.
//  Copyright (c) 2012年 ju.taobao.com. All rights reserved.
//

#import "NSDate+FromServer.h"
#import "TBTop.h"

@implementation NSDate (FromServer)

+ (id) serverDate {
    return [TBTop timestampSync];
}

@end
