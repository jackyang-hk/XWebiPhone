//
//  ZQLocationManager.m
//  ZheQ
//
//  Created by zehua fu on 11-6-1.
//  Copyright 2011年 ju.taobao.com/. All rights reserved.
//

#import "JULocationManager.h"
#import "JULog.h"
#import "JuCityManager.h"
#import "contants.h"

NSString* LOCATIONADDR_PRO_NAME = @"latestLoactionAddr";

@implementation JULocationManager
@synthesize isLatestLocateSuccess = _isLatestLocateSuccess;
@synthesize latestLocation = _latestLocation;
@synthesize latestLoactionAddr = _latestLocationAddr;
@synthesize locationManager = _locationManager;
@synthesize delegate;
@synthesize reverseGeoCoder;
@synthesize gpsCity = _gpsCity;
@synthesize defaultCity = _defaultCity;

- (void) dealloc{
    RELEASE_SAFELY(systemLanguages);
    RELEASE_SAFELY(_latestLocation);
    self.locationManager.delegate = nil;
    RELEASE_SAFELY(_locationManager);
    RELEASE_SAFELY(_latestLocationAddr);
    self.reverseGeoCoder.delegate = nil;
	RELEASE_SAFELY(reverseGeoCoder);
    [mapView removeFromSuperview];
    RELEASE_SAFELY(mapView);
    RELEASE_SAFELY(_locationLock);
    self.gpsCity = nil;
    self.defaultCity = nil;
    [super dealloc];
}

- (id) init{
    self = [super init];
    if (self != nil) {
        _latestLocation = nil;
        _latestLocationAddr = nil;
        self.reverseGeoCoder = nil;
        _isLatestLocateSuccess = NO;
        _locationManager = [[CLLocationManager alloc] init];
        [_locationManager setDelegate:self];
        
//        // 判斷是否 iOS 8
//        if([_locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
////            [_locationManager requestAlwaysAuthorization]; // 永久授权
//            [_locationManager requestWhenInUseAuthorization]; //使用中授权
//        }
        
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) { // iOS8+
            // Sending a message to avoid compile time error
            [[UIApplication sharedApplication] sendAction:@selector(requestWhenInUseAuthorization)
                                                       to:self.locationManager
                                                     from:self
                                                 forEvent:nil];
        }
        
        [_locationManager setDesiredAccuracy:kCLLocationAccuracyThreeKilometers];
        _locationManager.distanceFilter = 500;
        mapView = [[MKMapView alloc]initWithFrame:CGRectMake(0, 0, 1, 1)];
        mapView.showsUserLocation = YES;
        UIWindow* window = [[UIApplication sharedApplication] keyWindow];
        [window insertSubview:mapView atIndex:0];
        _locationLock = [[NSLock alloc]init];
        
        if (systemLanguages == nil) {
            systemLanguages = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] retain];
        }
        
        [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObject:@"zh-Hans"] forKey:@"AppleLanguages"];
        [[NSUserDefaults standardUserDefaults] synchronize];

    }
    return self;
}


#pragma mark -
#pragma mark Get/Set user default city

+ (NSString *)userDefaultCity {
    if ([JULocationManager sharedInstance].defaultCity == nil) {
         NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [JULocationManager sharedInstance].defaultCity = [defaults valueForKey:kUserDefaultCity];
    }
    return [JULocationManager sharedInstance].defaultCity;
}


+ (void)updateUserDefaultCity:(NSString *)city {
    
    [JULocationManager sharedInstance].defaultCity = city;
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:city forKey:kUserDefaultCity];
    [defaults synchronize];
    
    NSNotification* notification = [NSNotification notificationWithName:kCityNotificationLoaded
                                                                 object:[JULocationManager sharedInstance]
                                                               userInfo:nil];
    [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
}

