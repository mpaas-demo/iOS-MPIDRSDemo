//
//  HandDetectView.m
//  IDRSSDKDemo
//
//  Created by cuixling on 2020/4/4.
//  Copyright © 2020年 cuixling. All rights reserved.
//
#if defined(__arm64__)
#import "MProHandDetectView.h"
#import <MPIDRSSDK/MPIDRSSDK.h>

#define ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight                        [[UIScreen mainScreen] bounds].size.height

@interface MProHandDetectView()

@property (nonatomic, strong) UILabel *lbYpr;
@property (strong, nonatomic) UILabel *lbAttribute;

@property (strong, nonatomic) UILabel *lbHandAction;

@end

@implementation MProHandDetectView

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
        
        self.lbHandAction = [[UILabel alloc] init];
        self.lbHandAction.textColor = [UIColor greenColor];
        self.lbHandAction.numberOfLines = 1;
        [self addSubview:self.lbHandAction];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = [self.lbYpr sizeThatFits:CGSizeMake(150, CGFLOAT_MAX)];
    self.lbYpr.frame = CGRectMake(self.frame.size.width-size.width-4, 44, size.width, size.height);
    
    size = [self.lbAttribute sizeThatFits:CGSizeMake(150, CGFLOAT_MAX)];
    self.lbAttribute.frame = CGRectMake(self.frame.size.width-size.width-4, CGRectGetMaxY(self.lbYpr.frame)+6, size.width, size.height);
    
    [_lbHandAction sizeToFit];
    _lbHandAction.frame = CGRectMake(CGRectGetMinX(self.lbYpr.frame)-_lbHandAction.frame.size.width-8, 44, _lbHandAction.frame.size.width, _lbHandAction.frame.size.height);
}

-(void)drawRect:(CGRect)rect {
    
    //获得处理的上下文
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //设置线条样式
    CGContextSetLineCap(ctx, kCGLineCapButt);
    
    float w = self.presetSize.width;
    float h = self.presetSize.height;
    
    float sw = ScreenWidth;
    float sh = ScreenHeight;
     
    
    float kw = sw/w;
    float kh = sh/h;
    

    for(int i = 0; i < _detectResult.count; i++) {
        HandDetectionOutput *outputModel = _detectResult[i];
        
        CGContextSetRGBStrokeColor(ctx, 0.85, 0.0, 0.0, 1.0);
        CGContextSetRGBFillColor(ctx, 0.85, 0.0, 0.0, 1.0);
        CGContextSetLineWidth(ctx, 1);
        
        int x = outputModel.rect.origin.x *kw;;
        if (self.isMirror) {
            x = (w - outputModel.rect.origin.x - outputModel.rect.size.width) *kw;
        }
        int y = outputModel.rect.origin.y *kh;
        int w = outputModel.rect.size.width *kw;
        int h = outputModel.rect.size.height *kh;
        
        CGContextStrokeRect(ctx, CGRectMake(x, y, w, h));
        
    }
}

-(void)setDetectResult:(NSArray<HandDetectionOutput *> *)detectResult {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self->_detectResult = detectResult;
        
        if (detectResult.count>0) {
            HandDetectionOutput *handResult = detectResult[0];
            
            NSString *info;
            // 动态手势
            if (handResult.hand_action_type == 1 && handResult.phone_touched_score>0) {
                NSString *touched = handResult.phone_touched ? @"true" : @"false";
                info = [NSString stringWithFormat:@"%@: %@: %f", touched, [self handActionTypeToText:handResult.hand_phone_action], handResult.phone_touched_score];
                self.lbHandAction.text = info;
                NSLog(@"hand: %@", info);
            } else if (handResult.hand_action_type == 0 && handResult.hand_static_action > 0) {
                info = [NSString stringWithFormat:@"%@: %f", [self handStaticActionTypeToText:handResult.hand_static_action], handResult.hand_static_action_score];
                self.lbHandAction.text = info;
                NSLog(@"hand: %@", info);
            } else {
                self.lbHandAction.text = nil;
            }
        } else {
            self->_lbYpr.text = @"";
            self->_lbAttribute.text = @"";
        }
        
        [self setNeedsDisplay];
        [self setNeedsLayout];
    });
}

- (NSString*)handActionTypeToText:(int)type {
    
    switch (type) {
        case 0:
            return @"未知";
            break;
        case 1:
            return @"签字";
            break;
        case 2:
            return @"翻页";
            break;
        default:
            break;
    }
    
    return 0;
}

- (NSString*)handStaticActionTypeToText:(int)type {
    NSArray *action = @[@"Unknown",
                        @"Blur",
                        @"OK",
                        @"Palm",
                        @"Finger",
                        @"NO.8",
                        @"Heart",
                        @"Fist",
                        @"Holdup",
                        @"Congratulate",
                        @"Yeah",
                        @"Love",
                        @"Good",
                        @"Rock",
                        @"NO.3",
                        @"NO.4",
                        @"NO.6",
                        @"NO.7",
                        @"NO.9",
                        @"Greeting",
                        @"Pray",
                        @"Thumbs_down",
                        @"Thumbs_left",
                        @"Thumbs_right",
                        @"Hello",
                        @"Silence",];
    
    
    return  [action objectAtIndex:type];;
}

@end
#endif
