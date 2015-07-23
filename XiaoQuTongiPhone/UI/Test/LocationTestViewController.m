//
//  SplashViewController.m
//  XiaoQuTongiPhone
//
//  Created by redcat on 14-7-23.
//  Copyright (c) 2014年 redcat. All rights reserved.
//

#import "Macros.h"
#import "LocationTestViewController.h"


@implementation LocationTestViewController

- (id) init {
    if (self = [super init]) {

    }
    return self;
}

- (void) loadView {
    UIView* view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view = view;

    
    self.mapView = [[MKMapView alloc] initWithFrame:CGRectMake(0, 0, IPHONE_WIDTH, 400)];
    [self.view addSubview:self.mapView];
    [self.mapView setMapType:MKMapTypeStandard];
    self.mapView.showsUserLocation=YES;
    [self.mapView setDelegate:self];
    
    

    
}

- (void) viewDidLoad {
    [super viewDidLoad];
    

}

- (void) relocate {
    CLLocationCoordinate2D theCoordinate;
    theCoordinate.latitude=self.mapView.userLocation.coordinate.latitude;
    theCoordinate.longitude=self.mapView.userLocation.coordinate.longitude;
    MKCoordinateSpan theSpan;
    theSpan.latitudeDelta=0.1;
    theSpan.longitudeDelta=0.1;
    MKCoordinateRegion theRegion;
    theRegion.center=theCoordinate;
    theRegion.span=theSpan;
    [self.mapView setRegion:theRegion];
    
    UIAlertView* alertView = [[UIAlertView alloc]initWithTitle:nil message:[NSString stringWithFormat:@"%.20f,%.20f",self.mapView.userLocation.coordinate.longitude,self.mapView.userLocation.coordinate.latitude] delegate:self cancelButtonTitle:@"取消" otherButtonTitles:nil];
    [alertView show];
}

- (void) viewDidAppear:(BOOL)animated {
    
    [self performSelector:@selector(relocate) withObject:nil afterDelay:2];

    


}


@end
