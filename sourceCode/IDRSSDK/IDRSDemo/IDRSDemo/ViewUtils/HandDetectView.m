//
//  HandDetectView.m
//  IDRSSDKDemo
//
//  Created by cuixling on 2020/4/4.
//  Copyright © 2020年 cuixling. All rights reserved.
//

#import "HandDetectView.h"
#import <MPIDRSSDK/MPIDRSSDK.h>

#define ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight                        [[UIScreen mainScreen] bounds].size.height

const int BODY_LIMB_IDX[6][2] =
{
//    {0,  1},
	{1,  2},
	{1,  5},
	{2,  3},
	{3,  4},
	{5,  6},
	{6,  7},
};

@interface HandDetectView ()

@property (nonatomic, strong) UILabel *lbYpr;
@property (strong, nonatomic) UILabel *lbAttribute;

@property (strong, nonatomic) UILabel *lbHandAction;

@end

@implementation HandDetectView

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
	self.lbYpr.frame = CGRectMake(self.frame.size.width-size.width-4, self.uiOffsetY+4, size.width, size.height);

	size = [self.lbAttribute sizeThatFits:CGSizeMake(150, CGFLOAT_MAX)];
	self.lbAttribute.frame = CGRectMake(self.frame.size.width-size.width-4, CGRectGetMaxY(self.lbYpr.frame)+6, size.width, size.height);

	[_lbHandAction sizeToFit];
	_lbHandAction.frame = CGRectMake(CGRectGetMinX(self.lbYpr.frame)-_lbHandAction.frame.size.width-8, self.uiOffsetY+3, _lbHandAction.frame.size.width, _lbHandAction.frame.size.height);
}

-(void)setUseRedColor:(BOOL)useRedColor {
	_useRedColor = useRedColor;

	if (useRedColor) {
		self.lbYpr.textColor = [UIColor redColor];
	}
}

-(void)drawRect:(CGRect)rect {

	//获得处理的上下文
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	//设置线条样式
	CGContextSetLineCap(ctx, kCGLineCapButt);

	float w = self.presetSize.width;
	float h = self.presetSize.height;

	float sw; float sh;
	if (self.isRemoteWindow) {
		//远端视频流界面大小;
		sw = 140;
		sh = 200;
	}else{
		sw = ScreenWidth;
		sh = ScreenHeight;
		if (ScreenWidth>ScreenHeight) {
			w = self.presetSize.height;
			h = self.presetSize.width;
		}
	}

	float kw = sw/w;
	float kh = sh/h;

	// 手势识别出来的人脸框
	if (true) {
		HandDetectionOutput *xxx = _detectResult[0];

		CGContextSetRGBStrokeColor(ctx, 0.85, 0.0, 0.0, 1.0);
		CGContextSetRGBFillColor(ctx, 0.85, 0.0, 0.0, 1.0);
		CGContextSetLineWidth(ctx, 2);

		int xx = xxx.face_rect.origin.x *kw;
		int yy = xxx.face_rect.origin.y *kh;
		int ww = xxx.face_rect.size.width *kw;
		int hh = xxx.face_rect.size.height *kh;

		if (self.isRTC) {
			xx = ScreenWidth - (xxx.face_rect.origin.x *kw + h);
		}
		CGContextStrokeRect(ctx, CGRectMake(xx, yy, ww, hh));
	}

	for(int i = 0; i < _detectResult.count; i++) {
		HandDetectionOutput *outputModel = _detectResult[i];

		CGContextSetRGBStrokeColor(ctx, 0.85, 0.0, 0.0, 1.0);
		CGContextSetRGBFillColor(ctx, 0.85, 0.0, 0.0, 1.0);
		CGContextSetLineWidth(ctx, 1);

		int x;
		int y = outputModel.rect.origin.y *kh;
		int w = outputModel.rect.size.width *kw;
		int h = outputModel.rect.size.height *kh;

		if (self.isRTC) {
			x = ScreenWidth - (outputModel.rect.origin.x *kw + h);
		}else{
			x = outputModel.rect.origin.x *kw;
		}
		CGContextStrokeRect(ctx, CGRectMake(x, y, w, h));

		//火柴人
		for (int j = 1; j < 8; j++)
		{

			if (/*NULL != outputModel.body_key_points_score &&*/ outputModel.body_key_points_score[j] > 0)
			{
				float px = outputModel.body_key_points[j].x*kw;
				float py = outputModel.body_key_points[j].y*kh;
				CGContextStrokeRect(ctx, CGRectMake(px,py,10,10));
			}
		}

		for (int j = 0; j < 6; j++)
		{
			int start_idx = BODY_LIMB_IDX[j][0];
			int end_idx = BODY_LIMB_IDX[j][1];
			if (NULL != outputModel.body_key_points_score && NULL != outputModel.body_key_points_score && outputModel.body_key_points_score[start_idx] > 0
			    && outputModel.body_key_points_score[end_idx] > 0)
			{
				//设置路径颜色
				CGContextSetRGBStrokeColor(ctx,0.5,0.5, 0.5,1);
				//设置路径起始坐标
				CGContextMoveToPoint(ctx,outputModel.body_key_points[start_idx].x*kw,outputModel.body_key_points[start_idx].y*kh);

				//设置路径的终点坐标
				CGContextAddLineToPoint(ctx,outputModel.body_key_points[end_idx].x*kw, outputModel.body_key_points[end_idx].y*kh);
				//设置路径宽度
				CGContextSetLineWidth(ctx,3.0);
				//渲染路径
				CGContextStrokePath(ctx);
			}
		}
	}
}

-(void)setDetectResult:(NSArray<HandDetectionOutput *> *)detectResult {
	_detectResult = detectResult;

	if (detectResult.count>0) {
		HandDetectionOutput *handResult = detectResult[0];

		NSString *info;
		// 动态手势
		if (handResult.hand_action_type == 1 && handResult.phone_touched_score>0) {
			NSString *touched = handResult.phone_touched ? @"true" : @"false";
			info = [NSString stringWithFormat:@"%@: %@: %f--手脸对比分数:%f", touched, [self handActionTypeToText:handResult.hand_phone_action], handResult.phone_touched_score,self.face_hand_score];
			self.lbHandAction.text = info;
			NSLog(@"hand: %@", info);
		} else if (handResult.hand_action_type == 0 && handResult.hand_static_action > 0) {
			info = [NSString stringWithFormat:@"%@: %f", [self handStaticActionTypeToText:handResult.hand_static_action], handResult.hand_static_action_score];
			self.lbHandAction.text = info;
			NSLog(@"hand: %@", info);
		} else {
			self.lbHandAction.text = nil;
		}
	}

	[self setNeedsDisplay];
	[self setNeedsLayout];
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


	return [action objectAtIndex:type];;
}

@end
