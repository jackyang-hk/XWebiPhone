//
//  TBStoredData.h
//  TBSDK
//
//  Created by Xu Jiwei on 10-11-3.
//  Copyright 2010 Taobao.com. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __cplusplus
extern "C" {
#endif
    //! 获取保存的用户名
    NSString* TBSessionGetStoredUsername();
    
    //! 获取保存的密码
    NSString* TBSessionGetStoredPassword();
    
    //! 获取保存的自动登录token
    NSString* TBSessionGetStoredAutoLoginToken();
    
    //! 保存用户名
    void TBSessionSetStoredUsername(NSString *user);
    
    //! 保存密码
    void TBSessionSetStoredPassword(NSString *pass);
    
    //! 保存自动登录用的token
    void TBSessionSetStoredAutoLoginToken(NSString* token);
    
    //! 清除保存的用户名和密码
    void TBSessionClearTOPSession();
#ifdef __cplusplus
}
#endif