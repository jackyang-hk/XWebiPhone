//
//  DeviceDetect.m
//  JU
//
//  Created by zeha fu on 12-6-12.
//  Copyright (c) 2012年 ju.taobao.com. All rights reserved.
//

#import "DeviceDetect.h"
#import <sys/utsname.h>
#import <mach/mach.h>
#import <mach/mach_host.h>

@implementation DeviceDetect

+ (BOOL) isLowPerformenceDevice {
    struct utsname name = {0};
//    //只初始化一次
//    static BOOL isInitialized = NO;
//    if (!isInitialized) {
        uname(&name);
//        isInitialized = YES;
//    }

    
//	float version = [[UIDevice currentDevice].systemVersion floatValue];//判定系统版本。
	if (strstr(name.machine, "iPod1,1") != 0 || strstr(name.machine, "iPod2,1") != 0 || strstr(name.machine, "iPod3,1") != 0 || strstr(name.machine, "iPod4,1") != 0) {
		return YES;
	}
	else {
        double memory = [[UIDevice currentDevice] availableMemory];
//#ifdef DEBUG
//        DDLogInfo(@"Avalible Memory %f",memory);
//#endif
        if (memory < 10) {
            return YES;
        }
		return NO;
	}
}

+ (BOOL) isUnder5xVersion {
    float version = [[UIDevice currentDevice].systemVersion floatValue];//判定系统版本。
	if (version < 5.0) {
		return YES;
	} else {
		return NO;
	}
}

// ------Alipay FeedBack
+ (BOOL)isSingleTask{
	struct utsname name;
	uname(&name);
	float version = [[UIDevice currentDevice].systemVersion floatValue];//判定系统版本。
	if (version < 4.0 || strstr(name.machine, "iPod1,1") != 0 || strstr(name.machine, "iPod2,1") != 0) {
		return YES;
	} else {
		return NO;
	}
}



@end

@implementation UIDevice (UIDeviceHelper)

static void print_free_memory () {
    mach_port_t host_port;
    mach_msg_type_number_t host_size;
    vm_size_t pagesize;
    
    host_port = mach_host_self();
    host_size = sizeof(vm_statistics_data_t) / sizeof(integer_t);
    host_page_size(host_port, &pagesize);        
    
    vm_statistics_data_t vm_stat;
    
    if (host_statistics(host_port, HOST_VM_INFO, (host_info_t)&vm_stat, &host_size) != KERN_SUCCESS)
        NSLog(@"Failed to fetch vm statistics");
    
    /* Stats in bytes */ 
    natural_t mem_used = (vm_stat.active_count +
                          vm_stat.inactive_count +
                          vm_stat.wire_count) * pagesize;
    natural_t mem_free = vm_stat.free_count * pagesize;
    natural_t mem_total = mem_used + mem_free;
    NSLog(@"used: %u free: %u total: %u", mem_used, mem_free, mem_total);
}

- (double)availableMemory {
    vm_statistics_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmStats, &infoCount);   
    if(kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }
    return ((vm_page_size * vmStats.free_count) / 1024.0) / 1024.0;
}

- (NSString*) uniqueIdentifier {
//    return [TBTop imei];
#pragma - mark todo imei
    return @"ajklsjd;fja;lsdf";
}

@end
