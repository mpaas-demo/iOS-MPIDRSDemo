//
//  MPResample.cpp
//  MPIDRSSDKDemo
//
//  Created by 斌小狼 on 2021/10/29.
//  Copyright © 2021 Alipay. All rights reserved.
//

#include "MPResample.hpp"
void pcm_resample_16k(const pcm_frame_t *frame_in, pcm_frame_t *frame_out)
{
    int i;
    int magnification = frame_in->sample_rate / 16000;

    frame_out->buf = frame_in->buf;
    frame_out->len = frame_in->len / magnification;
    frame_out->sample_rate = 16000;
    frame_out->sample_depth = frame_in->sample_depth;


    for (i = 0; i < frame_out->len; i++) {
        frame_out->buf[i] = frame_in->buf[i*magnification]; /* 取第一个特征值 */
    }

    /* 如果按照16bit来 */
//     for (i = 0; i < len / 3; i++) {
//         if (0 == (i % 2)) {
//             buf[i] = buf[i*3+2];
//         } else {
//             buf[i] = buf[i*3];
//         }
//     }
}
