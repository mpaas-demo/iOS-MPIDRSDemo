//
//  MPButtonView.h
//  MPIDRSSDKDemo
//
//  Created by 斌小狼 on 2021/9/24.
//  Copyright © 2021 Alipay. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MPButtonViewDelegate <NSObject>

- (void)clickButton:(UISwitch*)btn andWithtpye:(int)state;

@end

@interface XLSwitch :UISwitch
@property(nonatomic,copy) void(^block)(UISwitch*);
- (void)addTapBlock:(void(^)(UISwitch *btn))block;
@end


@interface MPButtonView : UIView

@property (nonatomic, weak) id<MPButtonViewDelegate> delegate;

-(instancetype)initWithFrame:(CGRect)frame andNameArray:(NSArray<NSString*>*)arr;

@end

