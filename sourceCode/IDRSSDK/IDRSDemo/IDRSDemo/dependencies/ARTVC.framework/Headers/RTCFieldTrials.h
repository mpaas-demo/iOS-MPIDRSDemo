/*
 *  Copyright 2016 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#import <Foundation/Foundation.h>

#import <ARTVC/RTCMacros.h>

/** The only valid value for the following if set is kXRTCFieldTrialEnabledValue. */
RTC_EXTERN NSString * const kXRTCFieldTrialAudioSendSideBweKey;
RTC_EXTERN NSString * const kXRTCFieldTrialAudioForceNoTWCCKey;
RTC_EXTERN NSString * const kXRTCFieldTrialAudioForceABWENoTWCCKey;
RTC_EXTERN NSString * const kXRTCFieldTrialSendSideBweWithOverheadKey;
RTC_EXTERN NSString * const kXRTCFieldTrialFlexFec03AdvertisedKey;
RTC_EXTERN NSString * const kXRTCFieldTrialFlexFec03Key;
RTC_EXTERN NSString * const kXRTCFieldTrialH264HighProfileKey;
RTC_EXTERN NSString * const kXRTCFieldTrialMinimizeResamplingOnMobileKey;
RTC_EXTERN NSString * const kXRTCFieldTrialUseNWPathMonitor;
/* ADD_FOR_MRTC_BEGIN */
RTC_EXTERN NSString * const kXRTCFieldTrialBweLossExperimentKey;
RTC_EXTERN NSString * const kXRTCFieldTrialPacingExperimentKey;
RTC_EXTERN NSString * const kXRTCFieldTrialNackExperimentKey;
RTC_EXTERN NSString * const kXRTCFieldTrialPlayoutDelayExperimentKey;
RTC_EXTERN NSString * const kXRTCFieldTrialJitterEstimatorExperimentKey;
RTC_EXTERN NSString * const kXRTCFieldTrialVideoSmoothRenderingExperimentKey;
RTC_EXTERN NSString * const kXRTCFieldTrialVideoTimingExperimentKey;
RTC_EXTERN NSString * const kXRTCFieldTrialICEExperimentKey;
RTC_EXTERN NSString * const kXRTCFieldTrialDPExperimentKey;
RTC_EXTERN NSString * const kXRTCFieldTrialAvSyncExperimentKey;
RTC_EXTERN NSString * const kXRTCFieldTrialNetEqDelayManagerConfigKey;
RTC_EXTERN NSString * const kXRTCFieldTrialBBRBweExperimentKey;
#ifdef MRTC_ENABLE_WWDC21_VIDEOTOOLBOX
RTC_EXTERN NSString * const kXRTCFieldTrialVideoToolboxLowLatencyEncodeExperimentKey;
#endif
RTC_EXTERN NSString * const kXRTCFieldTriaRSFecExperimentKey;
RTC_EXTERN NSString * const kXRTCFieldTrialVideoNackOptimizationExperimentKey;
RTC_EXTERN NSString * const kXRTCFieldTrialDtlsExperimentKey;
/* ADD_FOR_MRTC_END */
/** The valid value for field trials above. */
RTC_EXTERN NSString * const kXRTCFieldTrialEnabledValue;
/* ADD_FOR_MRTC_BEGIN */
RTC_EXTERN NSString * const kXRTCFieldTrialDisabledValue;
/* ADD_FOR_MRTC_END */

/** Initialize field trials using a dictionary mapping field trial keys to their
 * values. See above for valid keys and values. Must be called before any other
 * call into WebRTC. See: webrtc/system_wrappers/include/field_trial.h
 */
RTC_EXTERN void XRTCInitFieldTrialDictionary(NSDictionary<NSString *, NSString *> *fieldTrials);
/**
 * Deprecated 
 */ 
RTC_EXTERN void XRTCInitFieldTrialPHPL(BOOL phpl);
