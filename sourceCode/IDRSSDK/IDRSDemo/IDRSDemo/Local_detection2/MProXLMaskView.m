//
//  XLMaskView.m
//  ProSDKDemo
//
//  Created by 斌小狼 on 2022/1/5.
//
#if defined(__arm64__)
#import "MProXLMaskView.h"

@interface MProXLMaskView ()

@property (nonatomic, strong) UIActivityIndicatorView* loadingView;

@property (nonatomic, strong) UIButton *button;
@end

@implementation MProXLMaskView

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.alpha = 0.4;
        [self uploadUI];
    }
    return self;
}

- (void)uploadUI{
    [self addSubview:({
        _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        _loadingView;
    })];
    
    [self addSubview:({
        _label = [[UILabel alloc] init];
        _label.font = [UIFont systemFontOfSize:18];
        _label.textColor = [UIColor redColor];
        _label;
    })];
    [self addSubview:({
        _button = [[UIButton alloc] init];
        [_button setTitle:@"退出" forState:UIControlStateNormal];
        
        [_button setTintColor:[UIColor redColor]];
//        _button.backgroundColor = [UIColor redColor];
        [_button addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        _button.hidden = true;
        _button;
    })];
    
}

- (void)layoutSubviews
{
    self.loadingView.center = self.center;
    self.label.frame = CGRectMake(100, 20, 200, 80);
    self.button.frame = self.frame;
}

- (void)loadingViewShow{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showLoadingView:) object:@(YES)];
    [self performSelector:@selector(showLoadingView:) withObject:@(YES) afterDelay:0.5];
}
- (void)loadingViewHidden{
    [self showLoadingView:@(NO)];
}

- (void)showLoadingView:(id)showObj
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showLoadingView:) object:@(YES)];
    dispatch_async(dispatch_get_main_queue(), ^{
        if ([showObj boolValue]) {
            self.loadingView.center = self.center;
            if (!self.loadingView.isAnimating) {
                [self.loadingView startAnimating];
            }
        } else {
            [self.loadingView stopAnimating];
            [self.loadingView removeFromSuperview];
            self.button.hidden = false;
        }
    });
}

- (void)btnClick:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(clickButton:)]) {
        [self.delegate clickButton:sender];
    }
}

@end
#endif
