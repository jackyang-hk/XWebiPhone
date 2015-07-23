//
//  NSObject+AppCacheUtil.m
//  BridgeLabiPhone
//
//  Created by redcat on 15/5/29.
//  Copyright (c) 2015年 redcat. All rights reserved.
//

#import "AppBridgeUtil.h"

@implementation AppBridgeUtil



+ (NSMutableDictionary*) dicFromQuery:(NSString*) query {
    query = [query stringByURLDecodingStringParameter];
    if (query == nil || [query isEqualToString:@""]) {
        return [[NSMutableDictionary alloc]init];
    }
    NSArray* list = [query componentsSeparatedByString:@"&"];
    NSMutableDictionary* queryDic = [[NSMutableDictionary alloc]init];
    for (NSString* em in list) {
        if (em != nil && ![em isEqualToString:@""]) {
            NSArray* el = [em componentsSeparatedByString:@"="];
            if ([el count] > 1) {
                [queryDic setObject:[el objectAtIndex:1] forKey:[el objectAtIndex:0]];
            }
        }
    }
    return queryDic;
}


+ (BOOL) isSyncBridgeRequest:(NSURL*) url{
    if (url && [url.absoluteString rangeOfString:@"bridge/operation?"].location != NSNotFound) {
        return true;
    }
    return false;
}

+ (NSData*) performSyncBridgeRequest:(NSURL*) url{
    NSString* operationData = [url.query stringByURLDecodingStringParameter];
    NSError* error;
    id operation = [operationData objectFromJSONStringWithParseOptions:JKSerializeOptionPretty error:&error];
    NSDictionary* params = [operation objectForKey:@"params"];
    if ([@"set_sync" isEqualToString:[operation objectForKey:@"action"]]) {
        NSString* key = [params objectForKey:@"key"];
        NSString* value = [params objectForKey:@"value"];
        if (value == nil || [value isEqualToString:@""]) {
            [[ISDiskCache sharedCache] removeObjectForKey:key];
            //目前先加三个钩子，便于数据存放到PARAMS
            if ([key isEqualToString:@"mobile"]) {
                [TBTop sharedInstance].mobile = nil;
            } else if ([key isEqualToString:@"communityId"]) {
                [TBTop sharedInstance].communityId = nil;
            } else if ([key isEqualToString:@"session"]) {
                [TBTop sharedInstance].session = nil;
            }
        } else {
            [[ISDiskCache sharedCache] setObject:value forKey:key];
            //目前先加三个钩子，便于数据存放到PARAMS
            if ([key isEqualToString:@"mobile"]) {
                [TBTop sharedInstance].mobile = value;
            } else if ([key isEqualToString:@"communityId"]) {
                [TBTop sharedInstance].communityId = value;
            } else if ([key isEqualToString:@"session"]) {
                [TBTop sharedInstance].session = value;
            }
        }
        return [@"true" dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([@"get_sync" isEqualToString:[operation objectForKey:@"action"]]) {
        NSString* key = [params objectForKey:@"key"];
        NSString* value = [[ISDiskCache sharedCache] objectForKey:key];
        
        if ((value == nil || [value isEqualToString:@""]) && [key isEqualToString:@"udid"]) {
            value = [TBTop getUniqueIdentifierForVendor];
        } else if ((value == nil || [value isEqualToString:@""]) && [key isEqualToString:@"mobile"]) {
            value = [TBTop sharedInstance].mobile;
        } else if ((value == nil || [value isEqualToString:@""]) && [key isEqualToString:@"session"]) {
            value = [TBTop sharedInstance].session;
        } else if ((value == nil || [value isEqualToString:@""]) && [key isEqualToString:@"token"]) {
            value = [TBTop sharedInstance].token;
        }
        
        if (value != nil) {
            return [value dataUsingEncoding:NSUTF8StringEncoding];
        }
        
        return [@"false" dataUsingEncoding:NSUTF8StringEncoding];
    } else if ([@"delete_sync" isEqualToString:[operation objectForKey:@"action"]]) {
        NSString* key = [params objectForKey:@"key"];
        if (key != nil || ![key isEqualToString:@""]) {
            [[ISDiskCache sharedCache] removeObjectForKey:key];
            //目前先加三个钩子，便于数据存放到PARAMS
            if ([key isEqualToString:@"mobile"]) {
                [TBTop sharedInstance].mobile = nil;
            } else if ([key isEqualToString:@"communityId"]) {
                [TBTop sharedInstance].communityId = nil;
            } else if ([key isEqualToString:@"session"]) {
                [TBTop sharedInstance].session = nil;
            }
        }
        return [@"true" dataUsingEncoding:NSUTF8StringEncoding];
    }
    return [@"false" dataUsingEncoding:NSUTF8StringEncoding];
}


@end
