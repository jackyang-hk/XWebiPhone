//
//  JUDef.h
//  JU
//
//  Created by HuiChen on 12-6-18.
//  Copyright (c) 2012年 ju.taobao.com. All rights reserved.
//

#ifndef JU_JUDef_h
#define JU_JUDef_h

//=============环境相关宏=================
//正式环境
#define RELEASE_MODE 1

//预发环境
//#define PRERELEASE_MODE 1

//Daily环境
//#define DAILY_MODE 1

//#ifdef RELEASE_MODE
//正式环境
#define TOP_HOST_URL_RELEASE_MODE       @"http://gw.api.taobao.com/router/rest"
#define MTOP_HOST_URL_RELEASE_MODE      @"http://api.m.taobao.com/rest/api3.do"
#define ALIPAY_HOST_RELEASE_MODE        @"http://mali.alipay.com"

#define WAP_SITE_HOST_RELEASE_MODE      @"wap.taobao.com"
#define WAP_SEARCH_HOST_RELEASE_MODE    @"s.m.taobao.com"


//#elif PRERELEASE_MODE
//预发环境
#define TOP_HOST_URL_PRERELEASE_MODE    @"http://110.75.14.63/top/router/rest"
#define MTOP_HOST_URL_PRERELEASE_MODE   @"http://api.wapa.taobao.com/rest/api3.do"
#define ALIPAY_HOST_PRERELEASE_MODE     @"http://mali.alipay.com"

#define WAP_SITE_HOST_PRERELEASE_MODE   @"wapa.taobao.com"
#define WAP_SEARCH_HOST_PRERELEASE_MODE @"s.wapa.taobao.com"

//#elif DAILY_MODE
//日常环境
#define TOP_HOST_URL_DAILY_MODE         @"http://api.daily.taobao.net/router/rest"
//#define TOP_HOST_URL_DAILY_MODE @"http://10.232.37.47:8080/top/router/rest" //无争的TOP开发机器

#define MTOP_HOST_URL_DAILY_MODE        @"http://api.waptest.taobao.com/rest/api3.do"
//#define MTOP_HOST_URL_DAILY_MODE        @"http://10.13.105.14:9000/rest/api3.do"   // 慧尘的MTop开发机器

//MTOP二套日常环境
//#define MTOP_HOST_URL_DAILY_MODE @"http://10.232.102.92/rest/api3.do"

#define ALIPAY_HOST_DAILY_MODE     @"http://mali.stable.alipay.net"

#define WAP_SITE_HOST_DAILY_MODE        @"waptest.taobao.com"
#define WAP_SEARCH_HOST_DAILY_MODE      @"s.waptest.taobao.com"

//#endif


//============TTID=======================

#define kCurrentVersion     @"1.4.0"

#define APP_TTTID_TAG       @"@juhuasuan_iphone_" kCurrentVersion    // 201200@juhuasuan_iphone_1.3.0
//#define APP_TTID_NUMBER     @"201200"   // Apple Store
//#define APP_TTID_NUMBER     @"206200"   // 自有渠道，就是聚划算网站页面的下载
//#define APP_TTID_NUMBER     @"208200"   // 91助手
//#define APP_TTID_NUMBER     @"700220"   // 91助手位置1，付费给91做推广的版本
//#define APP_TTID_NUMBER     @"700141"   // 同步推
//#define APP_TTID_NUMBER     @"700407"   // PP助手，4-10张截图，jpg，iPhone为320*480，iPad为480*360，icon为512*512，jpg格式
//#define APP_TTID_NUMBER     @"700069"   // 淘宝应用中心
//#define APP_TTID_NUMBER     @"240200"   // UC天网
//#define APP_TTID_NUMBER     @"600073"   // UC天网投放3
//#define APP_TTID_NUMBER     @"600120"   // UC天网投放4
//#define APP_TTID_NUMBER     @"600149"   // UC天网广告位
//#define APP_TTID_NUMBER     @"257200"   // 上海联通
//#define APP_TTID_NUMBER     @"700361"   // 北京联通
//#define APP_TTID_NUMBER     @"700362"   // 深圳电信
//#define APP_TTID_NUMBER     @"600029"   // 新浪微博广告位
//#define APP_TTID_NUMBER     @"231200"   // 腾讯空间

