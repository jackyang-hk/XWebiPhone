//
//  TBTop.h
//  TBMockSDK
//
//  Created by zeha fu on 12-4-15.
//  Copyright (c) 2012年 Taobao.com. All rights reserved.
//

#import <Foundation/Foundation.h>



#define kUserIconPathNotificationLoaded @"kUserIconPathNotificationLoaded"
#define kSessionNotificationLoaded @"kSessionNotificationLoaded"

typedef enum _REQUEST_HOST { 
    RELEASE_REQUEST = 0,
    PRERELEASE_REQUEST = 1,
    DAILY_REQUEST = 2
} REQUEST_HOST_MODE;


void TBSetTOPAppKeyWithSecret(NSString *key, NSString *secret);

@class TBLoginResult;
@interface TBTop : NSObject

+ (TBTop*)sharedInstance;

//服务器同步的当前时间
+ (NSDate *)timestampSync;

/*! 获取当然的时间戳 For MTOP */
+ (NSString *)timestampForMTop;

/*! 获取当然的时间戳 */
+ (NSString*) timestamp;

+ (NSString*) imei;

+ (NSString*) imsi;

+ (NSString *) getMacAddressString;

/*! 获取当前是否已经有用户登录 */
+ (BOOL)isLoggedIn;

/*! 清除会话 */
+ (void)clearSession;

/*! 重置登录信息 */
+ (void) resetUserAccount;

+ (void) setUserSession:(TBLoginResult*) loginResult ;

/*! 当前会话的 TOP sesssion id */
@property (nonatomic, retain) NSString* session;

/*!*/
@property (nonatomic, retain) NSString* community;
@property (nonatomic, retain) NSString* communityId;


@property (nonatomic, retain) NSString* mobile;

@property (nonatomic, retain) NSArray* cookies;

/*! 当前会话的 TOP ecode*/
@property (nonatomic, retain) NSString* ecode;

/*! 当前会话的 TOP ecode*/
@property (nonatomic, retain) NSString* token;

/*! 当前会话的 TOP ecode*/
@property (nonatomic, retain) NSString* userId;

/*! 当前会话的无线 session id */
@property (nonatomic, retain) NSString* wapSID;

//! 登录时得到的 ecode
@property (nonatomic, retain) NSString* wapECode;

/*! 当前登录用户的 userNick */
@property (nonatomic, retain) NSString* usernick;

/*! 当前登录用户的 password */
@property (nonatomic, retain) NSString* password;

/*! 无线埋点的 ttid */
@property (nonatomic, retain) NSString* wapTTID;


/*! TOP API 的请求地址 */
@property (nonatomic, retain) NSString* topAPIURL;

/*! 无线 MTOP API 的请求地址 */
@property (nonatomic, retain) NSString* wapAPIURL;

/*! 程序的 TOP App Key */
@property (nonatomic, retain) NSString* appKey;

/*!
 获取程序的 TOP App Secretcode
 */
@property (nonatomic, retain) NSString* secretCode;

@property (nonatomic, assign) BOOL sessionRunLoopSync;

@property (nonatomic, retain) NSString* topSession;
- (void)setSession_raw:(NSString *)newTopSession;       // 专门未自动登陆宏使用，不会出发群发消息

@property (nonatomic, retain) NSString* userIconPath;

@property (nonatomic, assign) BOOL isSupportSchedule;


/*! 设置App 网络层参数 */
+ (void) configAppNetEnvSetting ;

/*! 获取本地时间与服务器的时间差 */
+ (void)fetchServerTimeInterval;

/*! 获取支付宝无线的 host */
//+ (NSString *)alipayHost;

//! 无线站点的host
//+ (NSString *)wapSiteHost;

//! 无线搜索的host
//+ (NSString *)wapSearchHost;

//! 设置支付宝客户端标识
//+ (void)setAlipayClientSignature:(NSString *)sign;

//! 获取当前的支付宝客户端标识
//+ (NSString *)alipayClientSignature;

/*! 根据支付宝交易号获取支付页面的URL */
+ (NSString *)tradePayURL:(NSString *) alipay_no;
/*! 根据批量支付宝交易号获取支付页面的URL */
+ (NSString*) batchPayURL:(NSArray*)alipay_nos;

+ (NSString *)confirmGoodsURL:(NSString *)alipay_no;

/*! 根据支付宝晩号获取确认付款页面的URL */
//+ (NSString *)confirmGoodsURL:(NSString *)alipay_no;

//! 获取购物车批量付款链接
//+ (NSString *)batchPayURL:(NSArray *)tradeIds;

+ (NSString *)topHostURL;

+ (NSString*) mtopHostURL;

+ (REQUEST_HOST_MODE) getCurrentRequestHostMode ;

+ (void) setCurrentRequestHostMode :(REQUEST_HOST_MODE) mode ;

- (NSString*) phoneNumberForCurrentUser ;

- (void) setPhoneNumberForCurrentUser:(NSString*)phoneNumber;

- (NSString*) schedulePhoneNumberForCurrentUser ;

- (void) setSchedulePhoneNumberForCurrentUser:(NSString*)phoneNumber ;

- (void) updateUserCookies ;

// 获取UUID
+ (NSString*) getUniqueIdentifierForVendor ;

+ (NSString*) getLat;

+ (NSString*) getLng;

+ (NSString*) constructUA ;

@end
