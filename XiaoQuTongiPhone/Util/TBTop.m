//
//  TBTop.m
//  TBMockSDK
//
//  Created by zeha fu on 12-4-15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "TBTop.h"
#import "MD5.h"
#import <sys/socket.h> 
#import <sys/sysctl.h>
#import <net/if.h>
#import <net/if_dl.h>
//#import "TBLoginResult.h"
#import "Reachability.h"
#import "TOPRequest.h"
#import "NSDate+Formatter.h"
#import "JULocationManager.h"
#import "TBStoredData.h"
#import "RegexKitLite.h"
//#import "TBTopIsScheduleSupportRequest.h"
#import "TaobaoTFS.h"
#import "JUSDKJUWebUtile.h"
#import "UMessage.h"
#import "SFHFKeychainUtils.h"

void TBSetTOPAppKeyWithSecret(NSString *key, NSString *secret){
    [TBTop sharedInstance].appKey = key;
    [TBTop sharedInstance].secretCode = secret;
}


@implementation TBTop

@synthesize appKey = _appKey;
@synthesize secretCode = _secretCode;
@synthesize session = _session;
@synthesize community = _community;
@synthesize communityId = _communityId;
@synthesize mobile = _mobile;
@synthesize ecode = _ecode;
@synthesize token = _token;
@synthesize wapSID = _wapSID;
@synthesize wapTTID = _wapTTID;
@synthesize usernick = _usernick;
@synthesize password = _password;
@synthesize userId = _userId;
@synthesize wapECode = _wapECode;
@synthesize topAPIURL = _topAPIURL;
@synthesize wapAPIURL = _wapAPIURL;
@synthesize sessionRunLoopSync = _sessionRunLoopSync;
@synthesize topSession = _topSession;
@synthesize userIconPath = _userIconPath;
@synthesize cookies = _cookies;
@synthesize isSupportSchedule = _isSupportSchedule;

- (void) dealloc {
    self.appKey = nil;
    self.secretCode = nil;
    self.session = nil;
    self.community = nil;
    self.communityId = nil;
    self.mobile = nil;
    self.ecode = nil;
    self.token = nil;
    self.wapSID = nil;
    self.wapTTID = nil;
    self.usernick = nil;
    self.password = nil;
    self.userId = nil;
    self.wapECode = nil;
    self.topAPIURL = nil;
    self.wapAPIURL = nil;
    self.topSession = nil;
    self.userIconPath = nil;
    [super dealloc];
}

static NSString* USERNICK_KEY = @"USERNICK_KEY";
static NSString* PASSWORD_KEY = @"PASSWORD_KEY";

static int          timestampOffset = 0;

//// ------ custom private method
//
//+ (void) configUserTrackSDK
//{
//    NSString * version = [TBUserTrack userTrackSDKVersion];
//    NSLog(@"UserTrackSDK version: %@", version);
//    
//    int mode = [TBTop getCurrentRequestHostMode];
//    if (mode == DAILY_REQUEST)
//    {
//        [TBUserTrack setTOPAppKeyAndAppSecret:APP_KEY_DAILY_MODE_USERTRACK_SDK secret:APP_SECRET_DAILY_MODE_USERTRACK_SDK];
//    }
//    else if (mode == PRERELEASE_REQUEST)
//    {
//        [TBUserTrack setTOPAppKeyAndAppSecret:APP_KEY_PRERELEASE_MODE secret:APP_SECRET_PRERELEASE_MODE];
//    }
//    else
//    {
//        [TBUserTrack setTOPAppKeyAndAppSecret:APP_KEY_RELEASE_MODE secret:APP_SECRET_RELEASE_MODE];
//    }
//        
//    [TBUserTrack setChannel:[[TBTop sharedInstance] wapTTID]];
//    [TBUserTrack setGlobalNavigationTrackEnabled:YES];
//}


+ (void) configAppNetEnvSetting {
    //set the app key ,app secret & ttid 顺序不可调换
    
    int mode = [TBTop getCurrentRequestHostMode];
    if (mode == DAILY_REQUEST) {
        TBSetTOPAppKeyWithSecret(APP_KEY_DAILY_MODE, APP_SECRET_DAILY_MODE);
    } else if (mode == PRERELEASE_REQUEST) {
        TBSetTOPAppKeyWithSecret(APP_KEY_PRERELEASE_MODE, APP_SECRET_PRERELEASE_MODE);
    } else {
        TBSetTOPAppKeyWithSecret(APP_KEY_RELEASE_MODE, APP_SECRET_RELEASE_MODE);
    }
    
//    [[TBTop sharedInstance] setWapTTID:g_appTTID];
    
    //设置 app key/app secret － userTrackSDK
//    [TBTop configUserTrackSDK];
}



