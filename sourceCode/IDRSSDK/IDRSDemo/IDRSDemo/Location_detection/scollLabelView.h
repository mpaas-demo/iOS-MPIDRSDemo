//
//  scollLabelView.h
//  IDRSDemo
//
//  Created by 崔海斌 on 2021/7/2.
//  Copyright © 2021 cuixling. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface scollLabelView : UIView

+ (scollLabelView*)shareManager;

- (void)setTextViewWithString:(NSString*)string;

- (void)setTextViewLocation:(int)location;

- (void)showTextView;

- (void)dismissTextView;

@end

NS_ASSUME_NONNULL_END