// Wap TTID, &ttid=
#define kWapTTIDFenZhong            @"12fez001" // 申请分众Wap TTID: 12fez001
#define kWapTTIDWeiBoApp            @"12xl0003" // 新浪微博的分享App Wap TTID: 12xl0003
#define kWapTTIDWeiBoTaobaoItem     @"12xl0004" // 新浪微博的分享宝贝Wap TTID: 12xl0004
#define kWapTTIDWeiXinApp           @"12wex002" // 微信分享App Wap TTID: 12wex002
#define kWapTTIDWeiXinTaobaoItem    @"12wex001" // 微信分享宝贝Wap TTID: 12wex001
#define kWapTTIDAlipayQRCode        @"12ewm315" // 聚划算无线悦享拍的Wap TTID:12ewm315
#define kWapTTIDScheduleItemSMS     @"12ewm318" // 短信提醒用户预约下单功能成功的中转页Wap TTID:12ewm318
// 线下推广用的二维码ttid    12ewm324，目前用的TMS地址是：http://act.ju.taobao.com/go/rgn/juhuasuan/mobile-from-weixin.php?ttid=12ewm324
// 对应的短链接是：http://t-jh.cn/G0wgUly

//
// 12ewm315 至 12ewm329
//

//=============数据请求相关宏==============
//是否使用MTOP的输出属性过滤
#define USE_MTOP_FILTER 1
//MTOP是否JU相关接口是否关闭Ecode签名
#define MTOP_JUAPI_DISABLEECODE 1
//Wifi环境下请求失效时间
#define ASIHTTP_TIMEOUT_WIFI 15
//非Wifi环境下请求失效时间
#define ASIHTTP_TIMEOUT_NOT_WIFI 30
//请求失败重试次数
#define TOP_REQUEST_FAILED_REPEATCOUNT 1
//======================================

#define APP_PROFILE_GROUP_NAME          @"UI_PROFILE"
#define APP_PROFILE_KEY                 @"UI_IOS_" kCurrentVersion

//=================================UI相关宏===================================
#define kCommonCornerRadius                 4

#define kNormalTextColor0                   UIColorFromRGB(0x666666)    // 普通的文本颜色，(102, 102, 102)
#define kNormalTextColor1                   UIColorFromRGB(0x333333)    // 加重的文本颜色，如选中，(51, 51, 51)
#define kNormalTextColor2                   UIColorFromRGB(0x999999)    // 提示的次要文本颜色，(153, 153, 153)

#define kOrderStatusColorCreated            UIColorFromRGB(0xc7223d)    // 订单已经创建，待付款，红色，(199, 34, 61)
#define kOrderStatusColorSuccess            UIColorFromRGB(0x388e07)    // 交易成功颜色，绿色, (56, 142, 7)
#define kOrderStatusColorClosed             UIColorFromRGB(0x999999)    // 交易关闭颜色，灰色

#define kOrderStatusColorWaitingForReceive  kOrderStatusColorCreated    // 等待收获颜色，红色
#define kOrderStatusColorWaitingForSend     kOrderStatusColorSuccess    // 等待发货颜色，绿色

#define kScheduleStatusColorWaiting         kOrderStatusColorSuccess    // 等待预下单，绿色
#define kScheduleStatusColorCreating        kOrderStatusColorSuccess    // 正在预下单，绿色
#define kScheduleStatusColorSuccess         kOrderStatusColorCreated    // 预下单成功，绿色

#define kTitleSchedule                      @"预下单"
#define kStringLoading                      @"正在载入..."

//=================================Notification===============================
// 一些跨模块的通知消息定义
#define kLikedItemNotification              @"kLikedItemNotification"

//===========================================================================

#define kTradeEntryTypeDefault                  @"Defatul category"         // 聚划算商品类目入口
#define kTradeEntryTypeCity                     @"City category"            // 城市商品类目入口
#define kTradeEntryTypeTag                      @"Cloud tag category"       // 云标签类目入口
#define kTradeEntryTypeBanner                   @"Banner category"          // Banner公告栏入口
#define kTradeEntryTypeLike                     @"My liked category"        // 今日最爱列表入口
#define kTradeEntryTypeHistory                  @"History browse category"  // 浏览历史列表入口