- (void) setUsernick:(NSString *)userNick {
    if (_usernick != userNick) {
        [_usernick release];
        _usernick = [userNick retain];
        TBSessionSetStoredUsername(_usernick);
    }
}

- (void) setPassword:(NSString *)password {
    if (_password != password) {
        [_password release];
        _password = [password retain];
        TBSessionSetStoredPassword(_password);
    }
}

- (NSString*) usernick {
    if (_usernick == nil) {
        _usernick = [TBSessionGetStoredUsername() retain];
    }
    return _usernick;
}

- (NSString*) password {
    if (_password == nil) {
        _password = [TBSessionGetStoredPassword() retain];
    }
    return _password;
}

- (NSString*) phoneNumberForCurrentUser {
    id phone = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-PhoneNumber",[self usernick]]];
    
    if (phone == nil) {
        if ([[self usernick] isMatchedByRegex:@"^(13|15|14|18)([0-9]{9})$"]) {
            return [self usernick];
        }
        return nil;
    }
    
    return phone;
}

- (void) setPhoneNumberForCurrentUser:(NSString*)phoneNumber {
    [[NSUserDefaults standardUserDefaults] setObject:phoneNumber forKey:[NSString stringWithFormat:@"%@-PhoneNumber",[self usernick]]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSString*) schedulePhoneNumberForCurrentUser {
    id phone = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@-SchedulePhoneNumber",[self usernick]]];
    
    if (phone == nil) {
        if ([[self usernick] isMatchedByRegex:@"^(13|15|14|18)([0-9]{9})$"]) {
            return [self usernick];
        }
        return nil;
    }
    
    return phone;
}

- (void) setSchedulePhoneNumberForCurrentUser:(NSString*)phoneNumber {
    [[NSUserDefaults standardUserDefaults] setObject:phoneNumber forKey:[NSString stringWithFormat:@"%@-SchedulePhoneNumber",[self usernick]]];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void) resetUserAccount {
    
    [JUSDKJUWebUtile deleteHttpCookies];
    
    TBSessionClearTOPSession();
    [TBTop sharedInstance].usernick = nil;
    [TBTop sharedInstance].userId = nil;
    [TBTop sharedInstance].session = nil;
    [TBTop sharedInstance].userIconPath = nil;
    [TBTop sharedInstance].password = nil;
    [TBTop sharedInstance].topSession = nil;
    
}

+ (TBTop*)sharedInstance {            
    static TBTop* kInstance = nil; 
    
    if (!kInstance) {                    
        kInstance = [[self alloc] init];    
    }                                    
    
    return kInstance;                     
}

+ (void)fetchServerTimeInterval {
    if ([[Reachability reachabilityForInternetConnection] isReachable]) {
        TOPRequest *request = [[TOPRequest alloc] initWithMethod:@"taobao.time.get"];
        request.delegate = self;
        request.requestDidFinishSelector = @selector(serverTimeRequestFinished:);
        request.requestDidFailedSelector = @selector(serverTimeRequestFailed:);
        [request sendRequest];
        
    } else {
        [self performSelector:@selector(fetchServerTimeInterval) withObject:nil afterDelay:5];
    }
}

+ (void)serverTimeRequestFinished:(TOPRequest *)request {
    NSString *serverTimeStr = [request.responseJSON valueForKeyPath:@"time_get_response.time"];
    if ([serverTimeStr length] == 19) {
        NSString    *serverTimeWithTimeZone = [[NSString alloc] initWithFormat:@"%@ +0800",serverTimeStr];
        NSDate *serverTime = [NSDate dateFromString:serverTimeWithTimeZone withFormat:@"yyyy-MM-dd HH:mm:ss zzz" locale:[NSLocale systemLocale]];
        [serverTimeWithTimeZone release];
        NSDate *now = [NSDate date];
        timestampOffset = [serverTime timeIntervalSinceDate:now];
        NSLog(@"serverTime:%@,now:%@",serverTime,now);
        NSLog(@"Local time and server time interval: %d", timestampOffset);
    }
    RELEASE_SAFELY(request);
}

+ (void)serverTimeRequestFailed:(TOPRequest *)request {
    RELEASE_SAFELY(request);
}

+ (NSDate *)timestampSync {
    return [NSDate date];
}

+ (NSString*) timestampForMTop{
    return [NSString stringWithFormat:@"%0.0f",[[TBTop timestampSync] timeIntervalSince1970]];
}

+ (NSString*) timestamp {
    static NSDateFormatter* formatter = nil;
    if (formatter == nil) {
        formatter = [[NSDateFormatter alloc]init];
        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    }
    return [formatter stringFromDate:[TBTop timestampSync]];
}

+ (NSString*) imei
{
    static NSString * theIMEI = nil;
    if (theIMEI == nil)
    {
        theIMEI = [[NSString alloc] initWithString:[MD5 md5_string:[TBTop getMacAddressString]]];
    }
    return theIMEI;
}

+ (NSString*) imsi
{
    static NSString * theIMSI = nil;
    if (theIMSI == nil)
    {
        theIMSI = [[NSString alloc] initWithString:[MD5 md5_string:[TBTop getMacAddressString]]];
    }
    
    return theIMSI;
}

+ (NSString *) getMacAddressString
{
	int                    mib[6];
	size_t                len;
	char                *buf;
	unsigned char        *ptr;
	struct if_msghdr    *ifm;
	struct sockaddr_dl    *sdl;
	
	mib[0] = CTL_NET;
	mib[1] = AF_ROUTE;
	mib[2] = 0;
	mib[3] = AF_LINK;
	mib[4] = NET_RT_IFLIST;
	
	if ((mib[5] = if_nametoindex("en0")) == 0) {
		printf("Error: if_nametoindex error/n");
		return NULL;
	}
	
	if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
		printf("Error: sysctl, take 1/n");
		return NULL;
	}
	
	if ((buf = malloc(len)) == NULL) {
		printf("Could not allocate memory. error!/n");
		return NULL;
	}
	
	if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
		printf("Error: sysctl, take 2");
		free(buf);
		return NULL;
	}
	
	ifm = (struct if_msghdr *)buf;
	sdl = (struct sockaddr_dl *)(ifm + 1);
	ptr = (unsigned char *)LLADDR(sdl);
	NSString *outstring = [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
	free(buf);
	return [outstring uppercaseString];
}

