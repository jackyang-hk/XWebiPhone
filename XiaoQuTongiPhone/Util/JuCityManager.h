//
//  JuCityManager.h
//  JU
//
//  Created by zeha fu on 12-5-31.
//  Copyright (c) 2012年 ju.taobao.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TOPRequest.h"

@interface JuCityManager : NSObject <TBTOPRequestDelegate> {
    TOPRequest* _request;
    NSMutableDictionary* _cities;
}

@property (nonatomic, retain) NSArray   *cityList;
@property (nonatomic, retain) NSString* updateGPSCity;

DECLARE_SINGLETON(JuCityManager);

- (void) gpsUpdateToCity:(NSString*) gpsCity ;

@end
