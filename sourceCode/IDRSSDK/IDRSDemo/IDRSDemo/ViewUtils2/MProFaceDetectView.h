//
//  MProFaceDetectView.h
//  IDRSSDKDemo
//
//  Created by cuixling on 2020/3/18.
//  Copyright © 2020年 cuixling. All rights reserved.
//
#if defined(__arm64__)
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class faceUIAndName;
@interface MProFaceDetectView : UIView

@property (nonatomic, copy) NSArray<faceUIAndName*> *detectResult;
@property (nonatomic, assign) BOOL isMirror;//是否镜像;
@property (nonatomic, assign) CGSize presetSize;//// 检测图像的分辨率
@end
#endif
NS_ASSUME_NONNULL_END
