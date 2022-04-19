/*
 *  Copyright 2017 The WebRTC project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import <ARTVC/RTCVideoFrame.h>

#import <ARTVC/RTCMacros.h>

NS_ASSUME_NONNULL_BEGIN

@class RTC_OBJC_TYPE(XRTCVideoCapturer);

RTC_OBJC_EXPORT
@protocol RTC_OBJC_TYPE
(XRTCVideoCapturerDelegate)<NSObject> -
    (void)capturer : (RTC_OBJC_TYPE(XRTCVideoCapturer) *)capturer didCaptureVideoFrame
    : (RTC_OBJC_TYPE(XRTCVideoFrame) *)frame;
@end

RTC_OBJC_EXPORT
@interface RTC_OBJC_TYPE (XRTCVideoCapturer) : NSObject

@property(nonatomic, weak) id<RTC_OBJC_TYPE(XRTCVideoCapturerDelegate)> delegate;

- (instancetype)initWithDelegate:(id<RTC_OBJC_TYPE(XRTCVideoCapturerDelegate)>)delegate;

@end

NS_ASSUME_NONNULL_END
