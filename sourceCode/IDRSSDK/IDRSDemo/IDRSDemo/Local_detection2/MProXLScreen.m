//
//  MProXLScreen.m
//  IDRSDemo
//
//  Created by 崔海斌 on 2021/7/2.
//  Copyright © 2021 cuixling. All rights reserved.
//
#if defined(__arm64__)
#import "MProXLScreen.h"

@implementation MProXLScreen

//iphone xs max
+ (CGSize)sizeFor65Inch{
    return CGSizeMake(414,896);
}

//iphone xr
+ (CGSize)sizeFor61Inch{
    return CGSizeMake(414,896);
}

// iphonex
+ (CGSize)sizeFor58Inch{
    return CGSizeMake(375,812);
}
//plus
//4 /5

@end
#endif
