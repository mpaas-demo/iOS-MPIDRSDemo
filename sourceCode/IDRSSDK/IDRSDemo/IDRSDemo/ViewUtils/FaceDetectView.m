//
//  FaceDetectView.m
//  IDRSSDKDemo
//
//  Created by cuixling on 2020/3/18.
//  Copyright © 2020年 cuixling. All rights reserved.
//

#import "FaceDetectView.h"
#import <MPIDRSSDK/MPIDRSSDK.h>

#define ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight                        [[UIScreen mainScreen] bounds].size.height

@interface FaceDetectView ()

@property (nonatomic, strong) UILabel *lbYpr;
@property (strong, nonatomic) UILabel *lbAttribute;

@property (strong, nonatomic) UILabel *lbRecognitionScore;


@end

@implementation FaceDetectView

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

		self.lbLiveness = [[UILabel alloc] init];
		self.lbLiveness.textColor = [UIColor greenColor];
		self.lbLiveness.numberOfLines = 1;
		[self addSubview:self.lbLiveness];
	}
	return self;
}

-(void)layoutSubviews {
	[super layoutSubviews];

	CGSize size = [self.lbYpr sizeThatFits:CGSizeMake(150, CGFLOAT_MAX)];
	self.lbYpr.frame = CGRectMake(self.frame.size.width-size.width-4, self.uiOffsetY+4, size.width, size.height);

	size = [self.lbAttribute sizeThatFits:CGSizeMake(150, CGFLOAT_MAX)];
	self.lbAttribute.frame = CGRectMake(self.frame.size.width-size.width-4, CGRectGetMaxY(self.lbYpr.frame)+6, size.width, size.height);

	[_lbRecognitionScore sizeToFit];
	_lbRecognitionScore.frame = CGRectMake(CGRectGetMinX(self.lbYpr.frame)-_lbRecognitionScore.frame.size.width-8, self.uiOffsetY+6, _lbRecognitionScore.frame.size.width, _lbRecognitionScore.frame.size.height);

	[_lbLiveness sizeToFit];
	_lbLiveness.frame = CGRectMake(CGRectGetMinX(self.lbYpr.frame)-_lbLiveness.frame.size.width-8, CGRectGetMaxY(_lbRecognitionScore.frame)+10, _lbLiveness.frame.size.width, _lbLiveness.frame.size.height);
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
	CGContextSetLineCap(ctx, kCGLineCapSquare);

	if (_useRedColor) {
		CGContextSetRGBStrokeColor(ctx, 1.0, 0.0, 0.0, 1.0);
	} else {
		CGContextSetRGBStrokeColor(ctx, 1.0, 1.0, 1.0, 1.0);
	}
	//设置线条粗细宽度
	CGContextSetLineWidth(ctx, 1.5);

	float w = self.presetSize.width;//720 w  1280 h
	float h = self.presetSize.height;
	if (ScreenWidth>ScreenHeight && !self.isRemoteWindow &&!self.isRTC) {
		w = self.presetSize.height;
		h = self.presetSize.width;
	}
	float kw = self.frame.size.width/w;
	float kh = self.frame.size.height/h;
	for(int i = 0; i < _detectResult.count; i++) {
		FaceDetectionOutput *outputModel = _detectResult[i];
		int x = outputModel.rect.origin.x *kw;;
		if (self.isRTC) {
			if ([self getIsIpad]) {
				//x = (outputModel.rect.origin.x - 150) *kw;
				x = (w - outputModel.rect.origin.x - outputModel.rect.size.width - 150) *kw;
			}else{
				x = (w - outputModel.rect.origin.x - outputModel.rect.size.width) *kw;
			}
		}
		int y = outputModel.rect.origin.y *kh;
		int w = outputModel.rect.size.width *kw;
		int h = outputModel.rect.size.height *kh;

		CGContextStrokeRect(ctx, CGRectMake(x, y, w, h));

		// score
//        NSString *str = [NSString stringWithFormat:@"%f", outputModel.score];
//        UIFont *font = [UIFont systemFontOfSize:14.0];
//        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
//        [paragraphStyle setAlignment:NSTextAlignmentLeft];
//        CGRect iRect = CGRectMake(x, y-16, w, 20);
//        UIColor *color = _useRedColor?[UIColor redColor]:[UIColor whiteColor];
//        [str drawInRect:iRect withAttributes:@{NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:color}];
        NSString *str = outputModel.label;
        UIFont *font = [UIFont systemFontOfSize:20.0];
        NSMutableParagraphStyle *paragraphStyle = [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
        [paragraphStyle setAlignment:NSTextAlignmentLeft];
        CGRect iRect = CGRectMake(x, y-22, w, 20);
        UIColor *color = _useRedColor?[UIColor redColor]:[UIColor redColor];
        [str drawInRect:iRect withAttributes:@{NSFontAttributeName:font,NSParagraphStyleAttributeName:paragraphStyle,NSForegroundColorAttributeName:color}];
	}
}
-(BOOL)getIsIpad {

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
- (void)setRecognitionScore:(float)recognitionScore {
	_recognitionScore = recognitionScore;

	if (_recognitionScore>=0) {
		_lbRecognitionScore.text = [NSString stringWithFormat:@"相似度：%f", recognitionScore];
	}

	[self setNeedsLayout];
}

-(void)setDetectResult:(NSArray<FaceDetectionOutput *> *)detectResult {
	_detectResult = detectResult;

	if (detectResult.count>0) {
		FaceDetectionOutput *faceResult = detectResult[0];
//        NSLog(@"当前线程：%@",[NSThread currentThread]);
		NSString *attr = @"";
		NSDictionary *attributeDic = faceResult.attributes;
		for (NSString *categoryvalue in attributeDic) {
			NSDictionary *valueDic = attributeDic[categoryvalue];
			NSString *str = [NSString stringWithFormat:@"%@: %@ %@\n", categoryvalue, valueDic[@"label"], valueDic[@"score"]];
			attr = [NSString stringWithFormat:@"%@%@", attr, str];
		}
		_lbAttribute.text = attr;

		self.lbLiveness.text = [NSString stringWithFormat:@"%@", [self livenessTypeToText:detectResult]];
	} else {
		_lbYpr.text = @"";
		_lbAttribute.text = @"";
		_lbRecognitionScore.text = @"";
	}

	[self setNeedsDisplay];
	[self setNeedsLayout];
}

- (NSString*)livenessTypeToText:(NSArray<FaceDetectionOutput *> *)detectResult {
	NSString * type0 = @"";
	for(int i = 0; i < detectResult.count; i++) {
		FaceDetectionOutput *faceDetection = detectResult[i];
		NSString * type = @"";
		if (faceDetection.livenessType == 0) {
			type = @"真人";
		}else if (faceDetection.livenessType == 1) {
			type = @"翻拍";
		}else if (faceDetection.livenessType == 2) {
			type = @"翻拍";
		}
		type0 = [NSString stringWithFormat:@"%@-%@", type0, type];
	}

	return type0;;
}

@end
