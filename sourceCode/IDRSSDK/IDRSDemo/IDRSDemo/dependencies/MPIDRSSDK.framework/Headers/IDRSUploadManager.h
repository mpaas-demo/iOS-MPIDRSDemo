//
//  IDRSUploadManager.h
//  IDRSSDK
//
//  Created by 斌小狼 on 2022/1/13.
//  Copyright © 2022 cuixling. All rights reserved.
//

#import <Foundation/Foundation.h>

// 录制类型
typedef NS_ENUM (NSInteger,IDRSRecordType){
    IDRSRecordLocal, // 本地
    IDRSRecordRemote, // 远程
};

@interface IDRSUploadFile : NSObject

/**
 fileName说明：多个文件的名字是统一的、只是后缀不同、且后缀必须为以下实例中的样子。
 video文件命名为：123.mp3
 meta文件命名为：123.mp3.meta
 result文件命名为：123.mp3.result.meta
 */
@property (nonatomic, strong) NSString * _Nonnull fileName;

@property (nonatomic, strong) NSString * _Nonnull filePath;

@end

@interface IDRSUploadManagerParam : NSObject

@property (nonatomic, strong) NSArray <IDRSUploadFile*>* _Nullable files;

@property (nonatomic, strong) NSString * _Nullable appId;

@property (nonatomic, strong) NSString * _Nullable ak;

@property (nonatomic, strong) NSString * _Nullable sk;

@property (nonatomic, strong) NSString * _Nullable detectProcessId;

@property (nonatomic, strong) NSString * _Nullable roomId;
//NSDateFormatter:YYYY-MM-dd'T'HH:mm:ss'Z'
@property (nonatomic, strong) NSDate * _Nonnull recordAt;
//录制时长
@property (nonatomic, assign) long duration;

@property (nonatomic, assign) IDRSRecordType type;

@end

NS_ASSUME_NONNULL_BEGIN
@interface IDRSUploadManager : NSObject

+ (instancetype)sharedInstance;

+ (void)uploadFileWithParam:(IDRSUploadManagerParam*)uploadBody
                    success:(void (^)(id responseObject))success
                    failure:(void (^)(NSError *error, IDRSUploadManagerParam *upLoadParam))failure;

@end

NS_ASSUME_NONNULL_END
