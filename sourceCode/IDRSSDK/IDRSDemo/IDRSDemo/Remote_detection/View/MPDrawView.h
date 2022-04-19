//
//  MPGestureView.h
//  MPIDRSSDKDemo
//
//  Created by 斌小狼 on 2021/9/24.
//  Copyright © 2021 Alipay. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FaceDetectView.h"
#import "HandDetectView.h"

NS_ASSUME_NONNULL_BEGIN

@interface MPDrawView : UIView
@property (strong, nonatomic) FaceDetectView *faceDetectView;
@property (strong, nonatomic) HandDetectView *handDetectView;
@property (assign, nonatomic) BOOL isShowOCR;//是否显示身份证框
@end

NS_ASSUME_NONNULL_END
