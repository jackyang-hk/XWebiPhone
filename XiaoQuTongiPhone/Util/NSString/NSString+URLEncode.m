//
//  NSString+URLEncode.m
//  D8
//
//  Created by fu zehua on 11-9-13.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "NSString+URLEncode.h"
#import "NSString+Trim.h"

@implementation NSString (URLEncode)

- (NSString*)stringByURLEncodingStringParameter
{
    // NSURL's stringByAddingPercentEscapesUsingEncoding: does not escape
    // some characters that should be escaped in URL parameters, like / and ?; 
    // we'll use CFURL to force the encoding of those
    //
    // We'll explicitly leave spaces unescaped now, and replace them with +'s
    //
    // Reference: [url]http://www.ietf.org/rfc/rfc3986.txt[/url]
    
    NSString *resultStr = self;
    
    CFStringRef originalString = (CFStringRef) [self trim];
    CFStringRef leaveUnescaped = CFSTR(" ");
//    CFStringRef forceEscaped = CFSTR("!*'();@&=+$/?#[]");
    CFStringRef forceEscaped = CFSTR("!*'();:@&=+$/,?%#[]");
    
    CFStringRef escapedStr;
    escapedStr = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                         originalString,
                                                         leaveUnescaped, 
                                                         forceEscaped,
                                                         kCFStringEncodingUTF8);
    
    if( escapedStr )
    {
        NSMutableString *mutableStr = [NSMutableString stringWithString:(NSString *)escapedStr];
        CFRelease(escapedStr);
        
        // replace spaces with plusses
        [mutableStr replaceOccurrencesOfString:@" "
                                    withString:@"+"
                                       options:0
                                         range:NSMakeRange(0, [mutableStr length])];
        resultStr = mutableStr;
    }
    return resultStr;
}

- (NSString*) stringByURLDecodingStringParameter {
//    NSString *decodeString = [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    
//    return decodeString;
    
    NSMutableString *outputStr = [NSMutableString stringWithString:self];
    [outputStr replaceOccurrencesOfString:@"+"
                               withString:@" "
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0, [outputStr length])];
    
    NSString* output = [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    if (output) {
        return output;
    } else {
        NSStringEncoding gbkEncoding =CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        return [outputStr stringByReplacingPercentEscapesUsingEncoding:gbkEncoding];
    }
}

@end
