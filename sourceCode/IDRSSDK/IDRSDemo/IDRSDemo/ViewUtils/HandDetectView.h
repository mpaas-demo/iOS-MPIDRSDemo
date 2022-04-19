//
//  HandDetectView.h
//  IDRSSDKSDKDemo
//
//  Created by cuixling on 2020/4/4.
//  Copyright © 2020年 cuixling. All rights reserved.
//

#import "VideoBaseDetectView.h"

NS_ASSUME_NONNULL_BEGIN

@class HandDetectionOutput;
@interface HandDetectView : VideoBaseDetectView

@property (nonatomic, strong) NSArray<HandDetectionOutput*> *detectResult;
@property (nonatomic, assign) BOOL showPointOrder;

@property (nonatomic, assign) BOOL useRedColor;

@property (nonatomic, assign) float recognitionScore;
@property (nonatomic, assign) float hand_face_score;
@property (nonatomic, assign) BOOL isRTC;//是否为远程双录;
@property (nonatomic, assign) BOOL isRemoteWindow;//是否为远端窗口;
@end

NS_ASSUME_NONNULL_END
