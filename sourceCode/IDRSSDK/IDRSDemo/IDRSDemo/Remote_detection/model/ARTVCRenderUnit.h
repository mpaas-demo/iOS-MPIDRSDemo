//
//  ARTVCRenderUnit.h
//  ARTVCRenderUnit
//
//  Created by shaochangying.scy on 2022/1/5.
//

#import <Foundation/Foundation.h>
#import <ARTVC/ARTVC.h>

NS_ASSUME_NONNULL_BEGIN


@interface ARTVCRenderUnit : NSObject

@property (nonatomic, strong) ARTVCFeed *feed;

@property (nonatomic, strong) UIView *renderView;

@property (nonatomic, assign) CGSize frameSize;

@property (nonatomic, assign) BOOL firstFrameRendered;

@property (nonatomic, assign) BOOL cameraStype;

@end

NS_ASSUME_NONNULL_END
