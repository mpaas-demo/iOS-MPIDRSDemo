//
//  MPGestureView.m
//  MPIDRSSDKDemo
//
//  Created by 斌小狼 on 2021/9/24.
//  Copyright © 2021 Alipay. All rights reserved.
//

#import "MPDrawView.h"

@interface MPDrawView()
@property (nonatomic, strong) UIImageView * ocrImageView;
@end

@implementation MPDrawView
- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:({
            _faceDetectView = [[FaceDetectView alloc] initWithFrame:frame];
            _faceDetectView;
        })];
        
        [self addSubview:({
            _handDetectView = [[HandDetectView alloc] initWithFrame:frame];
            _handDetectView;
        })];
        [self addSubview:({
            _ocrImageView = [self OCRRect];
            _ocrImageView.hidden = true;
            _ocrImageView;
        })];
    }
    return self;
}

- (void)setIsShowOCR:(BOOL)isShowOCR{
    _ocrImageView.hidden = !isShowOCR;
}

- (UIImageView*)OCRRect{
    CGRect rect = self.bounds;
    CGRect scanFrame = CGRectMake(rect.size.width*0.2, rect.size.height*0.2, rect.size.width*0.6, rect.size.height*0.6);
    NSString *bundlePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"MPIDRSSDK.bundle"];
    NSString * scanImagePath = [bundlePath stringByAppendingPathComponent:@"scan"];
    UIImage *scanImage = [UIImage imageNamed:scanImagePath];
    UIImageView* imageView = [[UIImageView alloc] initWithFrame:scanFrame];
    
    imageView.image = scanImage;
    imageView.backgroundColor = [UIColor clearColor];
    return imageView;
}

- (void)layoutSubviews {
    _faceDetectView.frame = self.frame;
    _handDetectView.frame = self.frame;
}

@end
