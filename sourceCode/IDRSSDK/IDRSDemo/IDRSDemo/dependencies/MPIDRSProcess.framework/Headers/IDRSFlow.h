//
//  IDRSFlow.h
//  IDRSSDK
//
//  Created by 崔海斌 on 2020/10/19.
//  Copyright © 2020 cuixling. All rights reserved.
//
#ifdef __arm64__
#import <Foundation/Foundation.h>
#import <MPIDRSProcess/FlowModel.h>

/*
 1、对SDK的方法进行封装返回、分为本地和远程两部分
 2、流程解析、自动调用方法、返回方法结果
 3、对方法进行控制、短时间内不能调用同一方法（TTS方向）
 4、
 */
@protocol IDRSFlowDelegate;

typedef void (^JsonBlock)(NSString *string);
typedef void (^successBlock)(NSString *string,JsonBlock jsonBlock);

@interface IDRSFlow : NSObject

/// 创建实例
/// @param delegate 代理
/// @param config FlowCreateConfig 初始参数
/// @param jsonString 返回数据，修改后，通过jsonBlock 传回SDK
- (instancetype)initIDRSWithDelegate:(id<IDRSFlowDelegate>)delegate Config:(FlowCreateConfig*)config success:(successBlock)jsonString;

- (instancetype)init NS_UNAVAILABLE;

/// 开启摄像头
/// @param orientation orientation确定了视频流角度、而检测需要这个角度、如果此处角度为你页面角度、则检测角度为0
/// @param view 返回相机VIew
- (void)startCameraWithOrientation:(AVCaptureVideoOrientation)orientation back:(void (^)(UIView* cameraView))view;

/// 切换摄像头
- (void)switchCamera:(void (^)(BOOL result))success;

/// 开始流程
- (void)startFlow;

/// 上一章
- (void)reLastPage;

/// 开始下一项检测
/// 如果没有更多检测项则跳到下一章节
- (void)startNextDetection;

/// 重复当前检测项
- (void)repeatCurrentDetection;

/// 重新播报当前章节
- (void)replayCurChapter;

/// 流程暂停
- (void)flowPause;

/// 流程恢复
- (void)flowResume;

/// 添加当前自定义章节的结果
/// @param result 自定义章节结果
- (void)AddCurChapterCustomResult:(NSString*)result;

//清空存储的默认路径下的视频、meta文件
- (void)wipeCache;

/// 销毁
- (void)destroy;

/// 版本号
+ (NSString*)getVersion;

@end
#endif
