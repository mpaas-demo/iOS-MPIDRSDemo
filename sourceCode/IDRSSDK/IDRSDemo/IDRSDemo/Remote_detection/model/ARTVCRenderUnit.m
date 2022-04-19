//
//  ARTVCRenderUnit.m
//  ARTVCRenderUnit
//
//  Created by shaochangying.scy on 2022/1/5.
//
#if defined(__arm64__)
#import "ARTVCRenderUnit.h"
//#import <UIKit/UIKit.h>

@implementation ARTVCRenderUnit

- (instancetype)init {
    self = [super init];
    if (self) {
        self.frameSize = CGSizeZero;
        self.firstFrameRendered = NO;
        self.cameraStype = YES;
    }
    return self;
}


@end
#endif
