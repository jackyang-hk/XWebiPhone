//
//  TBStoredData.m
//  TBSDK
//
//  Created by Xu Jiwei on 10-11-3.
//  Copyright 2010 Taobao.com. All rights reserved.
//

#import "TBStoredData.h"

#import "SFHFKeychainUtils.h"

#define kKeychainServiceName        @"tbsdk_session_data"
#define kKeychainUsernameKey        @"tbsdk_session_uname"
#define kKeychainPasswordKey        @"tbsdk_session_passwd"
#define kKeychainAutoLoginTokenKey  @"tbsdk_session_auto_login_token"
#define kKeychainTOPSessionKey      @"tbsdk_top_session"
#define kKeychainWapSessionKey      @"tbsdk_wap_session"

NSString* TBSessionGetStoredUsername() {
    NSString *user = [SFHFKeychainUtils getPasswordForUsername:kKeychainUsernameKey
                                                andServiceName:kKeychainServiceName
                                                         error:NULL];
    return user;
}

NSString* TBSessionGetStoredPassword() {
    NSString *password = [SFHFKeychainUtils getPasswordForUsername:kKeychainPasswordKey
                                                    andServiceName:kKeychainServiceName
                                                             error:NULL];
    return password;
}

NSString* TBSessionGetStoredAutoLoginToken() {
    NSString *password = [SFHFKeychainUtils getPasswordForUsername:kKeychainAutoLoginTokenKey
                                                    andServiceName:kKeychainServiceName
                                                             error:NULL];
    return password;
}

void TBSessionSetStoredUsername(NSString* user) {
    if ([user length] > 0) {
        [SFHFKeychainUtils storeUsername:kKeychainUsernameKey
                             andPassword:user
                          forServiceName:kKeychainServiceName
                          updateExisting:YES
                                   error:NULL];
    }
}

void TBSessionSetStoredPassword(NSString* pass) {
    if ([pass length] > 0) {
        [SFHFKeychainUtils storeUsername:kKeychainPasswordKey
                             andPassword:pass
                          forServiceName:kKeychainServiceName
                          updateExisting:YES
                                   error:NULL];
    }
}

void TBSessionSetStoredAutoLoginToken(NSString* token) {
    if ([token length] > 0) {
        [SFHFKeychainUtils storeUsername:kKeychainAutoLoginTokenKey
                             andPassword:token
                          forServiceName:kKeychainServiceName
                          updateExisting:YES
                                   error:NULL];
    }
}

void TBSessionClearTOPSession() {
//    [SFHFKeychainUtils storeUsername:kKeychainWapSessionKey
//                         andPassword:@"0"
//                      forServiceName:kKeychainServiceName
//                      updateExisting:YES
//                               error:NULL];
//    
//    [SFHFKeychainUtils storeUsername:kKeychainTOPSessionKey
//                         andPassword:@"0"
//                      forServiceName:kKeychainServiceName
//                      updateExisting:YES
//                               error:NULL];
    
    [SFHFKeychainUtils deleteItemForUsername:kKeychainUsernameKey andServiceName:kKeychainServiceName error:NULL];
    [SFHFKeychainUtils deleteItemForUsername:kKeychainPasswordKey andServiceName:kKeychainServiceName error:NULL];
}