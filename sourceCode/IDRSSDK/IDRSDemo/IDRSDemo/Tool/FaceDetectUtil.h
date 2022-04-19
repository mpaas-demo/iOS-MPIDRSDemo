//
//  FaceDetectUtil.h
//  IDRSSDKDemo
//
//  Created by cuixling on 2020/5/13.
//  Copyright © 2020年 cuixling. All rights reserved.
//

#ifndef FaceDetectUtil_h
#define FaceDetectUtil_h
#import <MPIDRSSDK/MPIDRSSDK.h>

@interface FaceDetectUtil : NSObject

@property (nonatomic, strong) NSMutableArray<NSNumber*> *faceIds;
@property (nonatomic, strong) NSMutableArray<NSArray<FaceDetectionOutput *>*> *faceArr;

/**
   构造器
   @return FaceDetectUtil的实体
 */
+ (FaceDetectUtil *)init;

// 人脸追踪是否有变化
- (BOOL)isFaceTrackChanged:(nonnull NSArray<FaceDetectionOutput *>*)faces;

- (int)getLiveType:(NSInteger)faceId;

@end
#endif /* FaceDetectUtil_h */
