//
//  scollLabelView.m
//  IDRSDemo
//
//  Created by 崔海斌 on 2021/7/2.
//  Copyright © 2021 cuixling. All rights reserved.
//

#import "scollLabelView.h"
#import "XLScreen.h"

@interface scollLabelView()

@property (nonatomic,strong,readwrite) UILabel* label;
@property (nonatomic,strong,readwrite) UITextView* textView;

@end

@implementation scollLabelView

+ (scollLabelView*)shareManager{
    static scollLabelView* manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[scollLabelView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH - UI(200), SCREEN_HEIGHT - UI(250), UI(180), UI(240))];
    });
    return manager;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
        [self addSubview:({
            _label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, UI(24))];
            _label.textColor = [UIColor whiteColor];
            _label.font = [UIFont systemFontOfSize:14];
            _label;
        })];
        [self addSubview:({
            _textView = [[UITextView alloc] initWithFrame:CGRectMake(0, UI(26), self.frame.size.width, self.frame.size.height - UI(26))];
            _textView.backgroundColor = [UIColor clearColor];
            _textView.textColor = [UIColor whiteColor];
            _textView.tintColor = [UIColor redColor];//光标颜色
            _textView.font = [UIFont systemFontOfSize:16];
            //隐藏键盘
            _textView.inputView = [[UIView alloc] init];;
            _textView;
        })];
    }
    return self;
}

- (void)setTextViewWithString:(NSString*)string{
    _textView.text = string;
    [_textView becomeFirstResponder];
}

- (void)setTextViewLocation:(int)location{
    dispatch_async(dispatch_get_main_queue(), ^{
        self->_label.text = [NSString stringWithFormat:@"当前光标位置：%d",location];
        self->_textView.selectedRange = NSMakeRange(location, 0);
    });
    
}

- (void)showTextView{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

- (void)dismissTextView{
    [_textView resignFirstResponder];
    [self removeFromSuperview];
}

@end
