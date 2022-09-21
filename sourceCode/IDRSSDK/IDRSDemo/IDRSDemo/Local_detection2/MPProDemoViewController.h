//
//  FaceSDKDemoViewController.h
//  IDRSSDKDemo
//
//  Created by cuixling on 2020/3/14.
//  Copyright © 2020年 cuixling. All rights reserved.
//
#if defined(__arm64__)
#import <UIKit/UIKit.h>
#import "MProXLMaskView.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, DemoBtnTag) {
    DemoBtnTag_SwichCamera = 0,
    DemoBtnTag_StartFlow,
    DemoBtnTag_NextDetection,
    DemoBtnTag_LastDetection,
    DemoBtnTag_RepeatCurDet,
    DemoBtnTag_RePlayCurCha,
    DemoBtnTag_TtsPauRes,
};

@interface MPProDemoViewController : UIViewController
@property (nonatomic, strong) MProXLMaskView *maskView;
@end

@interface DemoButton : UIButton

- (instancetype)initWithNormalTitle:(NSString *)str1
                      selectedTitle:(NSString *__nullable)str2;

@end
NS_ASSUME_NONNULL_END
#endif
