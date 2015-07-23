//
//  JMURLAction.m
//  JoyMaps
//
//  Created by laijiandong on 13-5-12.
//  Copyright (c) 2013年 taobao inc. All rights reserved.
//

#import "JMURLAction.h"
#import "JMUtility.h"

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "JMURLAction requires ARC support."
#endif

@implementation JMURLAction

@synthesize urlPath = urlPath_;
@synthesize query = query_;
@synthesize animated = animated_;

- (id)copyWithZone:(NSZone *)zone {
    JMURLAction* action = [[JMURLAction alloc]init];
    action.urlPath = self.urlPath;
    action.query = self.query;
    action.animated = self.animated;
    return action;
}

- (id)initWithURLPath:(NSString *)urlPath {
    self = [super init];
    if (self) {
        // parse the parameters form url
        if (urlPath != nil) {
            NSURL *url = [NSURL URLWithString:urlPath];
            NSString *queryString = [url query];
            if (queryString != nil) {
                NSUInteger boundary = [queryString length] + 1; // plus the length of '?'
                if ([urlPath length] > boundary) {
                    NSInteger index = [urlPath length] - boundary;
                    urlPath_ = [urlPath substringToIndex:index];
                }
                
                NSDictionary *query = [JMUtility dictionaryByParsingURLQueryPart:queryString];
                query_ = query;
            
            } else {
                urlPath_ = urlPath;
            }
        }
    }
    
    return self;
}

+ (instancetype)actionWithURLPath:(NSString*)urlPath {
    return [[JMURLAction alloc] initWithURLPath:urlPath];
}

- (JMURLAction *)applyQuery:(NSDictionary*)query {
    self.query = query;
    
    return self;
}

- (JMURLAction *)applyAnimated:(BOOL)animated {
    self.animated = animated;
    
    return self;
}

@end
