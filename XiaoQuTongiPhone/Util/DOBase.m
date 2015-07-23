//
//  DOBase.m
//  JHS
//
//  Created by zeha fu on 12-4-5.
//  Copyright (c) 2012年 ju.taobao.com. All rights reserved.
//

#import "DOBase.h"
#import "NSObject+ClassForProperty.h"
#import <objc/runtime.h>
#import "JULog.h"

//#define OPEN_MAPPING_WARMING 1

@interface DOBase (Private)

+ (DOBase*) mapping:(id)data forClass:(Class)clazz;

+ (NSArray*) mappingList:(id)list forClass:(Class) clazz;

@end

@implementation DOBase
@synthesize jsonData = _jsonData;

- (void)dealloc
{
    self.jsonData = nil;
    [self unregisterFromKVO];
    [super dealloc];
    
}

- (id) init {
    self = [super init];
    if (self) {
        [self registerForKVO];
    }
    return self;
}

#pragma mark - KVO

- (void)registerForKVO {
	for (NSString *keyPath in [self observableKeypaths]) {
		[self addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
	}
}

- (void)unregisterFromKVO {
	for (NSString *keyPath in [self observableKeypaths]) {
		[self removeObserver:self forKeyPath:keyPath];
	}
}

- (NSArray *)observableKeypaths {
//	return [NSArray arrayWithObjects:@"mode", @"customView", @"labelText", @"labelFont", 
//			@"detailsLabelText", @"detailsLabelFont", @"progress", nil];
    return nil;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	
}


+ (Class) classForName:(NSString*) name {
    return nil;
}

+ (NSArray*) mappingList:(id)list {
    return [self mappingList:list forClass:[self class]];
}

+ (NSArray*) mappingList:(id)list forClass:(Class) clazz {
    NSMutableArray* arrays = [[[NSMutableArray alloc]init] autorelease];
    //匹配Clazz未空，不进行匹配
    if (clazz == nil) {
        return arrays;
    }
    
    if (!list || [list isKindOfClass:[NSNull class]]) {
        return arrays;
    } 
    NSAutoreleasePool* pool = [[NSAutoreleasePool alloc]init];
    if ([list isKindOfClass:[NSArray class]]) {
        for (NSDictionary* element in list) {
            if (element != nil && ![element isKindOfClass:[NSNull class]]) {
                id elementdo = [clazz mapping:element];
                if (elementdo) {
                    [arrays addObject:elementdo];
                }
            }
        }
    } else if ([list isKindOfClass:[NSDictionary class]]){
        [arrays addObject:[clazz mapping:list]];
    }
    [pool release];
    return arrays;
}

+ (DOBase*) mapping:(id)data{  
    return [self mapping:data forClass:[self class]];
}

+ (DOBase*) mapping:(id)data forClass:(Class)clazz {
    if (clazz == nil || data == nil || ![data isKindOfClass:[NSDictionary class]]) {
        return [[[clazz alloc]init] autorelease];
    }
    
    NSArray* array = [data allKeys];
    DOBase* target = [[[[clazz class] alloc]init] autorelease];
    @try {
        if ([target isKindOfClass:[DOBase class]]) {
            target.jsonData = data;                    
        }
    }
    @catch (NSException *exception) {
    }

    
#ifdef DEBUG
    unsigned int outCount;
    objc_property_t * properties = class_copyPropertyList([clazz class], &outCount);
    if (outCount != [array count]) {
#ifdef OPEN_MAPPING_WARMING
        DDLogVerbose(@"Warming - Missing Key Count: The Data has '%lu' properties while '%d' properties in class '%s'",[array count],outCount,class_getName([target class]));
#endif
    }
	free(properties);
#endif

    
    for (id obj in array) {
        id value = [data objectForKey:obj];
        
        if ([value isKindOfClass:[NSArray class]]) {
            Class propertyClass = [clazz classForName:obj];
            if (propertyClass == nil) {
//                DDLogVerbose(@"Warming - Missing Match: The Class of Property ['%@'] is not defined in class '%s'",obj,class_getName([target class]));
                propertyClass = [clazz classForProperty:[obj cStringUsingEncoding:NSASCIIStringEncoding]];
                if (propertyClass != NULL) {
                    @try {
                        if (value != nil) {
                            [target setValue:value forKey:obj];                    
                        } else {
#ifdef OPEN_MAPPING_WARMING
                            DDLogWarn(@"some property is not so normal");
#endif
                        }
                    }
                    @catch (NSException *exception) {
                        @try {
                            [target setValue:value forUndefinedKey:obj];                    
                        }
                        @catch (NSException *exception) {
#ifdef OPEN_MAPPING_WARMING
                            DDLogWarn(@"Warming - Missing Match: The Property ['%@'] is not defined or alia defined in class ['%s']",obj,class_getName([target class]));
#endif
                        }
                    }
                }
            } else {
                NSArray* propertyValues = [DOBase mappingList:value forClass:propertyClass];
                @try {
                    [target setValue:propertyValues forKey:obj];
                }
                @catch (NSException *exception) {
#ifdef OPEN_MAPPING_WARMING
                    DDLogWarn(@"Warming - Missing Match: The Property ['%@'] is not defined in class ['%s']",obj,class_getName([target class]));
#endif
                }
            }
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            Class propertyClass = [self classForName:obj];
            
            if (propertyClass == nil) {
                propertyClass = [clazz classForProperty:[obj cStringUsingEncoding:NSASCIIStringEncoding]];
            }
            
            if ([propertyClass class] == [NSArray class]) {
#ifdef OPEN_MAPPING_WARMING
                DDLogWarn(@"Warming - Missing Match: The Class of Property ['%@'] is NSArray, but return class is NSDictionary",obj);
#endif
            }
            if (propertyClass != NULL && [propertyClass class] != [NSDictionary class]) {
                id propertyValue = [DOBase mapping:value forClass:propertyClass];
                @try {
                    if (propertyValue != nil) {
                        [target setValue:propertyValue forKey:obj];                    
                    } else {
#ifdef OPEN_MAPPING_WARMING
                        DDLogVerbose(@"some property is not so normal");
#endif
                    }
                }
                @catch (NSException *exception) {
#ifdef OPEN_MAPPING_WARMING
                    DDLogWarn(@"Warming - Missing Match: The Property ['%@'] is not defined in class ['%s']",obj,class_getName([target class]));
#endif
                }
            } else if ([propertyClass class] == [NSDictionary class]) {
                [target setValue:value forKey:obj];                    
            } else {
                @try {
                    [target setValue:value forUndefinedKey:obj];                    
                }
                @catch (NSException *exception) {
#ifdef OPEN_MAPPING_WARMING
                    DDLogWarn(@"Warming - Missing Match: The Property ['%@'] is not defined or alia defined in class ['%s']",obj,class_getName([target class]));
#endif
                }
            }
        } else {
            @try {
                if (value != nil) {
                    [target setValue:value forKey:obj];                    
                } else {
#ifdef OPEN_MAPPING_WARMING
                    DDLogWarn(@"some property is not so normal");
#endif
                }
            }
            @catch (NSException *exception) {
                @try {
                    [target setValue:value forUndefinedKey:obj];                    
                }
                @catch (NSException *exception) {
#ifdef OPEN_MAPPING_WARMING
                    DDLogWarn(@"Warming - Missing Match: The Property ['%@'] is not defined or alia defined in class ['%s'] ",obj,class_getName([target class]));
#endif
                }
            }
        }
    }
    
    if (target && [target respondsToSelector:@selector(finishMapping)]) {
        [target performSelector:@selector(finishMapping)];
    }
    
    return target;
}

+ (DOBase*) mapping:(id)data forInstance:(DOBase*)target withClass:(Class)clazz {
    NSArray* array = [data allKeys];
//    DOBase* target = [[[[clazz class] alloc]init] autorelease];
    @try {
        if ([target isKindOfClass:[DOBase class]]) {
            target.jsonData = data;
        }
    }
    @catch (NSException *exception) {
    }
    
    
#ifdef DEBUG
    unsigned int outCount;
	objc_property_t* properties = class_copyPropertyList([clazz class], &outCount);
	if (properties) {
		free(properties);
	}
    if (outCount != [array count]) {
#ifdef OPEN_MAPPING_WARMING
        DDLogVerbose(@"Warming - Missing Key Count: The Data has '%lu' properties while '%d' properties in class '%s'",[array count],outCount,class_getName([target class]));
#endif
    }
#endif
    
    for (id obj in array) {
        id value = [data objectForKey:obj];
        
        if ([value isKindOfClass:[NSArray class]]) {
            Class propertyClass = [clazz classForName:obj];
            if (propertyClass == nil) {
                //                DDLogVerbose(@"Warming - Missing Match: The Class of Property ['%@'] is not defined in class '%s'",obj,class_getName([target class]));
                propertyClass = [clazz classForProperty:[obj cStringUsingEncoding:NSASCIIStringEncoding]];
                if (propertyClass != NULL) {
                    @try {
                        if (value != nil) {
                            [target setValue:value forKey:obj];
                        } else {
#ifdef OPEN_MAPPING_WARMING
                            DDLogWarn(@"some property is not so normal");
#endif
                        }
                    }
                    @catch (NSException *exception) {
                        @try {
                            [target setValue:value forUndefinedKey:obj];
                        }
                        @catch (NSException *exception) {
#ifdef OPEN_MAPPING_WARMING
                            DDLogWarn(@"Warming - Missing Match: The Property ['%@'] is not defined or alia defined in class ['%s']",obj,class_getName([target class]));
#endif
                        }
                    }
                }
            } else {
                NSArray* propertyValues = [DOBase mappingList:value forClass:propertyClass];
                @try {
                    [target setValue:propertyValues forKey:obj];
                }
                @catch (NSException *exception) {
#ifdef OPEN_MAPPING_WARMING
                    DDLogWarn(@"Warming - Missing Match: The Property ['%@'] is not defined in class ['%s']",obj,class_getName([target class]));
#endif
                }
            }
        } else if ([value isKindOfClass:[NSDictionary class]]) {
            Class propertyClass = [clazz classForProperty:[obj cStringUsingEncoding:NSASCIIStringEncoding]];
            if ([propertyClass class] == [NSArray class]) {
#ifdef OPEN_MAPPING_WARMING
                DDLogWarn(@"Warming - Missing Match: The Class of Property ['%@'] is NSArray, but return class is NSDictionary",obj);
#endif
            }
            if (propertyClass != NULL && [propertyClass class] != [NSDictionary class]) {
                id propertyValue = [DOBase mapping:value forClass:propertyClass];
                @try {
                    if (propertyValue != nil) {
                        [target setValue:propertyValue forKey:obj];
                    } else {
#ifdef OPEN_MAPPING_WARMING
                        DDLogVerbose(@"some property is not so normal");
#endif
                    }
                }
                @catch (NSException *exception) {
#ifdef OPEN_MAPPING_WARMING
                    DDLogWarn(@"Warming - Missing Match: The Property ['%@'] is not defined in class ['%s']",obj,class_getName([target class]));
#endif
                }
            } else if ([propertyClass class] == [NSDictionary class]) {
                [target setValue:value forKey:obj];
            } else {
                @try {
                    [target setValue:value forUndefinedKey:obj];
                }
                @catch (NSException *exception) {
#ifdef OPEN_MAPPING_WARMING
                    DDLogWarn(@"Warming - Missing Match: The Property ['%@'] is not defined or alia defined in class ['%s']",obj,class_getName([target class]));
#endif
                }
            }
        } else {
            @try {
                if (value != nil) {
                    [target setValue:value forKey:obj];
                } else {
#ifdef OPEN_MAPPING_WARMING
                    DDLogWarn(@"some property is not so normal");
#endif
                }
            }
            @catch (NSException *exception) {
                @try {
                    [target setValue:value forUndefinedKey:obj];
                }
                @catch (NSException *exception) {
#ifdef OPEN_MAPPING_WARMING
                    DDLogWarn(@"Warming - Missing Match: The Property ['%@'] is not defined or alia defined in class ['%s'] ",obj,class_getName([target class]));
#endif
                }
            }
        }
    }
    
    return target;
}

- (void) print:(NSMutableString*) description class:(Class)clazz {
    if ([[clazz superclass] superclass] != nil) {
        [self print:description class:[clazz superclass]];
    }
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(clazz, &outCount);
    for(i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName) {
            NSString *propertyName = [NSString stringWithCString:propName encoding:NSASCIIStringEncoding];
            if ([propertyName isEqualToString:@"raw"]) {
                continue;
            }
            if ([propertyName compare:@"jsonData"] != NSOrderedSame) {
                [description appendString:@"    "];
                [description appendString:propertyName];
                [description appendString:@" = "];
                [description appendFormat:@"%@",[[self valueForKey:propertyName] description]];
                [description appendString:@" \n"];
            }
        }
    }
    free(properties);
}

- (NSString*) description {
    NSMutableString* description = [[[NSMutableString alloc]initWithFormat:@"%s { \n",class_getName([self class])] autorelease];
    
    [self print:description class:[self class]];
    
    [description appendString:@"}"];
    return description;
}

- (void) setValue:(id)value forKey:(NSString *)key {
    Class propertyClass = [[self class] classForProperty:[key cStringUsingEncoding:NSASCIIStringEncoding]];
    if ([propertyClass class] != [value class] && ([propertyClass class] == [NSString class])) {
#warning 非String类型的变量赋值NSString类型的属性
        [super setValue:[NSString stringWithFormat:@"%@",value] forKey:key];
    } else {
        [super setValue:value forKey:key];
    }
}


@end
