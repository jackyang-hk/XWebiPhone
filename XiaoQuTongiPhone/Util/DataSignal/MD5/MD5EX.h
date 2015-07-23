//
//  MD5.h
//  TBLoginBase
//
//  Created by zeha fu on 12-4-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MD5EX : NSObject

+ (NSString *) md5_string:(NSString *) str ;

+ (NSString*) md5_data:(NSData*) data ;

@end
