//
//  VideoBaseDetectView.m
//  IDRSSDKDemo
//
//  Created by cuixling on 2020/3/14.
//  Copyright © 2020年 cuixling. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface VideoBaseDetectView : UIView

@property (nonatomic, assign) float uiOffsetY;// 子控件布局的起始位置
@property (nonatomic, assign) CGSize presetSize;// 图像分辨率
@property (nonatomic, assign) float face_hand_score;

@end

NS_ASSUME_NONNULL_END
