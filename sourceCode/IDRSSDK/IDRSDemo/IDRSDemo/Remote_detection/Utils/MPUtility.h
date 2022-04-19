//
//  MPUtility.h
//  MPIDRSSDKDemo
//
//  Created by 斌小狼 on 2021/10/14.
//  Copyright © 2021 Alipay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <mach/mach.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPUtility : NSObject

+ (CGFloat)statusBarHeight;

+ (CGFloat)navigationBarHeight;

+ (CGFloat)safeAreaInsetsBottom;

+ (CGFloat)screenWidth;

+ (CGFloat)screenHeight;

+ (UIImage *)imageNamed:(NSString *)name ofType:(NSString *)type;

/**
 * 获取 KYC.bundle 中文件的路径
 */
+ (NSString *)filePathNamed:(NSString *)name;

/**
 * 相对于视觉稿宽度的缩放比例
 */
+ (CGFloat)uiScaleW;

/**
* 相对于视觉稿高度的缩放比例
*/
+ (CGFloat)uiScaleH;

/**
* 获取当前CPU占用率
*/
+ (CGFloat)cpuUsageForApp;
@end

NS_ASSUME_NONNULL_END