- (void) setGpsCity:(NSString *)gpsCity {
    if (_gpsCity != gpsCity) {
        [_gpsCity release];
        _gpsCity = [gpsCity retain];
        NSNotification* notification = [NSNotification notificationWithName:kGPSCityNotificationLoaded
                                                                     object:[JULocationManager sharedInstance]
                                                                   userInfo:nil];
        
        [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"Couldn't turn on monitoring: Location services are not enabled.");
    }
    
    CLAuthorizationStatus authorizationStatus = [CLLocationManager authorizationStatus];
    switch (authorizationStatus) {
        case kCLAuthorizationStatusAuthorizedAlways:
            return;
            
        case kCLAuthorizationStatusAuthorizedWhenInUse:
            
            return;
            
        default:
            
            break;
    }

}

IMPLEMENT_SINGLETON(JULocationManager);

+ (void) startUpLocate{
    DDLogInfo(@"MSG: start location service");
    
    if ([JULocationManager sharedInstance].locationManager == nil) {
        [JULocationManager sharedInstance].locationManager = [[[CLLocationManager alloc] init] autorelease];
        [[JULocationManager sharedInstance].locationManager setDelegate:[JULocationManager sharedInstance]];
        
        // 判斷是否 iOS 8
        if([[JULocationManager sharedInstance].locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
//            [[JULocationManager sharedInstance].locationManager requestAlwaysAuthorization]; // 永久授权
            [[JULocationManager sharedInstance].locationManager requestWhenInUseAuthorization]; //使用中授权
        }
        
        [[JULocationManager sharedInstance].locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
        [JULocationManager sharedInstance].locationManager.distanceFilter = 500;
        [[JULocationManager sharedInstance].locationManager setDistanceFilter:kCLDistanceFilterNone];
    }
    [[JULocationManager sharedInstance].locationManager setDelegate:[JULocationManager sharedInstance]];
    [[JULocationManager sharedInstance].locationManager startUpdatingLocation];
}

+ (void) stopLocate{
    DDLogInfo(@"MSG: stop location service");
    [[JULocationManager sharedInstance].locationManager stopUpdatingLocation];
    [[JULocationManager sharedInstance].locationManager setDelegate:nil];
}

+ (CLLocation*) latestLocation{
    return [JULocationManager sharedInstance].latestLocation;
}

+ (void) registDelegate:(id)delegate{
    [JULocationManager sharedInstance].delegate = delegate;
}

+ (void) clearDelegate:(id)delegate{
    if ([JULocationManager sharedInstance].delegate == delegate) {
        [JULocationManager sharedInstance].delegate = nil;
    }
}

+ (void) addObserverForLocationAddr:(id)observer{
    [[JULocationManager sharedInstance] addObserver:observer forKeyPath:LOCATIONADDR_PRO_NAME options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld context:nil];
}

+ (void) removeObserverForLocationAddr:(id)observer{
    [[JULocationManager sharedInstance] removeObserver:observer forKeyPath:LOCATIONADDR_PRO_NAME];
}

+ (BOOL) isLatestLocateSuccess{
    return [JULocationManager sharedInstance].isLatestLocateSuccess;
}

- (void) uploadADDRToLocation:(CLLocationCoordinate2D) coordinate{
    self.reverseGeoCoder =[[[MKReverseGeocoder alloc] initWithCoordinate:coordinate] autorelease];
    self.reverseGeoCoder.delegate = self;
    [self.reverseGeoCoder start];
}

- (void) startFetchAddr{
    if (systemLanguages == nil) {
        systemLanguages = [[[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"] retain];
    }
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObject:@"zh-Hans"] forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.reverseGeoCoder =[[[MKReverseGeocoder alloc] initWithCoordinate:self.latestLocation.coordinate] autorelease];
    self.reverseGeoCoder.delegate = self;
    [self.reverseGeoCoder start];
}

- (void) refreshLocation{
    [JULocationManager stopLocate];
    [JULocationManager startUpLocate];
}


#pragma - mark CLLocationManagerDelegate
/*
 *  locationManager:didUpdateToLocation:fromLocation:
 *  
 *  Discussion:
 *    Invoked when a new location is available. oldLocation may be nil if there is no previous location
 *    available.
 */
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation{
    [JULocationManager stopLocate];
    
    if (oldLocation != _latestLocation) {
        DDLogVerbose(@"warnming - update location is not from former location stored");
    }

    if (abs(mapView.userLocation.coordinate.latitude - newLocation.coordinate.latitude) < 10) {
        self.latestLocation = mapView.userLocation.location;
//        UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%.20f,%.20f",mapView.userLocation.coordinate.longitude,mapView.userLocation.coordinate.latitude] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil];
//        [alertView show];
    } else {
        self.latestLocation = newLocation;
        //不需要更精确的位置信息
//        [self performSelector:@selector(refreshLocation) withObject:nil afterDelay:5];
    }
    
    [self startFetchAddr];
    
    DDLogVerbose(@"location has bean update to %@",newLocation);
    self.isLatestLocateSuccess = YES;
	if (delegate && [delegate respondsToSelector:@selector(didUpdateToLocation:)]) {
		[delegate didUpdateToLocation:self.latestLocation];
	}
}


static BOOL responce;

- (void)locationManager:(CLLocationManager *)manager
       didFailWithError:(NSError *)error{
    [JULocationManager stopLocate];
    
    self.isLatestLocateSuccess = NO;
    DDLogVerbose(@"location update fail on %@",[error domain]);
    if ([error code] == kCLErrorDenied) {

        if (!responce) {
            responce = YES;
            [JULocationManager stopLocate];
            
            UIAlertView * alertView = [[UIAlertView alloc]initWithTitle:@"查找位置失败" message:@"无法获取您的位置，请开启定位" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
            [alertView show];
            [alertView release];
            
//            [[ProgressHUDManager sharedInstance] showInfoHubWithInfo:@"定位失败" detailInfo:@"无法获取所在城市，请开启定位" afterDelay:2 group:@"No Location"];
//            [[ProgressHUDManager sharedInstance] showInfoHubWithInfo:@"无法获取所在城市，请开启定位" afterDelay:2 group:@"No Network Detect"];
        }
    }
    if (delegate && [delegate respondsToSelector:@selector(didFailureLocate)]) {
        [delegate didFailureLocate];
    }    
}

#pragma - mark MKReverseGeocoderDelegate

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error{
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObject:@"zh-Hans"] forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    DDLogVerbose(@"MSG: MKReverseGeocoder has failed.");
    self.latestLoactionAddr = @"";
#if DAILYMODE
    [self performSelector:@selector(startFetchAddr) withObject:nil afterDelay:1];
#else 
    [self performSelector:@selector(startFetchAddr) withObject:nil afterDelay:5];
#endif
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)placemark{
    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObject:@"zh-Hans"] forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSMutableString* string = [NSMutableString stringWithFormat:@"%@%@%@",placemark.subLocality,placemark.thoroughfare,placemark.subThoroughfare];

    [string replaceOccurrencesOfString:@"(null)" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, string.length)];
    self.latestLoactionAddr = string;
    
    NSString* city;
    if ([placemark.locality hasSuffix:@"市"]) {
        city = [placemark.locality substringToIndex:[placemark.locality length] - 1];
    } else {
        city = placemark.locality;        
    }
    DDLogVerbose(@"MSG: MKReverseGeocoder has success get City %@.",city);
    
    [[NSUserDefaults standardUserDefaults] setObject:city forKey:kGPSCityKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([JULocationManager userDefaultCity] != nil && [[JULocationManager userDefaultCity] isEqualToString:city]) {
        self.gpsCity = city;
        return;
    } else {
#pragma mark Send City Change Message;
        [_locationLock lock];
        [[JuCityManager sharedInstance] gpsUpdateToCity:city];
        [_locationLock unlock];
    }
} 

- (void) alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [JULocationManager updateUserDefaultCity:_gpsCity];
    }
}

@end
