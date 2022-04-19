//
//  DemoSetting.m
//  DemoSetting
//
//  Created by shaochangying.scy on 2021/11/23.
//  Copyright © 2021 Alipay. All rights reserved.
//
#define DemoSettingRtcUrlKey @"DemoSettingRtcUrlKey"
#define DemoSettingServerUrlKey @"DemoSettingServerUrlKey"
#define DemoSettingProcessIdKey @"DemoSettingProcessIdKey"
#define DemoSettingUserIdKey @"DemoSettingUserIdKey"
#define DemoSettingWatermarkIdKey @"DemoSettingWatermarkIdKey"
#define DemoSettingPhotosKey @"DemoSettingPhotosKey"
#define DemoSettingNamesKey @"DemoSettingNamesKey"
#define DemoSettingAppIdKey @"DemoSettingAppIdKey"
#define DemoSettingPackageNameKey @"DemoSettingPackageNameKey"
#define DemoSettingAKKey @"DemoSettingAKKey"
#define DemoSettingSKKey @"DemoSettingSKKey"

#import "DemoSetting.h"

@implementation DemoSetting

static DemoSetting *settingModel = nil;
+ (instancetype)sharedInstance {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        settingModel = [[DemoSetting alloc] init];
    });
    return settingModel;
}


- (NSString *)processId
{
    if (!_processId) {
        NSString *processId = [[NSUserDefaults standardUserDefaults] objectForKey:DemoSettingProcessIdKey];
        if (processId && processId.length > 0) {
            _processId = processId;
        }else {
            _processId = @"";
        }
    }
    return _processId;
}

- (NSString *)userId
{
    if (!_userId) {
        NSString *userId = [[NSUserDefaults standardUserDefaults] objectForKey:DemoSettingUserIdKey];
        if (userId && userId.length > 0) {
            _userId = userId;
        }else {
            _userId = [NSString stringWithFormat:@"%d",arc4random()%10000 + 1000];
        }
    }
    return _userId;
}

- (NSString *)watermarkId
{
    if (!_watermarkId) {
        NSString *watermarkId = [[NSUserDefaults standardUserDefaults] objectForKey:DemoSettingWatermarkIdKey];
        if (watermarkId && watermarkId.length > 0) {
            _watermarkId = watermarkId;
        }else {
            _watermarkId = @"";
        }
    }
    return _watermarkId;
}

- (NSMutableArray *)photos
{
    if (!_photos) {
        NSArray *photos = [[NSUserDefaults standardUserDefaults] objectForKey:DemoSettingPhotosKey];
        if (photos && photos.count > 0) {
            _photos = [NSMutableArray arrayWithArray:photos];
        }else {
            _photos = [NSMutableArray array];;
        }
    }
    return _photos;
}

- (NSMutableArray *)names
{
    if (!_names) {
        NSArray *names = [[NSUserDefaults standardUserDefaults] objectForKey:DemoSettingNamesKey];
        if (names && names.count > 0) {
            _names = [NSMutableArray arrayWithArray:names];
        }else {
            _names = [NSMutableArray array];;
        }
    }
    return _names;
}

- (NSString *)appId
{
    if (!_appId) {
        NSString *appId = [[NSUserDefaults standardUserDefaults] objectForKey:DemoSettingAppIdKey];
        if (appId && appId.length > 0) {
            _appId = appId;
        }else {
            _appId = @"你的appId";
        }
    }
    return _appId;
}

- (NSString *)packageName
{
    if (!_packageName) {
        NSString *packageName = [[NSUserDefaults standardUserDefaults] objectForKey:DemoSettingPackageNameKey];
        if (packageName && packageName.length > 0) {
            _packageName = packageName;
        }else{
            _packageName = @"你的包名";
        }
    }
    return _packageName;
}
- (NSString *)ak
{
    if (!_ak) {
        NSString *ak = [[NSUserDefaults standardUserDefaults] objectForKey:DemoSettingAKKey];
        if (ak && ak.length > 0) {
            _ak = ak;
        }else{
            _ak = @"你的ak";
        }
    }
    return _ak;
}

- (NSString *)sk
{
    if (!_sk) {
        NSString *sk = [[NSUserDefaults standardUserDefaults] objectForKey:DemoSettingSKKey];
        if (sk && sk.length > 0) {
            _sk = sk;
        }else{
            _sk = @"你的sk";
        }
    }
    return _sk;
}

- (void)saveData {
//    [[NSUserDefaults standardUserDefaults] setObject:self.rtcUrl forKey:DemoSettingRtcUrlKey];
//    [[NSUserDefaults standardUserDefaults] setObject:self.serverUrl forKey:DemoSettingServerUrlKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.processId forKey:DemoSettingProcessIdKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.userId forKey:DemoSettingUserIdKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.watermarkId forKey:DemoSettingWatermarkIdKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.photos forKey:DemoSettingPhotosKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.names forKey:DemoSettingNamesKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.packageName forKey:DemoSettingPackageNameKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.appId forKey:DemoSettingAppIdKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.ak forKey:DemoSettingAKKey];
    [[NSUserDefaults standardUserDefaults] setObject:self.sk forKey:DemoSettingSKKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
}

@end

