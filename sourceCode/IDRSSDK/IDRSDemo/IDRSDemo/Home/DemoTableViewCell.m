//
//  DemoTableViewCell.m
//  IDRSSDKDemo
//
//  Created by cuixling on 2020/3/15.
//  Copyright © 2020年 cuixling. All rights reserved.
//

#import "DemoTableViewCell.h"

@interface DemoTableViewCell ()

@property (nonatomic, strong) UILabel *label;

@end

@implementation DemoTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {

	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
	if (self) {
		self.selectionStyle = UITableViewCellSelectionStyleNone;

		_label = [[UILabel alloc] init];
		_label.font = [UIFont systemFontOfSize:18.f];
		_label.textAlignment = NSTextAlignmentCenter;
		[self.contentView addSubview:_label];

		_label.layer.backgroundColor = [UIColor whiteColor].CGColor;
		_label.layer.shadowOffset = CGSizeMake(1, 1);
		_label.layer.shadowRadius = 2.0;
		_label.layer.shadowColor = [UIColor blackColor].CGColor;
		_label.layer.shadowOpacity = 0.2;
		_label.layer.cornerRadius = 8.f;
	}

	return self;
}

-(void)setDataDic:(NSDictionary *)dataDic {
	_dataDic = dataDic;

	_label.text = _dataDic[@"title"];
}

- (void)layoutSubviews {
	[super layoutSubviews];

	_label.frame = CGRectMake(12, 12, self.frame.size.width-12*2, self.frame.size.height-8*2);
}

@end