+ (BOOL) isLoggedIn {
    return [TBTop sharedInstance].session != nil? YES:NO;
}

+ (void) clearSession {
    [TBTop sharedInstance].session = nil;
}

- (void) setUserIconPath:(NSString *)userIconPath {
    if (_userIconPath != userIconPath) {
        [_userIconPath release];
        _userIconPath = [userIconPath retain];
        
//        NSNotification* notification = [NSNotification notificationWithName:kUserIconPathNotificationLoaded
//																	 object:self
//																   userInfo:nil];
//        [[NSNotificationCenter defaultCenter] performSelectorOnMainThread:@selector(postNotification:) withObject:notification waitUntilDone:NO];
        [[NSNotificationCenter defaultCenter] postNotificationName:kUserIconPathNotificationLoaded object:nil];
    }
}

- (void)setSession_raw:(NSString *)newTopSession;       // 专门未自动登陆宏使用，不会触发群发消息
{
    if (_topSession != newTopSession) {
        [_topSession release];
        _topSession = [newTopSession retain];
//        self.userIconPath = nil;
    }
}

- (void) setTopSession:(NSString *)topSession {
    if (_topSession != topSession) {
        [self setSession_raw:topSession];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSessionNotificationLoaded object:nil];
    }
}

+ (void) setUserSession:(TBLoginResult*) loginResult {
//    [TBTop sharedInstance].session = loginResult.data.sid;
//    [TBTop sharedInstance].ecode = loginResult.data.ecode;
//    [TBTop sharedInstance].userId = loginResult.data.userId;
//    [TBTop sharedInstance].usernick = loginResult.data.nick;
//    [TBTop sharedInstance].token = loginResult.data.token;
//    [TBTop sharedInstance].topSession = loginResult.data.topSession;
}

