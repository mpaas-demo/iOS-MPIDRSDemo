//
//  ProRemoteCell.h
//  ProRemoteCell
//
//  Created by shaochangying.scy on 2022/1/5.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class ARTVCRenderUnit;

@interface ProRemoteCell : UICollectionViewCell

- (void)updateUI:(ARTVCRenderUnit *)renderInfo;

@end

NS_ASSUME_NONNULL_END
