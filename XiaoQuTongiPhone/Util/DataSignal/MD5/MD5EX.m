//
//  MD5.m
//  TBLoginBase
//
//  Created by zeha fu on 12-4-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MD5EX.h"
#import <CommonCrypto/CommonDigest.h>


@implementation MD5EX


+ (NSString *) md5_string:(NSString *) str {  
    const char *cStr = [str UTF8String];  
    unsigned char result[CC_MD5_DIGEST_LENGTH];  
    CC_MD5( cStr, strlen(cStr), result );  
	
    return [NSString stringWithFormat:  
            @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",  
            result[0], result[1], result[2], result[3],  
            result[4], result[5], result[6], result[7],  
            result[8], result[9], result[10], result[11],  
            result[12], result[13], result[14], result[15]  
            ];  
} 

+ (NSString*) md5_data:(NSData*) data {
	const char *cStr = [data bytes];
	unsigned char digest[CC_MD5_DIGEST_LENGTH];
	CC_MD5( cStr, [data length], digest );
	return [NSString stringWithFormat: @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            digest[0], digest[1], 
            digest[2], digest[3],
            digest[4], digest[5],
            digest[6], digest[7],
            digest[8], digest[9],
            digest[10], digest[11],
            digest[12], digest[13],
            digest[14], digest[15]];	
}
@end