// 存入UserDefaults的key，前缀统一为：kUserDefaultsKey
#define kUserDefaults                           [NSUserDefaults standardUserDefaults]

#define kUserDefaultsDeviceToken                @"kUserDefaultsDeviceToken"

// 记录服务器是否支持预下单功能
#define kUserDefaultsIsSupportSchedule          @"kUserDefaultsIsSupportSchedule"

#define kUserDefaultsTradeEntryTypeKey          @"kTradeEntryTypeKey"       // 当前入口的 NSUserDefault key
#define kUserDefaultsKeyCheckedUpdateTime       @"kUserDefaultsKeyCheckedUpdateTime"        // 记录显示升级提示的时间key，目前24小时一次

#define kUserDefaultsKeyHasShowedGuide          @"kUserDefaultsKeyHasShowedGuide_1_3_0"     // 第一次运行软件时显示引导界面
#define kUserDefaultsKeyNeedShowMainGuide       @"kUserDefaultsKeyNeedShowMainGuide"        // 显示主界面时的引导
#define kUserDefaultsKeyNeedShowFavoriteGuide   @"kUserDefaultsKeyNeedShowFavoriteGuide"    // 显示参团界面时的引导
#define kUserDefaultsKeyNeedShowDetailGuide     @"kUserDefaultsKeyNeedShowDetailGuide"      // 在参团页点击聚服务时显示的引导
#define kUserDefaultsKeyNeedShowProfileGuide    @"kUserDefaultsKeyNeedShowProfileGuide"     // 显示MyProfile配置页时的引导

#define kUserDefaultsKeyLastOrderId             @"kUserDefaultsKeyLastOrderId"              // 用户创建的最后一个订单id，用作支付成功后的标识

#define kUserDefaultsKeySafepayResultPrize      @"kUserDefaultsKeySafepayResultPrize"      // 用safepay成功后，是否显示活动页面，里面是一个URL地址，有就显示，否则不显示

// 分享微博参与抽奖活动相关宏
#define kUserDefaultsKeyLotteryIsValidWithNoAlipay  @"kUserDefaultsKeyLotteryIsValidWithNoAlipay"   // 813没有支付宝的下单成功后分享微博抽奖功能开关，故意留的bug让用户来玩
#define kUserDefaultsKeyLotteryStartDate        @"kUserDefaultsKeyLotteryStartDate"                 // 813周年庆抽奖活动的开始时间
#define kUserDefaultsKeyLotteryExpireDate       @"kUserDefaultsKeyLotteryExpireDate"                // 813周年庆抽奖活动的过期时间

// 客户端埋点消息时间
#define kUserDefaultsKeyStartUpChannelDate      @"kUserDefaultsKeyStartUpChannelDate"                // 813周年庆抽奖活动的过期时间

// 新浪微博登陆成功后存储账户信息
#define kUserDefaultsSinaWeiboAuthData          @"kUserDefaultsSinaWeiboAuthData"

// alipay
#define ALIPAY_SAFEPAY                          @"SafePay"
#define ALIPAY_DATASTRING                       @"dataString"
#define ALIPAY_SCHEME                           @"fromAppUrlScheme"
#define ALIPAY_TYPE                             @"requestType"


#define kTaobaoItemWapURLFormat                 @"http://a.m.taobao.com/i%@.htm?ttid=%@"    // @"http://a.m.taobao.com/i9261020013.htm?ttid=12ewm315", taobao_item_id, wap ttid

// TMS页面的定义
#define kTMSURLSwitchToApp              @"http://act.ju.taobao.com/go/rgn/juhuasuan/switch-to-app.php"              // 启动程序
#define kTMSURLMobileFromWeiXin         @"http://act.ju.taobao.com/go/rgn/juhuasuan/mobile-from-weixin.php"         // 微信中转页
#define kTMSURLHotAppHelper             @"http://act.ju.taobao.com/go/rgn/juhuasuan/hotapp-helper.php"              // 应用推荐中心中转页
#define kTMSURLHotAppList               @"http://act.ju.taobao.com/go/rgn/juhuasuan/hotapp.php"                     // 应用推荐列表
#define kTMSURLMobileFromOther          @"http://act.ju.taobao.com/go/rgn/juhuasuan/mobile-from-other.php"          // 从v1.3.0开始，所有第三方分享的信息都到该页面做中转
//#define kTMSURLScheduleFromSMS          @"http://act.ju.taobao.com/go/rgn/juhuasuan/mobile-from-other.php"          // 从v1.3.0开始，所有第三方分享的信息都到该页面做中转

