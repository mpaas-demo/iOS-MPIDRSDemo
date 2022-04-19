//
//  DemoSetting.h
//  DemoSetting
//
//  Created by shaochangying.scy on 2021/11/23.
//  Copyright © 2021 Alipay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIkit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DemoSetting : NSObject

+ (instancetype)sharedInstance;

@property (nonatomic, copy) NSString *processId;//流程ID

@property (nonatomic, copy) NSString *watermarkId;

@property (nonatomic, copy) NSString *userId;

@property (nonatomic, strong) NSMutableArray *photos;//照片

@property (nonatomic, strong) NSMutableArray *names;//人名

@property (nonatomic, copy) NSString *appId;

@property (nonatomic, copy) NSString *packageName;

@property (nonatomic, copy) NSString *ak;

@property (nonatomic, copy) NSString *sk;

- (void)saveData;

@end

NS_ASSUME_NONNULL_END
