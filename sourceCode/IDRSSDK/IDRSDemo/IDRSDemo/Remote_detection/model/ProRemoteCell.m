//
//  ProRemoteCell.m
//  ProRemoteCell
//
//  Created by shaochangying.scy on 2022/1/5.
//
#if defined(__arm64__)
#import "ProRemoteCell.h"
#import "ARTVCRenderUnit.h"

@implementation ProRemoteCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if(self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)updateUI:(ARTVCRenderUnit *)renderInfo; {
    if (renderInfo.renderView) {
        renderInfo.renderView.frame = CGRectMake(0, 0, 80, 80);
        [self.contentView addSubview:renderInfo.renderView];
    }
}






@end
#endif