// ONE-URL: http://act.ju.taobao.com/go/rgn/juhuasuan/mobile-schedule-sms.php
// @"http://ONE-URL/?type=1&scheduleId=1234567890&ttid=12ewm318"  // tyep:1 代表一个预约单状态变化，必须要给scheduleId，type:2 代表多个预约单状态变化，没有后续参数，直接显示列表

// 订单入口事件id
enum _EventClickId
{
    kEventClickIdTradeEvent = 30000,
    kEventClickIdLoginEvnet,
    kEventClickIdComfirmTradeBuy, 
    kEventClickIdAddress, 
    kEventClickIdSKU, 
    kEventClickIdAlipayStatusCode,      // 支付宝支付后切回程序的操作结果码
    kEventClickIdLottery,               // 813周年庆抽奖活动
    kEventIdParseQRCode,                // 解析QR二维码，将二维码内容发送给服务器
    kEventIdChannel,                    // 外部通道打点
    kEventIdShareToWeiBo,               // 分享到微博
    kEventIdGetWeiboFriend,             // 获取微博好友   30010
    kEventIdBannerClick,                // Banner点击
    kEventIdReceivePush,                // 收到push被唤起
    kEventClickId_Count
};

// App Refresh Key And Time 
#define k_ExpireDate_WholeAppRefresh @"expiredate_wholeapprefresh"
#define k_timeSeparate_WholeAppRefresh 21600 // 6小时刷新App 21600

#define SHOW_ALERT(__aTitle, __aMessage)    [[[UIAlertView alloc] initWithTitle:(__aTitle) message:(__aMessage) delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show]
#define ShowAlert(__aTitle, __aMessage)     SHOW_ALERT((__aTitle), (__aMessage))
#define SHOW_ALERT_CMD                      [[[UIAlertView alloc] initWithTitle:NSStringFromSelector(_cmd) message:@"" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil] show]


#define _PageName(page)                     [page isKindOfClass:[NSString class]] ? page : NSStringFromClass([page class])

//===================================================
// [TBSPage ctrlClicked:]
#define TBSPageCtrlClicked() \
[TBSPage ctrlClicked:NSStringFromSelector(_cmd) onPage:self]; \
DDLogInfo(@"TBSPageCtrlClicked:%@ on Page:%@", NSStringFromSelector(_cmd), NSStringFromClass([self class]))

#define TBSPageCtrlClicked1(__controlName) {\
NSString * __theName = [NSString stringWithFormat:@"%@_%@", NSStringFromSelector(_cmd), __controlName]; \
[TBSPage ctrlClicked:__theName onPage:self]; \
DDLogInfo(@"TBSPageCtrlClicked:%@ on Page:%@", __theName, NSStringFromClass([self class]));}

#define TBSPageCtrlClicked2(__controlName, page) {\
NSString * __theName = [NSString stringWithFormat:@"%@_%@", NSStringFromSelector(_cmd), __controlName]; \
[TBSPage ctrlClicked:__theName onPage:page]; \
DDLogInfo(@"TBSPageCtrlClicked:%@ on Page:%@", __theName, _PageName(page));}

//===================================================
// [TBSPage itemSelected:]
#define TBSPageItemSelected()  { \
UITableViewCell * __selectedCell = [tableView cellForRowAtIndexPath:indexPath]; \
NSString * __text = __selectedCell.textLabel.text; \
[TBSPage itemSelected:__text onPage:self]; \
DDLogInfo(@"TBSPageItemSelected:%@ on Page:%@", __text, NSStringFromClass([self class]));}

#define TBSPageItemSelected1(__itemName) \
[TBSPage itemSelected:__itemName onPage:self]; \
DDLogInfo(@"TBSPageItemSelected:%@ on Page:%@", __itemName, NSStringFromClass([self class]))

#define TBSPageItemSelected2(__itemName, __page) \
[TBSPage itemSelected:__itemName onPage:__page]; \
DDLogInfo(@"TBSPageItemSelected:%@ on Page:%@", __itemName, _PageName(__page))