+ (NSString *)alipayHost {
    int mode = [TBTop getCurrentRequestHostMode];
    if (mode == DAILY_REQUEST) {
        return ALIPAY_HOST_DAILY_MODE; //@"http://mali.alipay.net";
    } else if (mode == PRERELEASE_REQUEST) {
        return ALIPAY_HOST_PRERELEASE_MODE; //@"http://mali.alipay.com";
    } else {
        return ALIPAY_HOST_RELEASE_MODE; //@"http://mali.alipay.com";
    }
    
//    return ALIPAY_HOST;
}

+ (NSString *)tradePayURL:(NSString *)alipay_no {
    return [NSString stringWithFormat:@"%@/w/trade_pay.do?refer=tbc%@&alipay_trade_no=%@&s_id=%@",
            [self alipayHost],
            [TBTop sharedInstance].wapTTID ?: @"",
            alipay_no,
            [TBTop sharedInstance].session];
}

+ (NSString*) batchPayURL:(NSArray*)alipay_nos {
    return [NSString stringWithFormat:@"%@/batch_payment.do?refer=tbc%@&trade_nos=%@&s_id=%@",
            [self alipayHost],
            [TBTop sharedInstance].wapTTID ?: @"",
            [alipay_nos componentsJoinedByString:@","],
            [TBTop sharedInstance].session];
}

+ (NSString *)confirmGoodsURL:(NSString *)alipay_no {
    return [NSString stringWithFormat:@"%@/w/confirmGoods.do?refer=tbc%@&alipay_trade_no=%@&s_id=%@",
            [self alipayHost],
            [TBTop sharedInstance].wapTTID ?: @"",
            alipay_no,
            [TBTop sharedInstance].session];
}

+ (NSString *)topHostURL {
    int mode = [TBTop getCurrentRequestHostMode];
    if (mode == DAILY_REQUEST) {
        return TOP_HOST_URL_DAILY_MODE; //@"http://api.daily.taobao.net/router/rest";
    } else if (mode == PRERELEASE_REQUEST) {
        return TOP_HOST_URL_PRERELEASE_MODE; //@"http://110.75.14.63/top/router/rest";
    } else {
        return TOP_HOST_URL_RELEASE_MODE; //@"http://gw.api.taobao.com/router/rest";
    }
    
//    return TOP_HOST_URL;
}

+ (NSString*) mtopHostURL {
    int mode = [TBTop getCurrentRequestHostMode];
    if (mode == DAILY_REQUEST) {
        return MTOP_HOST_URL_DAILY_MODE; //@"http://api.waptest.taobao.com/rest/api3.do";
    } else if (mode == PRERELEASE_REQUEST) {
        return MTOP_HOST_URL_PRERELEASE_MODE; //@"http://api.wapa.taobao.com/rest/api3.do";
    } else {
        return MTOP_HOST_URL_RELEASE_MODE; //@"http://api.m.taobao.com/rest/api3.do";
    }
    
//    return MTOP_HOST_URL;
}


#define K_REUQEST_MODE @"K_REUQEST_MODE"

+ (REQUEST_HOST_MODE) getCurrentRequestHostMode {
#ifdef RELEASE_MODE
    return RELEASE_REQUEST;
#else
    
    id o_mode = [[NSUserDefaults standardUserDefaults] objectForKey:K_REUQEST_MODE];
    if (o_mode) {
        
        if ([o_mode intValue] == DAILY_REQUEST) {
            return DAILY_REQUEST;
        } else if ([o_mode intValue] == PRERELEASE_REQUEST) {
            return PRERELEASE_REQUEST;            
        } else {
            return RELEASE_REQUEST;
        }
        
    } else {
        
#ifdef DAILY_MODE
        return DAILY_REQUEST;
#elif PRERELEASE_MODE
        return PRERELEASE_REQUEST;
#else 
        return RELEASE_REQUEST;
#endif
        
    }
    
#endif
}

+ (void) setCurrentRequestHostMode :(REQUEST_HOST_MODE) mode {
    if (mode == DAILY_REQUEST) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%i",2] forKey:K_REUQEST_MODE];
    } else if (mode == PRERELEASE_REQUEST) {
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%i",1] forKey:K_REUQEST_MODE];
    } else {
        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%i",0] forKey:K_REUQEST_MODE];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    [TBTop configAppNetEnvSetting];
    [TBTop resetUserAccount];
	[TaobaoTFS resetServers];
}

