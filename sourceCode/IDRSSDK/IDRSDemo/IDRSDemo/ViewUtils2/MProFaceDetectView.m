//
//  FaceDetectView.m
//  IDRSSDKDemo
//
//  Created by cuixling on 2020/3/18.
//  Copyright © 2020年 cuixling. All rights reserved.
//
#if defined(__arm64__)
#import "MProFaceDetectView.h"
#import <MPIDRSProcess/MPIDRSProcess.h>

#define ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight                        [[UIScreen mainScreen] bounds].size.height

@interface MProFaceDetectView()

@property (nonatomic, strong) UILabel *lbYpr;
@property (strong, nonatomic) UILabel *lbAttribute;

@property (strong, nonatomic) UILabel *lbRecognitionScore;


@end

@implementation MProFaceDetectView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.lbYpr = [[UILabel alloc] init];
        self.lbYpr.textColor = [UIColor greenColor];
        self.lbYpr.numberOfLines = 0;
        [self addSubview:self.lbYpr];

        self.lbAttribute = [[UILabel alloc] init];
        self.lbAttribute.textColor = [UIColor greenColor];
        self.lbAttribute.numberOfLines = 0;
        [self addSubview:self.lbAttribute];

        self.lbRecognitionScore = [[UILabel alloc] init];
        self.lbRecognitionScore.textColor = [UIColor greenColor];
        self.lbRecognitionScore.numberOfLines = 1;
        [self addSubview:self.lbRecognitionScore];

    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];

    CGSize size = [self.lbYpr sizeThatFits:CGSizeMake(150, CGFLOAT_MAX)];

    size = [self.lbAttribute sizeThatFits:CGSizeMake(150, CGFLOAT_MAX)];
    self.lbAttribute.frame = CGRectMake(self.frame.size.width-size.width-4, CGRectGetMaxY(self.lbYpr.frame)+6, size.width, size.height);

    [_lbRecognitionScore sizeToFit];
    _lbRecognitionScore.frame = CGRectMake(CGRectGetMinX(self.lbYpr.frame)-_lbRecognitionScore.frame.size.width-8, 6, _lbRecognitionScore.frame.size.width, _lbRecognitionScore.frame.size.height);

}


-(void)drawRect:(CGRect)rect {

    //获得处理的上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //设置线条样式
    CGContextSetLineCap(ctx, kCGLineCapSquare);
    
//    CGContextSetRGBStrokeColor(ctx, 1.0, 0.0, 0.0, 1.0);
    CGContextSetRGBStrokeColor(ctx, 1.0, 1.0, 1.0, 1.0);
    //设置线条粗细宽度
    CGContextSetLineWidth(ctx, 1.5);

    float w = self.presetSize.width;
    float h = self.presetSize.height;
    
    float kw = self.frame.size.width/w;
    float kh = self.frame.size.height/h;
    for(int i = 0; i < _detectResult.count; i++) {
        faceUIAndName *outputModel = _detectResult[i];
        int x = outputModel.rect.origin.x *kw;;
        if (self.isMirror) {
            x = (w - outputModel.rect.origin.x - outputModel.rect.size.width) *kw;
        }
        int y = outputModel.rect.origin.y *kh;
        int w = outputModel.rect.size.width *kw;
        int h = outputModel.rect.size.height *kh;

        CGContextStrokeRect(ctx, CGRectMake(x, y, w, h));
        NSString *str = [NSString stringWithFormat:@"%@--%@",outputModel.name,outputModel.livenessType == 0? @"真人":@"翻拍"] ;
        UIFont *font = [UIFont systemFontOfSize:20.0];
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [paragraphStyle setAlignment:NSTextAlignmentLeft];
        CGRect iRect = CGRectMake(x, y-22, w, 20);
        UIColor *color = [UIColor redColor];
        [str drawInRect:iRect withAttributes:@{NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:color}];
    }
}
-(BOOL)getIsIpad{

    NSString *deviceType = [UIDevice currentDevice].model;

    if([deviceType isEqualToString:@"iPhone"]) {
        //iPhone
        return NO;
    }
    else if([deviceType isEqualToString:@"iPod touch"]) {
        //iPod Touch
        return NO;
    }
    else if([deviceType isEqualToString:@"iPad"]) {
        //iPad
        return YES;
    }
    return NO;
}

-(void)setDetectResult:(NSArray<faceUIAndName *> *)detectResult {
    dispatch_async(dispatch_get_main_queue(), ^{

        self->_detectResult = detectResult;
        if (detectResult.count>0) {
            faceUIAndName *faceResult = detectResult[0];
            NSString *isLiven = @"";
            switch (faceResult.isLiveness) {
                case 0:
                    isLiven = @"";
                    break;
                case 1:
                    isLiven = @"活体";
                    break;
                case 2:
                    isLiven = @"非活体";
                    break;
                default:
                    break;
            }
            
            self.lbRecognitionScore.text = [NSString stringWithFormat:@"%@",isLiven];
        } else {
            self->_lbYpr.text = @"";
            self->_lbAttribute.text = @"";
            self->_lbRecognitionScore.text = @"";
        }

        [self setNeedsDisplay];
        [self setNeedsLayout];
    });
}

@end
#endif
