//
//  scollLabelView.m
//  IDRSDemo
//
//  Created by 崔海斌 on 2021/7/2.
//  Copyright © 2021 cuixling. All rights reserved.
//
#if defined(__arm64__)
#import "MProScollLabelView.h"
#import "MProXLScreen.h"

@interface MProScollLabelView()

@property (nonatomic,strong,readwrite) UILabel* label;
@property (nonatomic,strong,readwrite) UITextView* textView;

@end

@implementation MProScollLabelView
static MProScollLabelView* manager = nil;
static dispatch_once_t onceToken;
+ (MProScollLabelView*)shareManager{
    dispatch_once(&onceToken, ^{
        manager = [[MProScollLabelView alloc] initWithFrame:CGRectMake(SCREEN_HEIGHT - UI(200), SCREEN_WIDTH - UI(250), UI(180), UI(240))];
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
    self.textView.text = string;
    [self.textView becomeFirstResponder];
}

- (void)setTextViewLocation:(int)location{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.label.text = [NSString stringWithFormat:@"当前光标位置：%d",location];
        self.textView.selectedRange = NSMakeRange(location, 0);
    });
    
}

- (void)showTextView{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
}

- (void)dismissTextView{
    [self.textView resignFirstResponder];
    [self removeFromSuperview];
    [self reset];
}
- (void)reset {
    manager = nil;
    onceToken=0l;
}
@end
#endif
