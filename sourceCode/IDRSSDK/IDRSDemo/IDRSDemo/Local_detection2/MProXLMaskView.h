//
//  XLMaskView.h
//  ProSDKDemo
//
//  Created by 斌小狼 on 2022/1/5.
//
#if defined(__arm64__)
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol XLMaskViewDelegate <NSObject>

- (void)clickButton:(UIButton*)sender;

@end

@interface MProXLMaskView : UIView

@property (nonatomic, weak) id<XLMaskViewDelegate> delegate;

@property (nonatomic, strong) UILabel *label;

- (void)loadingViewShow;

- (void)loadingViewHidden;

@end
#endif
NS_ASSUME_NONNULL_END
