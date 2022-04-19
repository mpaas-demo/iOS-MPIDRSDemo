/*
 *  Copyright 2017 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import <AVFoundation/AVFoundation.h>

#import <ARTVC/RTCMacros.h>

NS_ASSUME_NONNULL_BEGIN

@protocol RTC_OBJC_TYPE
(XRTCI420Buffer);

// XRTCVideoFrameBuffer is an ObjectiveC version of xwebrtc::VideoFrameBuffer.
RTC_OBJC_EXPORT
@protocol RTC_OBJC_TYPE
(XRTCVideoFrameBuffer)<NSObject>

    @property(nonatomic, readonly) int width;
@property(nonatomic, readonly) int height;

- (id<RTC_OBJC_TYPE(XRTCI420Buffer)>)toI420;

@end

NS_ASSUME_NONNULL_END
