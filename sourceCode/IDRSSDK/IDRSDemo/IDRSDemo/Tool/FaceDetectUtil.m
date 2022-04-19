//
//  FaceDetectUtil.m
//  IDRSSDKDemo
//
//  Created by cuixling on 2020/5/13.
//  Copyright © 2020年 cuixling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FaceDetectUtil.h"

@implementation FaceDetectUtil



+ (FaceDetectUtil *)init {
	FaceDetectUtil *util = [[FaceDetectUtil alloc] initUtil];
	return util;
}

- (instancetype)initUtil {
	self = [super init];
	if (self) {
		self.faceIds = [NSMutableArray array];
		self.faceArr = [NSMutableArray array];
	}
	return self;
}

// 人脸追踪是否有变化
- (BOOL)isFaceTrackChanged:(nonnull NSArray<FaceDetectionOutput *>*)faces {
	BOOL isChanged = false;
	if (faces.count == 0) {
		// 没有人脸，清空已有数组
		[_faceIds removeAllObjects];
		[_faceArr removeAllObjects];
		return true;
	}

	if (_faceArr.count < 30) {
		// 不够10帧，需要继续采集活体
		[self updateFaceIds:faces];
		[_faceArr addObject:faces];
		NSLog(@"added face type: %d, %f", faces[0].livenessType, faces[0].livenessScore);
		return true;
	}

	// 够30帧了，判断faceid是否有变化
	for (FaceDetectionOutput *face in faces) {
		NSInteger faceId = face.faceId;
		NSLog(@"current faceid: %ld", (long)faceId);
		BOOL isFinded = false;
		for (int i = 0; i< _faceIds.count; i++) {
			if(faceId == [_faceIds[i] intValue]) {
				isFinded = true;
			}
		}
		if (!isFinded) {
			isChanged = true;
		}
	}
	[self updateFaceIds:faces];

	// 人脸id有变化，清空faceArr
	if(isChanged) {
		[_faceArr removeAllObjects];
	}
	return isChanged;
}

- (int)getLiveType:(NSInteger)faceId {
	NSMutableArray<FaceDetectionOutput *> *findedFaces = [NSMutableArray array];
	for (int i = 0; i < _faceArr.count; i++) {
		NSArray<FaceDetectionOutput *>* faces = _faceArr[i];
		for (int j = 0; j < faces.count; j++) {
			if(faces[j].faceId == faceId) {
				[findedFaces addObject:faces[j]];
			}
		}
	}
	if(findedFaces.count == 0) {
		return -1;
	}
	int realCount = 0;
	int fakeCount = 0;
	for (int i = 0; i < findedFaces.count; i++) {
//        NSLog(@"facetype: %d, %f", findedFaces[i].livenessType, findedFaces[i].livenessScore);

		int type = [self getFaceType:findedFaces[i]];
		if (type == 0) {
			realCount++;
		} else {
			fakeCount++;
		}
	}
//    NSLog(@"facetype: %d, %d", realCount, fakeCount);
	if (realCount < fakeCount) {
		return 1;
	}
	return 0;
}

- (void)updateFaceIds:(nonnull NSArray<FaceDetectionOutput *>*)faces {
	[_faceIds removeAllObjects];
	for (FaceDetectionOutput *face in faces) {
		NSInteger num = face.faceId;
		NSNumber *number = [NSNumber numberWithInteger:num];
		[_faceIds addObject:number];
	}
}

- (int)getFaceType:(nonnull FaceDetectionOutput *)face {
	int type = face.livenessType;
	float score = face.livenessScore;
	if (type == 1 || type == 2) {
		if (score > 0.85) {
			return 1;
		}
	}
	return 0;
}

@end
