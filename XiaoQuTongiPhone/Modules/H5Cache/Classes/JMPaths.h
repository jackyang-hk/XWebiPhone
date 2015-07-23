//
//  JMPaths.h
//  JoyMapsKit
//
//  Created by laijiandong on 12/18/14.
//  Copyright (c) 2014 laijiandong. All rights reserved.
//

#import <Foundation/Foundation.h>

//
// 以下方法来源于Nimbus，文件路径拼接，查找在日常开发中比较常用，
// 但是为了这个小功能，大部分时候不会引入一个类库。
// 更多参见https://github.com/jverkoey/nimbus
//

#if defined __cplusplus
extern "C" {
#endif
    
    /**
     *  通过相对路径定位在资源包中的完整路径
     *
     *  @param bundle       资源包对象
     *  @param relativePath 资源包内的相对路径
     *
     *  @return 返回资源路径
     */
    NSString* JMPathForBundleResource(NSBundle *bundle, NSString *relativePath);
    
    /**
     *  通过相对路径定位在App Documents下的完整路径
     *
     *  @param relativePath 相对路径
     *
     *  @return 返回资源路径
     */
    NSString* JMPathForDocumentsResource(NSString *relativePath);
    
    /**
     *  通过相对路径定位在App Library下的完整路径
     *
     *  @param relativePath 相对路径
     *
     *  @return 返回资源路径
     */
    NSString* JMPathForLibraryResource(NSString *relativePath);
    
    /**
     *  通过相对路径定位在App Caches下的完整路径
     *
     *  @param relativePath 相对路径
     *
     *  @return 返回资源路径
     */
    NSString* JMPathForCachesResource(NSString *relativePath);
    
#if defined __cplusplus
};
#endif
