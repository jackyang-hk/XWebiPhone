//
//  NetworkDetect.m
//  JU
//
//  Created by zeha fu on 12-5-9.
//  Copyright (c) 2012年 ju.taobao.com. All rights reserved.
//

#import "NetworkDetect.h"
#import "Reachability.h"

@implementation NetworkDetect

+ (BOOL) isStateWiFi {
    Reachability* reachconn = [Reachability reachabilityForInternetConnection];
    if ([reachconn currentReachabilityStatus] == ReachableViaWiFi) {
        return YES;
    } 
    return NO;
}

+ (BOOL) isStateNotReached {
    Reachability* reachconn = [Reachability reachabilityForInternetConnection];
    if ([reachconn currentReachabilityStatus] == NotReachable) {
        return YES;
    } 
    return NO;
}

+ (void) showNetworkInfo {
    if ([NetworkDetect isStateNotReached]) {
        if (showInfoTotalCount > 0) {
            showInfoTotalCount -= 1;
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
//                                                            message:@"无网络连接"
//                                                           delegate:self
//                                                  cancelButtonTitle:@"确定"
//                                                  otherButtonTitles:nil];
//            [alert show];
        }
    } else {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
//                                                        message:@"亲，您的网络不给力啊！"
//                                                       delegate:self
//                                              cancelButtonTitle:@"确定"
//                                              otherButtonTitles:nil];
//        [alert show];
    }
}

static int showInfoTotalCount = 5;

+ (void) detectNoNetwork {
    if ([NetworkDetect isStateNotReached]) {
        if (showInfoTotalCount > 0) {
            showInfoTotalCount -= 1;
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@""
                                                            message:@"无网络连接"
                                                           delegate:self
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    } else {
        [self resetShowInfo];
    }
}

+ (void) resetShowInfo {
    showInfoTotalCount = 5;
}



@end
