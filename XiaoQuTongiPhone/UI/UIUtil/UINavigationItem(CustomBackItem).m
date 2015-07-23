//
//  UINavigationItem(CustomBackItem).m
//  XiaoQuTongiPhone
//
//  Created by redcat on 14-7-26.
//  Copyright (c) 2014年 redcat. All rights reserved.
//

#import "UINavigationItem(CustomBackItem).h"

@implementation UINavigationItem (CustomBackItem)

-(UIBarButtonItem *)backBarButtonItem{
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStyleDone target:nil action:NULL];
    item.tintColor = COLOR_PAGE_BACK;
    return item;
}

@end
