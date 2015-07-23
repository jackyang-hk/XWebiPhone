//
//  JUSevenAdapter.h
//  JU
//
//  Created by 陈 奕龙 on 13-12-23.
//  Copyright (c) 2013年 ju.taobao.com. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 *  iOS7适配类
 */
@interface JUSevenAdapter : NSObject


/**
 *  NavigaitonBar适配iOS7的背景图适配
 */
+(void) adapterNavigationBarBackground;


/**
 *  构建一个自定义iOS7上字体颜色的BarButtonItem（navigationBar）
 *
 *  @param text           button的文案
 *  @param color          字体颜色
 *  @param viewController 触发方法所在的viewController
 *  @param sel            button点击的触发方法
 *
 *  @return UIBarButtonItem的一个实例对象
 */
+(UIBarButtonItem*)adapterBarButtonWithText:(NSString*)text colorAtSeven:(UIColor*)color inViewController:(UIViewController *)viewController actionSEL:(SEL)sel;

/**
 *  构建一个使用默认字体颜色适配iOS7的BarButtonItem（navigationBar）
 *
 *  @param text           button的文案
 *  @param viewController 触发方法所在的viewController
 *  @param sel            button点击的触发方法
 *
 *  @return UIBarButtonItem的一个实例对象
 */
+(UIBarButtonItem*)adapterBarButtonWithText:(NSString*)text inViewController:(UIViewController *)viewController actionSEL:(SEL)sel;

/**
 *  构建一个适配iOS7的聚划算logo
 */
+(UIImageView*) adapterJULog;

/**
 *  构建一个适配iOS7的UILabel
 *
 *  @param title Label上的文案
 *
 *  @return UIlabel的一个实例
 */
+(UILabel*) adapterTitleLabel:(NSString*)title;

/**
 *  构建一个适配iOS7的返回按钮
 *
 *  @param viewController 触发方法所在的viewController
 *
 *  @return UIBarButtonItem的一个实例对象
 */
+(UIBarButtonItem*)adapterReturnButtonInViewController:(UIViewController *)viewController;

/**
 *  构建一个适配iOS7的分享按钮
 *
 *  @param viewController 触发方法所在的viewController
 *  @param sel            button点击的触发方法
 *
 *  @return UIBarButtonItem的一个实例对象
 */
+(UIBarButtonItem*)adapterShareButtonInViewController:(UIViewController *)viewController shareAction:(SEL)sel;

+(UIBarButtonItem*)adapterCategoryButtonInViewController:(UIViewController *)viewController categoryAction:(SEL)sel;

+(UIBarButtonItem*)adapterReloadButtonInViewController:(UIViewController *)viewController reloadAction:(SEL)sel;

+(UIBarButtonItem*)adapterSettingButtonInViewController:(UIViewController *)viewController settingAction:(SEL)sel;

//2.6.0
//添加一个适配iOS7的关闭按钮
+(UIBarButtonItem*)adapterCloseButtonInViewController:(UIViewController*)viewController closeAction:(SEL)sel;
+(UIView*)adapterBackgroundViewWithColor:(UIColor*)color;
@end
