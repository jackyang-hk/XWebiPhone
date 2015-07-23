//
//  JuCityManager.m
//  JU
//
//  Created by zeha fu on 12-5-31.
//  Copyright (c) 2012年 ju.taobao.com. All rights reserved.
//

#import "JuCityManager.h"
//#import "TBMTopGetCityNameListRequest.h"
#import "JULocationManager.h"
//#import "GuideForFunction.h"
#import "JULocalPath.h"


#ifdef RELEASE_MODE
//三天
#define K_CITY_DELAY 259200
#define K_ITEMCATE_FILENAME @"City.plist"

#elif PRERELEASE_MODE
//三天
#define K_CITY_DELAY 2
#define K_ITEMCATE_FILENAME @"City.plist"

#else

#define K_CITY_DELAY 2
#define K_ITEMCATE_FILENAME @"Daily-City.plist"

#endif

@implementation JuCityManager

@synthesize cityList = _cityList;
@synthesize updateGPSCity = _updateGPSCity;

IMPLEMENT_SINGLETON(JuCityManager);

- (void)dealloc
{
    self.cityList = nil;
    [_request setDelegate:nil];
    RELEASE_REQUEST_SAFELY(_request);
    RELEASE_SAFELY(_cities);
    self.updateGPSCity = nil;
    [super dealloc];
}

static BOOL showSwitchCity = NO;

- (void) requestDidFinished:(TOPRequest *)request {
//    if ([request isKindOfClass:[TBMTopGetCityNameListRequest class]]) {
//        NSArray* cities = [[request responseJSON] valueForKeyPath:@"data.result"];
//        
//        self.cityList = cities;
//        
//        [self saveCityLocal];
//        
//        for (NSString* city in self.cityList) {
//            if ([city compare:self.updateGPSCity] == NSOrderedSame) {
//                if ([JULocationManager userDefaultCity] == nil) {
//                    [JULocationManager updateUserDefaultCity:self.updateGPSCity];
////                    [JULocationManager sharedInstance].gpsCity = self.updateGPSCity;
////                    NSString* tip = [NSString stringWithFormat:@"您的GPS定位到城市 %@，是否查看",self.updateGPSCity];
////                    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil message:tip delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"切换", nil];
////                    [alertView show];
////                    [alertView release];
//                } else {
//                    if ([JULocationManager sharedInstance].gpsCity != self.updateGPSCity) {
//                        if (!showSwitchCity) {
//                            showSwitchCity = YES;
//                            [JULocationManager sharedInstance].gpsCity = self.updateGPSCity;
//                            NSString* tip = [NSString stringWithFormat:@"您的GPS定位到城市 %@，是否进行切换",self.updateGPSCity];
//                            UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil message:tip delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"切换", nil];
//                            [alertView show];
//                            [alertView release];
//                        }
//                    }
//                }
//                return;
//            }
//        }
//        [JULocationManager sharedInstance].gpsCity = self.updateGPSCity;
//        self.updateGPSCity = nil;
//    }
//    RELEASE_REQUEST_SAFELY(_request);
}

- (void) requestDidFailed:(TOPRequest *)request {
//    if ([request isKindOfClass:[TBMTopGetCityNameListRequest class]]) {
////        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"数据加载失败" 
////                                                        message:@"请检查您的网络，并稍候再试" 
////                                                       delegate:self 
////                                              cancelButtonTitle:@"确定" 
////                                              otherButtonTitles:nil];
////        [alert show];
////        [alert release];
//    }
//    self.updateGPSCity = nil;
//    RELEASE_REQUEST_SAFELY(_request);
}

- (void) fetchCities {
//    RELEASE_REQUEST_SAFELY(_request);
//    _request = [[TBMTopGetCityNameListRequest alloc]init];
//    [_request setDelegate:self];
//    [_request sendRequest];
}

- (void) gpsUpdateToCity:(NSString*) gpsCity {
    [self loadCityFromLocal];
    if (self.cityList == nil || [self.cityList count] == 0) {
        self.updateGPSCity = gpsCity;
        [self fetchCities];
        return;
    }
    
    for (NSString* city in self.cityList) {
        if ([city compare:gpsCity] == NSOrderedSame) {
            
            if ([JULocationManager userDefaultCity] == nil) {
                [JULocationManager updateUserDefaultCity:gpsCity];
//                [JULocationManager sharedInstance].gpsCity = gpsCity;
//                NSString* tip = [NSString stringWithFormat:@"您的GPS定位到城市 %@，是否查看",gpsCity];
//                UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil message:tip delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"切换", nil];
//                [alertView show];
//                [alertView release];
            } else {
                if ([JULocationManager sharedInstance].gpsCity != gpsCity) {
                    [JULocationManager sharedInstance].gpsCity = gpsCity;
                    NSString* tip = [NSString stringWithFormat:@"您的GPS定位到城市 %@，是否进行切换",gpsCity];
                    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil message:tip delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"切换", nil];
                    [alertView show];
                    [alertView release];
                }
            }
            return;
        }
    }
}

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1)
    {
        [JULocationManager updateUserDefaultCity:[JULocationManager sharedInstance].gpsCity];
    }
}


#pragma mark Localized City
- (void) loadCityFromLocal {
    if (_cities == nil || [_cities count] == 0) {
        NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:JUCachePathForKey(K_ITEMCATE_FILENAME)];
		
		if([dict isKindOfClass:[NSDictionary class]]) {
			_cities = [dict mutableCopy];
		} else {
			_cities = [[NSMutableDictionary alloc] init];
		}
		
		[[NSFileManager defaultManager] createDirectoryAtPath:CommonCacheDirectory() 
                                  withIntermediateDirectories:YES 
                                                   attributes:nil 
                                                        error:NULL];
		
		
        NSDate* date = [_cities objectForKey:@"expiredate"];
        if([[[NSDate serverDate] earlierDate:date] isEqualToDate:date] || date == nil) {
            return;
        }
        [_cities removeObjectForKey:@"expiredate"];
        self.cityList = [_cities objectForKey:@"cities"];
    }
}

- (void) saveCityLocal {
    if (_cityList) {
        [_cities setObject:[NSDate dateWithTimeIntervalSinceNow:K_CITY_DELAY] forKey:@"expiredate"];
        [_cities setObject:_cityList forKey:@"cities"];
        [_cities writeToFile:JUCachePathForKey(K_ITEMCATE_FILENAME) atomically:YES];
        [_cities removeObjectForKey:@"expiredate"];    
    }
}



@end
