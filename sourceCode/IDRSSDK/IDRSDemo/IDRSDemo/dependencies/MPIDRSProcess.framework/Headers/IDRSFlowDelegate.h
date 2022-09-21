//
//  IDRSFlowDelegate.h
//  IDRSSDK
//
//  Created by 崔海斌 on 2020/11/5.
//  Copyright © 2020 cuixling. All rights reserved.
//
#ifdef __arm64__
#import <Foundation/Foundation.h>
#import <MPIDRSProcess/FlowModel.h>
#import <MPIDRSSDK/MPIDRSSDK.h>

@protocol IDRSFlowDelegate <NSObject>

- (void)flowCameraView:(UIView *)cameraView didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer;

/// 检测超时回调
- (void)onDetectionFail:(id)body;

/// 检测成功
- (void)onDetectionSuccess:(SuccessModel*)body;

/// 开始章节：返回开始第几章节
- (void)onPhaseStarted:(CheckResult*)phase;

/// 结束章节：返回结束第几个章节
- (void)onPhaseComleted:(CheckResult*)phase;

/// 流程结束：全部章节结束时回调
- (void)onFlowCompleted;

/// 报错信息
/// @param errorDic 报错信息
/// @param param 上传报错返回的可用于下次（重试）的文件信息
- (void)onError:(NSDictionary*)errorDic withParam:(IDRSUploadManagerParam *)param;

/// 文件上传回调
/// @param isRun 正在调用接口
- (void)ossUploadWithStarted:(BOOL)isRun msg:(id)msg;

/// 手势位置回调
/// @param results 手势位置
- (void)onHandDetectUi:(NSArray<HandDetectionOutput *>* __nullable)results;

/// 人脸位置回调
/// @param resules 人脸位置
- (void)onFaceDetectUi:(NSArray<faceUIAndName*>*__nullable)resules;

/// tts合成数据返回
/// @param info 文本信息
/// @param info_len 下角标 : 不推荐使用，使用info.leght
/// @param buffer 音频流
/// @param len 音频流长度
/// @param taskid taskid
- (void)onTTSCallBackwithText:(NSString *)info word_idx:(int)info_len buffer:(char *)buffer len:(int)len taskid:(NSString *)taskid;

/// 音频文件下载进度
/// @param per 当前文件的百分比
/// @param percent 当前第几个文件
/// @param isAll 是否全部下载完成
/// @param error 报错信息
- (void)downloadAudio:(float)per percent:(NSString* _Nullable)percent isAll:(BOOL)isAll error:(NSError *_Nullable)error;

@end
#endif

