//
//  MPUtility.m
//  MPIDRSSDKDemo
//
//  Created by 斌小狼 on 2021/10/14.
//  Copyright © 2021 Alipay. All rights reserved.
//

#import "MPUtility.h"

static const CGFloat kBaselineWidth = 375;      // 视觉稿基准宽度
static const CGFloat kBaselineHeight = 812;     // 视觉稿基准高度

@implementation MPUtility

+ (CGFloat)statusBarHeight {
    return [UIApplication sharedApplication].statusBarFrame.size.height;
}

+ (CGFloat)navigationBarHeight {
    return 44;
}

+ (CGFloat)safeAreaInsetsBottom {
    if (@available(iOS 11.0, *)) {
        UIEdgeInsets edgeInsets = [UIApplication sharedApplication].keyWindow.rootViewController.view.safeAreaInsets;
        return edgeInsets.bottom;
    } else {
        return 0;
    }
}

+ (CGFloat)screenWidth {
    return [UIScreen mainScreen].bounds.size.width;
}

+ (CGFloat)screenHeight {
    return [UIScreen mainScreen].bounds.size.height;
}

+ (UIImage *)imageNamed:(NSString *)name ofType:(NSString *)type {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"MPIDRSSDKDemo.bundle" ofType:@""];
    path = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"images/%@", name]];

    UIImage *image;
    if (type.length == 0) {
        // 没有类型，表示 name 是完整文件名
        image = [[UIImage alloc] initWithContentsOfFile:path];
    } else {
        path = [path stringByAppendingString:@"@2x"];
        path = [path stringByAppendingString:[NSString stringWithFormat:@".%@", type]];
    }
    return image;
}

+ (NSString *)filePathNamed:(NSString *)name {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"KYC.bundle" ofType:@""];
    path = [path stringByAppendingPathComponent:name];
    return path;
}

+ (CGFloat)uiScaleW {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat scale = screenWidth / kBaselineWidth;   // 缩放比例
    return scale;
}

+ (CGFloat)uiScaleH {
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat scale = screenHeight / kBaselineHeight;   // 缩放比例
    return scale;
}

+ (CGFloat)cpuUsageForApp {
     kern_return_t kr;
     thread_array_t         thread_list;
     mach_msg_type_number_t thread_count;
     thread_info_data_t     thinfo;
     mach_msg_type_number_t thread_info_count;
     thread_basic_info_t basic_info_th;

     // get threads in the task
     kr = task_threads(mach_task_self(), &thread_list, &thread_count);
     if (kr != KERN_SUCCESS)
         return -1;

     float tot_cpu = 0;

     for (int j = 0; j < thread_count; j++) {
         thread_info_count = THREAD_INFO_MAX;
         kr = thread_info(thread_list[j], THREAD_BASIC_INFO,
                          (thread_info_t)thinfo, &thread_info_count);
         if (kr != KERN_SUCCESS)
             return -1;

         basic_info_th = (thread_basic_info_t)thinfo;
         if (!(basic_info_th->flags & TH_FLAGS_IDLE)) {
             // cpu_usage : Scaled cpu usage percentage. The scale factor is TH_USAGE_SCALE.
             tot_cpu += basic_info_th->cpu_usage / (float)TH_USAGE_SCALE;
         }

     } // for each thread
     kr = vm_deallocate(mach_task_self(), (vm_offset_t)thread_list, thread_count * sizeof(thread_t));
     assert(kr == KERN_SUCCESS);
     return tot_cpu;
 }
@end
