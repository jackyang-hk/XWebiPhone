//
//  TBModel.h
//  TBSDK
//
//  Created by Xu Jiwei on 10-6-10.
//  Copyright 2010 Taobao.com. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 TOP 数据的基类
 */
@interface TBModel : NSObject <NSCoding> {

}

/**
 创建一个 TBModel 实例
 */
+ (id)model;

/**
 使用一个 JSON 来创建 TBModel 实例
 @param json 以 NSDictionary 表示的 JSON 对象
 */
+ (id)modelWithJSON:(NSDictionary*)json;

/**
 使用一个数组类型的 JSON 来创建 TBModel 数组
 @param jsonArray 以 NSArray 表示的 JSON 数组对象
 */
+ (NSArray *)modelArrayWithJSON:(NSArray *)jsonArray;

/**
 使用 JSON 初始化一个 TBModel 实例
 @param dict 以 NSDictionary 表示的 JSON 对象
 */
- (id)initWithDictionary:(NSDictionary *)dict;

/**
 获取对应属性的类型，用于在属性值为一个 NSDictionary 或者 NSArray 时来正确创建属性的对象
 @param key 对应属性的名称
 */
- (Class)classForKey:(NSString*)key;

/**
 从一个 JSON Dictionary 设置 TBModel 的属性
 @param dict 以 NSDictionary 表示的 JSON 对象
 */
- (void)setFromDictionary:(NSDictionary*)dict;

/**
 该 TBModel 所拥有的属性名称列表
 */
- (NSArray *)keys;

/**
 将 TBModel 转换为一个 NSDictaionry
 */
- (NSDictionary*)toDictionary;

@end
