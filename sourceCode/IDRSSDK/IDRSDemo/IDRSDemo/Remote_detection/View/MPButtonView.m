//
//  MPButtonView.m
//  MPIDRSSDKDemo
//
//  Created by 斌小狼 on 2021/9/24.
//  Copyright © 2021 Alipay. All rights reserved.
//

#import "MPButtonView.h"
@implementation XLSwitch

-(void)addTapBlock:(void(^)(UISwitch *btn))block{
    self.block = block;
    
    [self addTarget:self action:@selector(click:) forControlEvents:UIControlEventValueChanged];
}

- (void)click:(UISwitch*)btn{
    if (self.block) {
        self.block(btn);
    }
}

- (void)setBlock:(void (^)(UISwitch *))block{
    _block = block;
    [self addTarget:self action:@selector(click:) forControlEvents:UIControlEventValueChanged];
}
@end

@interface MPButtonView ()

@property (nonatomic, copy) NSArray* dataArr;

@end

@implementation MPButtonView

-(instancetype)initWithFrame:(CGRect)frame andNameArray:(NSArray<NSString*>*)arr{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0.4;
        self.layer.cornerRadius = 8;
            
        self.layer.masksToBounds = YES;
        
        //设置边框及边框颜色
        self.layer.borderWidth = 1;
        
//        self.layer.borderColor =[ [UIColor grayColor] CGColor];
        
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerBottomRight cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        
        _dataArr = [NSArray arrayWithArray:arr];
//        [self subViewAddButton:_dataArr withNum:11];
    }
    
    return self;
}

- (void)subViewAddButton:(NSArray*)arr withNum:(int)datanum{
    int dataNum = datanum;
    int count = [NSNumber numberWithLong:arr.count].intValue;
    int columnNum = count%dataNum == 0?count/dataNum:count/dataNum +1;
    
    float labelX = 15;
    float labelY = 15;
    float labelW = 76;
    float labelH = 30;
    
    float Margin = 8;
    
    float buttonX = labelX + labelW + Margin;
    float buttonW = 40;
    
    for (int i = 0; i < columnNum; i++) {
        for (int j = 0 ; j < dataNum; j++) {
            if (i * dataNum + j >= count) {
                return;
            }
            [self addSubview:({
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(labelX + (buttonX + buttonW + Margin) * i, labelY + (labelH + Margin) * j, labelW, labelH)];
                label.adjustsFontSizeToFitWidth = YES;
                label.text = arr[(i * dataNum + j)];
                label.textColor = [UIColor whiteColor];
                label;
            })];
            
            [self addSubview:({
                XLSwitch *swt = [[XLSwitch alloc] initWithFrame:CGRectMake(buttonX + (buttonX + buttonW + Margin) * i, labelY + (labelH + Margin) * j, labelW, labelH)];
                
                [swt addTapBlock:^(UISwitch *btn) {
                    if ([self.delegate respondsToSelector:@selector(clickButton:andWithtpye:)]) {
                        [self.delegate clickButton:btn andWithtpye:i * dataNum + j];
                    }
                }];
                swt;
            })];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
//    [self re];
    if ([UIApplication sharedApplication].statusBarOrientation == UIInterfaceOrientationPortrait) {
        [self subViewAddButton:_dataArr withNum:_dataArr.count];
    }else {
        [self subViewAddButton:_dataArr withNum:6];
    }
    
}

@end
