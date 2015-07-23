//
//  TBModel.m
//  TBSDK
//
//  Created by Xu Jiwei on 10-6-10.
//  Copyright 2010 Taobao.com. All rights reserved.
//

#import "TBModel.h"

#import "SBJSON.h"

@implementation TBModel

#pragma mark -
#pragma mark Class methods

+ (id)model {
    id model = [[[self class] alloc] init];
    return [model autorelease];
}

+ (id)modelWithJSON:(NSDictionary *)json {
    id model = [[[self class] alloc] initWithDictionary:json];
    return [model autorelease];
}

+ (id)modelArrayWithJSON:(NSArray *)jsonArray {
    Class cls = [self class];
    NSMutableArray *ret = [NSMutableArray arrayWithCapacity:[jsonArray count]];
    for (NSDictionary *dict in jsonArray) {
        [ret addObject:[cls modelWithJSON:dict]];
    }
         
    return ret;
}

#pragma mark -
#pragma mark Initialize

- (id)initWithDictionary:(NSDictionary *)dict {
    if (self == [self init]) {
        [self setFromDictionary:dict];
    }
    return self;
}

- (void)setFromDictionary:(NSDictionary *)dict {
    for (NSString *key in [dict keyEnumerator]) {
        id val = [dict objectForKey:key];
        
        if ([val isKindOfClass:[NSArray class]]) {
            Class type = [self classForKey:key];
            
            if (type) {
                [self setValue:[type modelArrayWithJSON:val] forKey:key];
            } else {
                [self setValue:val forKey:key];
            }
            
        } else if (![val isKindOfClass:[NSDictionary class]] && ![val isKindOfClass:[NSNull class]]) {
            
            [self setValue:val forKey:key];
            
        } else {
            
            id origVal = [self valueForKey:key];
			
            if ([origVal isKindOfClass:[NSArray class]]) {
                NSLog(@"key: %@", key);
                
                NSArray *allKeys = [val allKeys];
                
                if ([allKeys count] > 0) {
                    NSArray *arr = [val objectForKey:[allKeys objectAtIndex:0]];
                    
                    Class type = [self classForKey:key];
                    
                    if (type && [arr isKindOfClass:[NSArray class]]) {
                        [self setValue:[type modelArrayWithJSON:arr] forKey:key];
                    }
                }
                
            } else {
                Class cls = [self classForKey:key];
                if (cls) {
                    [self setValue:[cls modelWithJSON:val] forKey:key];
                } else {
                    [self setValue:val forKey:key];
                }
            }
                                                  
        }
    }
}

#pragma mark -
#pragma mark Key-Value Coding

- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    NSLog(@"WARNING: [%@] Set value for undefiend key %@", self, key);
}

- (id)valueForUndefinedKey:(NSString *)key {
    NSLog(@"WARNING: [%@] Get value for undefiend key %@", self, key);
    return nil;
}

#pragma mark -
#pragma mark NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder {
    NSArray *keys = [self keys];
    
    if ([aDecoder allowsKeyedCoding]) {
        for (NSString *key in keys) {
            [self setValue:[aDecoder decodeObjectForKey:key] forKey:key];
        }
    } else {
        for (NSString *key in keys) {
            [self setValue:[aDecoder decodeObject] forKey:key];
        }
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    NSArray *keys = [self keys];
    
    if ([aCoder allowsKeyedCoding]) {
        for (NSString *key in keys) {
            [aCoder encodeObject:[self valueForKey:key] forKey:key];
        }
    } else {
        for (NSString *key in keys) {
            [aCoder encodeObject:[self valueForKey:key]];
        }
    }
}

#pragma mark -

- (Class)classForKey:(NSString *)key {
    return NULL;
}

- (NSArray *)keys {
    return nil;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *ret = [NSMutableDictionary dictionaryWithCapacity:[[self keys] count]];
    NSArray *keys = [self keys];
    for (NSString *key in keys) {
        id val = [self valueForKey:key];
        if (val && ![val isKindOfClass:[NSNull class]]) {
            [ret setObject:val forKey:key];
        }
    }
    return ret;
}

@end