//闪电购新增
#pragma mark -
#pragma mark Get/Set user default city

- (NSString *)userDefault:(NSString*)key {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    return [defaults valueForKey:key];
}


- (void)updateUserDefaultKey:(NSString *)key value:(NSString*) value {
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:value forKey:key];
    [defaults synchronize];
}

- (void) setSession:(NSString *)session {
    if (_session != session) {
        [_session release];
        _session = [session retain];
        [self updateUserDefaultKey:@"shequtong_session" value:session];
    }
}

- (NSString *) session {
    if (_session == nil) {
        _session = [[self userDefault:@"shequtong_session"] retain];
    }
    return _session;
}

- (void) setUserId:(NSString *)userId {
    if (_userId != userId) {
        [_userId release];
        _userId = [userId retain];
        [self updateUserDefaultKey:@"shequtong_userId" value:userId];
    }
}

- (NSString *) userId {
    if (_userId == nil) {
        _userId = [[self userDefault:@"shequtong_userId"] retain];
    }
    return _userId;
}

- (NSArray*) cookies {
    if (_cookies == nil) {
    //todo 先不管存储
        _cookies = [[[self userDefault:@"shequtong_cookies"] objectFromJSONStringWithParseOptions:JKParseOptionLooseUnicode] retain];
    }
    return _cookies;
}

- (void) setCookies:(NSArray*) cookies {
    if (_cookies != cookies) {
        [_cookies release];
        _cookies = [cookies retain];
            //todo 先不管存储
        NSMutableArray* cookieArray = [[NSMutableArray alloc]init];
        for (NSString* cookie in cookies) {
            [cookieArray addObject:cookie];
        }
    
        NSError* error = nil;
        id result = [NSJSONSerialization dataWithJSONObject:cookieArray
                                        options:kNilOptions error:&error];
        NSString *jsonString = [[NSString alloc] initWithData:result
                                                     encoding:NSUTF8StringEncoding];
        
        [self updateUserDefaultKey:@"shequtong_cookies" value:jsonString];
        
        [self updateUserCookies];
    }
}

- (void) setCommunity:(NSString *)community {
    if (_community != community) {
        [_community release];
        _community = [community retain];
        [self updateUserDefaultKey:@"shequtong_community" value:community];
        [UMessage addTag:community
                response:^(id responseObject, NSInteger remain, NSError *error) {
                    //add your codes
                }];
    }
}

- (NSString *) community {
    if (_community == nil) {
        _community = [[self userDefault:@"shequtong_community"] retain];
    }
    return _community;
}

- (void) setCommunityId:(NSString *)communityId {
    if (_communityId != communityId) {
        [_communityId release];
        _communityId = [communityId retain];
        [self updateUserDefaultKey:@"shequtong_communityId" value:_communityId];
    }
}

- (NSString *) communityId {
    if (_communityId == nil) {
        _communityId = [[self userDefault:@"shequtong_communityId"] retain];
    }
    return _communityId;
}

- (void) setMobile:(NSString *)mobile {
    if (_mobile != mobile) {
        NSString* oldMobile = [self mobile];
        
        if (![oldMobile isEqualToString: mobile]) {
            [self performSelector:@selector(updateTokenToServer) withObject:nil afterDelay:2];
        }
        
        [_mobile release];
        _mobile = [mobile retain];
        [self updateUserDefaultKey:@"shequtong_mobile" value:mobile];
    }
}

- (NSString *) mobile {
    if (_mobile == nil) {
        _mobile = [[self userDefault:@"shequtong_mobile"] retain];
    }
    return _mobile;
}

- (NSString*) token {
    if (_token == nil) {
        _token = [[self userDefault:@"shequtong_token"] retain];
    }
    return _token;
}

- (void) setToken:(NSString *)token {
    if (_token != token) {
        NSString* oldToken = [self token];
        if (![oldToken isEqualToString:token]) {
            [self performSelector:@selector(updateTokenToServer) withObject:nil afterDelay:2];
        }
        [_token release];
        _token = [token retain];
        [self updateUserDefaultKey:@"shequtong_token" value:token];
    }
}

