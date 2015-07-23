//
//  ZQLocationManager.h
//  ZheQ
//
//  Created by zehua fu on 11-6-1.
//  Copyright 2011年 ju.taobao.com/. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreLocation/CoreLocation.h"
#import "MapKit/MapKit.h"
#import "Macros.h"

#define kCityNotificationLoaded @"kCityNotificationLoaded"
#define kGPSCityNotificationLoaded @"kGPSCityNotificationLoaded"
#define kCityDidSelectedNotification @"kCityDidSelectedNotification"

extern NSString* LOCATIONADDR_PRO_NAME;

@protocol JHSLocationManagerDelegate;
@interface JULocationManager : NSObject <CLLocationManagerDelegate,MKReverseGeocoderDelegate,UIAlertViewDelegate>{
    NSArray           *systemLanguages;
    
    CLLocation* _latestLocation;
    NSString* _latestLocationAddr;
    MKMapView* mapView;
    
    BOOL _isLatestLocateSuccess;
    CLLocationManager* _locationManager;
    NSLock* _locationLock;
}

@property (nonatomic, assign) BOOL isLatestLocateSuccess;
@property (nonatomic, retain) CLLocation* latestLocation;
@property (nonatomic, copy) NSString* latestLoactionAddr;
@property (nonatomic, retain) CLLocationManager* locationManager;
@property (nonatomic, retain) MKReverseGeocoder* reverseGeoCoder;
@property (nonatomic, assign) id<JHSLocationManagerDelegate> delegate;
@property (nonatomic, retain) NSString* gpsCity;
@property (nonatomic, retain) NSString* defaultCity;

DECLARE_SINGLETON(JULocationManager);

+ (void) startUpLocate;

+ (void) stopLocate;

+ (void) registDelegate:(id)delegate;

+ (void) addObserverForLocationAddr:(id)observer;

+ (void) removeObserverForLocationAddr:(id)observer;

+ (void) clearDelegate:(id)delegate;

+ (BOOL) isLatestLocateSuccess;

- (void) uploadADDRToLocation:(CLLocationCoordinate2D) coordinate;
//获取用户默认城市, nil for first
+ (NSString *)userDefaultCity ;
//切换城市, 会发送通知给相关UI更新
+ (void)updateUserDefaultCity:(NSString *)city ;

@end

@protocol JHSLocationManagerDelegate <NSObject>

@optional

- (void) didUpdateToLocation:(CLLocation*)location;

- (void) didFailureLocate;

@end

