//
//  MPResample.hpp
//  MPIDRSSDKDemo
//
//  Created by 斌小狼 on 2021/10/29.
//  Copyright © 2021 Alipay. All rights reserved.
//
//音频数据重采样----48k->16K
#ifndef MPResample_hpp
#define MPResample_hpp

#include <stdio.h>
#include <stdint.h>

typedef struct {
    uint8_t        *buf;//数据
    int             len;//长度
    int             sample_rate;//采样率
    int             sample_depth;//深度
} pcm_frame_t;

void pcm_resample_16k(const pcm_frame_t *frame_in, pcm_frame_t *frame_out);

#endif /* MPResample_hpp */