- (void) updateTokenToServer {
    if ([TBTop sharedInstance].token == nil) {
        return;
    }
    
#ifdef DAILY
    NSString* base = @"http://daily.52shangou.com/msgcenter/appcheck";
#elif GRAY
    NSString* base = @"http://gray.52shangou.com/msgcenter/appcheck";
#else
    NSString* base = @"http://www.52shangou.com/msgcenter/appcheck";
#endif
    
    NSString* url = nil;
    if ([TBTop sharedInstance].mobile != nil) {
        url = [NSString stringWithFormat:@"%@?mobile=%@&deviceId=%@&identity=%d&apple_token=%@&longitude=%f&latitude=%f",base,[TBTop sharedInstance].mobile,[TBTop getUniqueIdentifierForVendor],APPTYPE,[TBTop sharedInstance].token,[JULocationManager sharedInstance].latestLocation.coordinate.longitude,[JULocationManager sharedInstance].latestLocation.coordinate.latitude];
    } else {
        url = [NSString stringWithFormat:@"%@?deviceId=%@&identity=%d&apple_token=%@&longitude=%f&latitude=%f",base,[TBTop getUniqueIdentifierForVendor],APPTYPE,[TBTop sharedInstance].token,[JULocationManager sharedInstance].latestLocation.coordinate.longitude,[JULocationManager sharedInstance].latestLocation.coordinate.latitude];
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:url]];
    [request setCachePolicy:NSURLRequestReloadIgnoringCacheData];
    [NSURLConnection connectionWithRequest:request delegate:nil];
}

- (void)updateUserCookies {
    [JUSDKJUWebUtile deleteHttpCookies];
    [JUSDKJUWebUtile updateHttpCookies];
}

+ (NSString*) getUniqueIdentifierForVendor {
    //Identify Save For Keychain
    NSError* error;
    NSString* identify = [SFHFKeychainUtils getPasswordForUsername:@"identifierForVender" andServiceName:@"shandiangou" error:&error];
    if (identify == nil) {
        identify = [[[UIDevice currentDevice] identifierForVendor] UUIDString];;
        [SFHFKeychainUtils storeUsername:@"identifierForVender" andPassword:identify forServiceName:@"shandiangou" updateExisting:YES error:&error];
    }
    return identify;
}

+ (NSString*) getLat {
    NSString *lat = [NSString stringWithFormat:@"%f",[JULocationManager sharedInstance].latestLocation.coordinate.latitude] ;
    return lat;
}

+ (NSString*) getLng {
    NSString *lng = [NSString stringWithFormat:@"%f",[JULocationManager sharedInstance].latestLocation.coordinate.longitude] ;
    return lng;
}

+ (NSString*) constructUA {
    NSMutableDictionary* uainfo = [[NSMutableDictionary alloc]init];
    
    //app version
    NSString *version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [uainfo setObject:version forKey:@"appVersion"];
    
    //系统信息
    UIDevice *device =[[UIDevice alloc] init];
    [uainfo setObject:device.name forKey:@"deviceName"];
    [uainfo setObject:device.systemName forKey:@"systemName"];
    [uainfo setObject:device.systemVersion forKey:@"systemVersion"];
    
    [uainfo setObject:@"2.4" forKey:@"bridgeLibVersion"];
    //2.4：完善缓存系统、黑白名单、失效时间、bug处理、MD5校验、域名配置；App唤醒事件；App激活之前中断的渲染流程；唯一识别码函数，（keychain）；基于缓存的Bridge方案，iConsole；
    //2.1：支付返回增加状态参数、增加网络异常情况处理、增加清除缓存处理、缓存系统处理
    //2.0：微信支付、支付宝支付V2、cookie丢失问题处理、百度定位SDK、WebView JS|CSS|PNG|JPG Cache
    //1.9：支付宝支付V1
    
    //渠道
    [uainfo setObject:@"appStore" forKey:@"ttid"];
    //种类
    [uainfo setObject:@"buyer" forKey:@"appType"];
    
   
    //设置App唯一码
    [uainfo setObject:[self getUniqueIdentifierForVendor] forKey:@"udid"];
    

    //792FF7DE-3284-46D7-B761-ECFA87CD61FF
    NSMutableString* ua = [[NSMutableString alloc]init];
    [ua appendString:@" "];
    for (NSString* key in [uainfo allKeys]) {
        [ua appendString:[NSString stringWithFormat:@"%@(%@) ",key,[[uainfo objectForKey:key] stringByURLEncodingStringParameter]]];
    }
    [ua appendString:@" "];
    
    return ua;
}


@end
