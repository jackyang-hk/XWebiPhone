//
//  TBMTOPRequest.h
//  TBMockSDK
//
//  Created by zeha fu on 12-4-12.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequestDelegate.h"
#import "ASIFormDataRequest.h"
#import "MD5EX.h"
#import "JSONKit.h"
#import "TBTop.h"
#import "DOBase.h"


#define USE_BLOCK_JSON_MAPPING 1 //是否使用Block协调json解析性能

@protocol TBTOPRequestDelegate;
@interface TOPRequest : NSObject <ASIHTTPRequestDelegate> {
@public
    ASIHTTPRequest* _dataFormRequest;
    NSDictionary        *responseJSON;
    NSString            *responseString;
    NSData              *responseData;
    id              responseObj;
    
    NSMutableDictionary *_params;

}
/*!
 创建一个指定方法的请求
 @param method 方法名称，例如 com.taobao.items.search
 */
//+ (id)requestWithMethod:(NSString *)method;

/*!
 创建一个指定方法的请求
 @param method 方法名称，例如 com.taobao.items.search
 */
- (id)initWithMethod:(NSString *)method;

/**
 * 初始化完整url
 */
- (id) initWithAbsoluteUrl:(NSString*) absoluteUrl;

/*!
 添加请求参数
 @param param 参数值
 @param key 参数名称
 */
- (void)addParam:(NSObject *)param forKey:(NSString*)key;

/*!
 删除一个请求参数
 @param key 参数名称
 */
- (void)removeParam:(NSString *)key;

//! 给请求签名
- (NSString *)sign;

//! 发送默认请求（异步请求）
- (void)sendRequest;

//! 发送异步请求
- (void) sendAsyncRequest;

//! 发送同步请求
- (TOPRequest*) sendSynchronousRequest ;

//! 取消请求
- (void)cancel;

//! 自定义请求对象，用于在子类中修改请求行为
- (void)customizeRequest:(ASIHTTPRequest *)request;

//! 响应指定的 selector
//- (void)responseSelector:(SEL)selector;

//! 判断session是否过期
//{
//    "error_response": {
//        "code": 27,
//        "msg": "Invalid session",
//        "sub_code": "sessionkey-not-generated-by-server",
//        "sub_msg": "RealSession don&apos;t belong app and user ! appKey is : 12610510 , user id is : 63812345"
//    }
//}
- (BOOL)isTopSessionInvalid;

//! 判断是否没有session
//{
//    "error_response": {
//        "code": 26,
//        "msg": "Missing session"
//    }
//}
- (BOOL)isTopMissingSession;

//! 调用成功的 selector
- (void)responseSuccess;

//! 调用失败的 selector
- (void)responseFailed;

//! 添加一条跟踪记录
//- (void)addTraceRecord;

//! 将 NSDictionary 转换为查询字符串
//- (NSString *)dictToQueryString:(NSDictionary *)dict;

//! 获取请求所用的数据
//- (NSDictionary *)dataForRequest;

//! 获取请求的目标 URL
//- (NSString *)urlForRequest;

//! 获取使用 GET 方式时的请求 URL
//- (NSString *)urlForGetRequest;

//!在发送请求时，retain delegate
//- (void)retainDelegate;

//!请求完成后，release delegate
//- (void)releaseDelegate;

//! 请求调用的Host
- (NSString*) requestHost;

- (void) prepareCommonParams;

- (NSURL*) requestURL;

- (DOBase*) mappingResponseJson:(NSDictionary*)jsonResponse;

//! 完整请求URL，如果有，则替代apimethod，只使用加参和加密
@property (nonatomic, strong)   NSString *absoluteUrl;

//! API 请求的方法
@property (nonatomic, strong)   NSString *apiMethod;

/*! 是否使用 POST 方式发送请求 */
@property (nonatomic) BOOL usePOST;

/*! 登录之后获取的ecode */
@property (nonatomic, strong) NSString* ecode;

//! 是否需要用户的session
@property (nonatomic) BOOL needsUserSession;

/*! 回调 delegate 对象 */
@property (nonatomic, weak) id delegate;

/*! 请求的参数 */
@property (nonatomic, strong) NSMutableDictionary *params;

/*! 请求失败时的 selector，默认为 tbRequestFailed: */
@property (nonatomic) SEL requestDidFailedSelector;

/*! 请求成功时的 selector，默认为 tbRequestSuccess: */
@property (nonatomic) SEL requestDidFinishSelector;

/*! 自定义用户数据 */
//@property (nonatomic, retain) NSDictionary *userInfo;

/*! JSON 格式的请求响应数据 */
@property (nonatomic, strong) NSDictionary *responseJSON;

/*! NSData 对象的请求响应数据 */
@property (nonatomic, strong) NSData *responseData;

/*! NSString 对象的请求响应数据 */
@property (nonatomic, strong) NSString *responseString;

/*! DOBase 对象的业务解析数据 */
@property (nonatomic, strong) DOBase *responseObj;

/*! 请求的错误 */
//@property (nonatomic, retain) TBErrorResponse *responseError;

/*! 发送请求时的数据 */
@property (nonatomic, strong) NSString *sentData;

//! 请求时使用同步请求
//@property (nonatomic, assign) BOOL  useSynchronousRequest;

//! 请求协议版本号
@property (nonatomic, strong) NSString* v;

@property (nonatomic) int requestTimeout;
/*! 重试次数 */
@property (nonatomic) int repeatCount;

@property (nonatomic) BOOL disableCache;

@property (nonatomic, strong) NSString* sequence;

@property (nonatomic, strong) NSString* backFunction;


@end

@protocol TBTOPRequestDelegate <NSObject>

@required
- (void) requestDidFinished:(TOPRequest*)request;

- (void) requestDidFailed:(TOPRequest*)request;

@end
