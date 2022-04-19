//
//  FaceDetectView.h
//  IDRSSDKDemo
//
//  Created by cuixling on 2020/3/18.
//  Copyright © 2020年 cuixling. All rights reserved.
//

#import "VideoBaseDetectView.h"

NS_ASSUME_NONNULL_BEGIN

@class FaceDetectionOutput;
@interface FaceDetectView : VideoBaseDetectView

@property (nonatomic, copy) NSArray<FaceDetectionOutput*> *detectResult;
@property (nonatomic, assign) BOOL showPointOrder;

@property (nonatomic, assign) BOOL useRedColor;
@property (nonatomic, strong) UILabel* lbLiveness;
@property (nonatomic, assign) float recognitionScore;
@property (nonatomic, assign) BOOL isRTC;//是否为远程双录;
@property (nonatomic, assign) BOOL isRemoteWindow;//是否为远端窗口;
@end

NS_ASSUME_NONNULL_END
