/*
 *  Copyright 2016 The WebRTC Project Authors. All rights reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

#ifndef SDK_OBJC_BASE_RTCMACROS_H_
#define SDK_OBJC_BASE_RTCMACROS_H_

#ifdef WEBRTC_ENABLE_OBJC_SYMBOL_EXPORT

#if defined(WEBRTC_LIBRARY_IMPL)
#define RTC_OBJC_EXPORT __attribute__((visibility("default")))
#endif

#endif  // WEBRTC_ENABLE_OBJC_SYMBOL_EXPORT

#ifndef RTC_OBJC_EXPORT
#define RTC_OBJC_EXPORT
#endif

// Internal macros used to correctly concatenate symbols.
#define RTC_SYMBOL_CONCAT_HELPER(a, b) a##b
#define RTC_SYMBOL_CONCAT(a, b) RTC_SYMBOL_CONCAT_HELPER(a, b)

// RTC_OBJC_TYPE_PREFIX
//
// Macro used to prepend a prefix to the API types that are exported with
// RTC_OBJC_EXPORT.
//
// Clients can patch the definition of this macro locally and build
// WebRTC.framework with their own prefix in case symbol clashing is a
// problem.
//
// This macro must only be defined here and not on via compiler flag to
// ensure it has a unique value.
#define RTC_OBJC_TYPE_PREFIX

// RCT_OBJC_TYPE
//
// Macro used internally to declare API types. Declaring an API type without
// using this macro will not include the declared type in the set of types
// that will be affected by the configurable RTC_OBJC_TYPE_PREFIX.
#define RTC_OBJC_TYPE(type_name) RTC_SYMBOL_CONCAT(RTC_OBJC_TYPE_PREFIX, type_name)

#if defined(__cplusplus)
#define RTC_EXTERN extern "C" RTC_OBJC_EXPORT
#else
#define RTC_EXTERN extern RTC_OBJC_EXPORT
#endif

#ifdef __OBJC__
#define RTC_FWD_DECL_OBJC_CLASS(classname) @class classname
#else
#define RTC_FWD_DECL_OBJC_CLASS(classname) typedef struct objc_object classname
#endif
//ADD_FOR_MRTC_BEGIN	
//-----------macro add for old p2p sdk begin -----------------------------------------------
//macro below MUST changed according to different branch
//undef macro first if already defined in webrtc/BUILD.gn,or there is compiling error below:
//error: 'USE_BUILTIN_WEBSOCKET_CHANNEL' macro redefined [-Werror,-Wmacro-redefined]
#if defined(USE_BUILTIN_WEBSOCKET_CHANNEL)
#undef USE_BUILTIN_WEBSOCKET_CHANNEL
#endif
#define USE_BUILTIN_WEBSOCKET_CHANNEL

#if defined(ARTVC_SMALLEST_BINARY)
#undef ARTVC_SMALLEST_BINARY
#endif
#define ARTVC_SMALLEST_BINARY

#if defined(ARTVC_ENABLE_STATS)
#undef ARTVC_ENABLE_STATS
#endif
#define ARTVC_ENABLE_STATS
//-----------macro add for old p2p sdk end -----------------------------------------------

//ADD_FOR_MRTC_END

//Don't ADD macros manually between the range below!! Add them above if needed.
//Macors between the range below will be automatically modified during buiding.

//Don't DELETE or MODIFY this line!Macros defined bleow is generated by build scripts automatically.begin
//-----define macro ARTVC_BUILD_FOR_MPAAS begin-----
#if defined(ARTVC_BUILD_FOR_MPAAS)
#undef ARTVC_BUILD_FOR_MPAAS
#endif
#define ARTVC_BUILD_FOR_MPAAS
//-----define macro ARTVC_BUILD_FOR_MPAAS end-----
//-----define macro ARTVC_BUILD_FOR_NOT_USEBLOX begin-----
#if defined(ARTVC_BUILD_FOR_NOT_USEBLOX)
#undef ARTVC_BUILD_FOR_NOT_USEBLOX
#endif
#define ARTVC_BUILD_FOR_NOT_USEBLOX
//-----define macro ARTVC_BUILD_FOR_NOT_USEBLOX end-----
//-----define macro ARTVC_ENABLE_E2EE begin-----
//#if defined(ARTVC_ENABLE_E2EE)
//#undef ARTVC_ENABLE_E2EE
//#endif
//#define ARTVC_ENABLE_E2EE
//-----define macro ARTVC_ENABLE_E2EE end-----
//-----define macro MRTC_ENABLE_VIDEO_CODEC_OPTIMIZATION begin-----
#if defined(MRTC_ENABLE_VIDEO_CODEC_OPTIMIZATION)
#undef MRTC_ENABLE_VIDEO_CODEC_OPTIMIZATION
#endif
#define MRTC_ENABLE_VIDEO_CODEC_OPTIMIZATION
//-----define macro MRTC_ENABLE_VIDEO_CODEC_OPTIMIZATION end-----
//-----define macro WEBRTC_BUILD_LIBAOM begin-----
#if defined(WEBRTC_BUILD_LIBAOM)
#undef WEBRTC_BUILD_LIBAOM
#endif
#define WEBRTC_BUILD_LIBAOM
//-----define macro WEBRTC_BUILD_LIBAOM end-----
//-----define macro MRTC_ENABLE_UNIFIED_PLAN begin-----
#if defined(MRTC_ENABLE_UNIFIED_PLAN)
#undef MRTC_ENABLE_UNIFIED_PLAN
#endif
#define MRTC_ENABLE_UNIFIED_PLAN
//-----define macro MRTC_ENABLE_UNIFIED_PLAN end-----
//-----define macro MRTC_ENABLE_WWDC21_VIDEOTOOLBOX begin-----
//#if defined(MRTC_ENABLE_WWDC21_VIDEOTOOLBOX)
//#undef MRTC_ENABLE_WWDC21_VIDEOTOOLBOX
//#endif
//#define MRTC_ENABLE_WWDC21_VIDEOTOOLBOX
//-----define macro MRTC_ENABLE_WWDC21_VIDEOTOOLBOX end-----
//-----define macro MRTC_ENABLE_H264_HIGH_PROFILE begin-----
//#if defined(MRTC_ENABLE_H264_HIGH_PROFILE)
//#undef MRTC_ENABLE_H264_HIGH_PROFILE
//#endif
//#define MRTC_ENABLE_H264_HIGH_PROFILE
//-----define macro MRTC_ENABLE_H264_HIGH_PROFILE end-----
//Don't DELETE or MODIFY this line!Macros defined bleow is generated by build scripts automatically.end
#endif  // SDK_OBJC_BASE_RTCMACROS_H_