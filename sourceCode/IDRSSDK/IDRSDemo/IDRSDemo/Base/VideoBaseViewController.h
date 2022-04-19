//
//  VideoBaseViewController.h
//  IDRSSDKDemo
//
//  Created by cuixling on 2020/3/14.
//  Copyright © 2020年 cuixling. All rights reserved.
//
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>
#import "VideoBaseDetectView.h"

#define ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight                        [[UIScreen mainScreen] bounds].size.height

NS_ASSUME_NONNULL_BEGIN

@interface VideoBaseViewController : UIViewController <AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate>

@property (strong, nonatomic) VideoBaseDetectView *detectView;
@property (strong, nonatomic) VideoBaseDetectView *handDetectView;

//Connection
@property (nonatomic, strong) AVCaptureConnection *audioConnection;//音频录制连接
@property (nonatomic, strong) AVCaptureConnection *videoConnection;//视频录制连接

@property (assign, nonatomic) BOOL isFrontCamera;

- (float)navigationbarHeight;
- (NSDictionary*)calculateInAndOutAngle;
- (void)printAvailableVideoFormatTypes:(AVCaptureVideoDataOutput *)videoOutput;
- (CGSize)sessionPresetToSize;
- (void) setRecordSessionPreset:(CMSampleBufferRef) sampleBuffer;

/**
   override
 */
// optional
- (BOOL)needCameraPreView;
- (AVCaptureSessionPreset)cameraSessionPreset;

// required
- (void)createKitInstance;
- (VideoBaseDetectView*)createDetectView;
- (VideoBaseDetectView*)createHandDetectView;

- (void)onImageMode:(id)sender;

@end

NS_ASSUME_NONNULL_END
