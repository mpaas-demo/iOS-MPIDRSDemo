//
//  FaceSDKDemoViewController.h
//  IDRSSDKDemo
//
//  Created by cuixling on 2020/3/14.
//  Copyright © 2020年 cuixling. All rights reserved.
//
#import "VideoBaseViewController.h"
#import <ReplayKit/ReplayKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FaceSDKDemoViewController : VideoBaseViewController
	<RPScreenRecorderDelegate,RPPreviewViewControllerDelegate>

// 视频相关
@property (nonatomic, assign, readonly) BOOL isCapturing;//正在录制
@property (nonatomic, assign, readonly) BOOL isPaused;//是否暂停
@property (nonatomic, assign, readonly) CGFloat currentRecordTime;//当前录制时间
@property (nonatomic, assign) CGFloat maxRecordTime;//最长录制时间
@property (nonatomic, copy) NSString *videoPath;//视频路径
@property (nonatomic, copy) NSString *videoName;//视频文件名称

@end

NS_ASSUME_NONNULL_END
