//
//  SplashViewController.h
//  XiaoQuTongiPhone
//
//  Created by redcat on 14-7-23.
//  Copyright (c) 2014年 redcat. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface LocationTestViewController : ViewControllerBase <MKMapViewDelegate>{
    
}
@property (nonatomic) MKMapView* mapView;
@property (nonatomic) NSString* latitude;
@property (nonatomic) NSString* longitude;

@end
