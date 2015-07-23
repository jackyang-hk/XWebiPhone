//
//  NSString+URLEncode.h
//  D8
//
//  Created by fu zehua on 11-9-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (URLEncode)

- (NSString*)stringByURLEncodingStringParameter;

- (NSString*) stringByURLDecodingStringParameter;

@end
