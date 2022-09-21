//
//  HandDetectView.h
//  IDRSSDKSDKDemo
//
//  Created by cuixling on 2020/4/4.
//  Copyright © 2020年 cuixling. All rights reserved.
//
#if defined(__arm64__)
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HandDetectionOutput;
@interface MProHandDetectView : UIView

@property (nonatomic, strong) NSArray<HandDetectionOutput*> *detectResult;

@property (nonatomic, assign) BOOL isMirror;//是否镜像;

@property (nonatomic, assign) CGSize presetSize;// 检测图像的分辨率

@end
#endif
NS_ASSUME_NONNULL_END
