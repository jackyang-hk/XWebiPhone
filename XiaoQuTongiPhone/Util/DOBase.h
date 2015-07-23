//
//  DOBase.h
//  JHS
//
//  Created by zeha fu on 12-4-5.
//  Copyright (c) 2012年 ju.taobao.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DOBase : NSObject

@property (nonatomic, retain) NSDictionary* jsonData;

+ (NSArray*) mappingList:(id)list;

//自定义mapping需要继承
+ (DOBase*) mapping:(id)directory;

+ (DOBase*) mapping:(id)data forInstance:(DOBase*)target withClass:(Class)clazz ;

//如有 NSArray or NSMutableArray 属性，需要子类继承
+ (Class) classForName:(NSString*) name;

//KVO继承
- (NSArray *)observableKeypaths ;

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context ;

@end