//===================================================
// [TBSPage controlSlide:]
#define TBSPageControlSlide() \
[TBSPage controlSlide:NSStringFromSelector(_cmd) onPage:self]; \
DDLogInfo(@"TBSPageControlSlide:%@ on Page:%@", NSStringFromSelector(_cmd), NSStringFromClass([self class]))

#define TBSPageControlSlide1(__controlName) {\
NSString * __theName = [NSString stringWithFormat:@"%@_%@", NSStringFromSelector(_cmd), __controlName]; \
[TBSPage controlSlide:__theName onPage:self]; \
DDLogInfo(@"TBSPageControlSlide:%@ on Page:%@", __theName, NSStringFromClass([self class]));}

//===================================================
// [TBSExt commitOnPage:]
#define TBSExtCommitOnPage(__thePage, __theEventId) \
[TBSExt commitOnPage:__thePage eventId:__theEventId]; \
DDLogInfo(@"TBSExtCommitOnPage:%@ enentId:%d", _PageName(__thePage), __theEventId)

#define TBSExtCommitOnPage1(__thePage, __theEventId, __theArg1) \
[TBSExt commitOnPage:__thePage eventId:__theEventId arg1:__theArg1]; \
DDLogInfo(@"TBSExtCommitOnPage:%@ enentId:%d arg1:%@", _PageName(__thePage), __theEventId, __theArg1)

#define TBSExtCommitOnPage2(__thePage, __theEventId, __theArg1, __theArg2) \
[TBSExt commitOnPage:__thePage eventId:__theEventId arg1:__theArg1 arg2:__theArg2]; \
DDLogInfo(@"TBSExtCommitOnPage:%@ enentId:%d arg1:%@ arg2:%@", _PageName(__thePage), __theEventId, __theArg1, __theArg2)

#define TBSExtCommitOnPage3(__thePage, __theEventId, __theArg1, __theArg2, __theArg3) \
[TBSExt commitOnPage:__thePage eventId:__theEventId arg1:__theArg1 arg2:__theArg2 arg3:__theArg3]; \
DDLogInfo(@"TBSExtCommitOnPage:%@ enentId:%d arg1:%@ arg2:%@ arg3:%@", _PageName(__thePage), __theEventId, __theArg1, __theArg2, __theArg3)

#define TBSExtCommitOnPage4(__thePage, __theEventId, __theArg1, __theArg2, __theArg3, __theArgs) \
[TBSExt commitOnPage:__thePage eventId:__theEventId arg1:__theArg1 arg2:__theArg2 arg3:__theArg3 args:__theArgs]; \
DDLogInfo(@"TBSExtCommitOnPage:%@ enentId:%d arg1:%@ arg2:%@ arg3:%@ args:%@", _PageName(__thePage), __theEventId, __theArg1, __theArg2, __theArg3, __theArgs)

#endif

// 判断系统版本号的宏定义
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)


//===================================================
// iPhone5兼容
#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
// iOS7兼容
#define iOS7  ([[[UIDevice currentDevice] systemVersion] compare:@"7.0"] != NSOrderedAscending)

#define XIB_IPHONE_HEIGHT 480
#define IPHONE_HEIGHT [UIScreen mainScreen].bounds.size.height
#define IPHONE_WIDTH [UIScreen mainScreen].bounds.size.width

#define IPHONE_STATUBAR_HEIGHT 20
#define IPHONE_NAVIGATION_HEIGHT 48

//URLMapping
#define SplashViewControllerURL @"daguanjia://go/splash"
#define RegistPhoneViewControllerURL @"daguanjia://go/regist_phone"
#define LoginViewControllerURL @"daguanjia://go/login"
#define ComfirmPhoneCodeViewControllerURL @"daguanjia://go/confirm_phone_code"
#define UploadPasswdViewControllerURL @"daguanjia://go/upload_passwd"
#define XiaoQuInfoViewControllerURL @"daguanjia://go/xiaoqu_info"
#define ShopInfoViewControllerURL @"daguanjia://go/shop_info"
#define MyProfileViewControllerURL @"daguanjia://go/my_profile"
#define CityListViewControllerURL @"daguanjia://go/city_list"
#define CommunitySearchViewControllerURL @"daguanjia://go/search_community"
#define CommonWebViewControllerURL @"daguanjia://go/common_webview"



