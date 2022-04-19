//
//  MPaaSDVInfo.h
//  mPaas
//
//  Created by yangwei on 2021/4/2.
//  Copyright © 2021 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MPaaSDVInfo : NSObject

+ (MPaaSDVInfo *)sharedInstance;

@property(nonatomic, copy) NSString *dvCode;
@property(nonatomic, strong, readonly) NSString *deviceModel;

/**
* 若需要自定义dvCode，可在category中重写此方法
*/
- (NSString *)dvCode;

@end

NS_ASSUME_NONNULL_END
