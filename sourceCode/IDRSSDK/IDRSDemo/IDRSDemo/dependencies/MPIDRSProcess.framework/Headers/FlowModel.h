//
//  FlowModel.h
//  IDRSSDK
//
//  Created by 崔海斌 on 2020/11/5.
//  Copyright © 2020 cuixling. All rights reserved.
//
#ifdef __arm64__
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <MPIDRSSDK/MPIDRSSDK.h>

@interface FlowConfig : NSObject

+ (instancetype)sharedInstance;

- (void)destoryShardInstance;

//default: @[@(0.2),@(0.2),@(0.6),@(0.6)]
@property (nonatomic, copy) NSArray *ocrRoi;
//default: @(90)
@property (nonatomic, copy) NSNumber *ocrRotate;
//default: true
@property (nonatomic, assign) BOOL ocrIsFront;

//default: 0
@property (nonatomic, assign) int inputAngle;
//default: 0
@property (nonatomic, assign) int outputAngle;

//default: @[@(0.2),@(0.2),@(0.6),@(0.6)]
@property (nonatomic, copy) NSArray *signRoi;

//default: 0
@property (nonatomic, assign) int handOutAngle;

@end
#pragma mark -- 初始化相关
enum FlowRecorderPresetSize {
    FlowRecorderPresetSize360P, // 手机能够支持的最接近360 x 640的尺寸，指得是短边
    FlowRecorderPresetSize540P, // 手机能够支持的最接近540 x 960的尺寸，指得是短边
    FlowRecorderPresetSize720P, // 手机能够支持的最接近720 x 1280的尺寸，指得是短边
    FlowRecorderPresetSize1080P // 手机能够支持的最接近1080 x 1920的尺寸，指得是短边
};
//初始化配置
@interface FlowCreateConfig : NSObject
//type: 是否下载流程json

@property (nonatomic, strong) NSString * ak;//AK
@property (nonatomic, strong) NSString * sk;//SK

@property (nonatomic, strong) NSString * appId;//APPID
@property (nonatomic, strong) NSString * packageName;//包名

@property (nonatomic, strong) NSString * processId;//流程ID
@property (nonatomic, strong) NSString * userId;//用户id

//如果想要设置录制相关内容、请传入以下两项
@property (nonatomic, assign) BOOL isHorizontal;//是否横屏录制，默认竖屏
@property (nonatomic, assign) enum FlowRecorderPresetSize presetSize;//默认360P

//以下参数可通过FlowConfig 随时更改
//如果需要使用签字类型检测，需传入---
@property (nonatomic, strong) NSArray * signroi;//识别手写体识别位置
//如果需要使用身份证检测，需传入
@property (nonatomic, strong) NSArray * ocrroi;//身份证识别位置
//如果需要使用身份证检测，需传入
@property (nonatomic, assign) int ocrRotate;//身份证检测角度
//如果需要使用身份证检测，需传入
@property (nonatomic, assign) BOOL isOcrFront;//检测身份证Yes:正面：NO:反面

@end

//结果使用
//检测类型
enum detectionType {
    face_track = 0,//人脸追踪;
    face_recognize,//人照对比;
    liveness_track,//活体检测;
    speech_word_detect,//激活词检测;
    id_card_recognize,//身份证检测
    sign_action_recognize,//手势动作检测;
    static_hand_recognize,//静态手势识别
    sign_classify_recognize,//签名类型检测
    other//其他
};
//检测项信息
@class phases;
@interface CheckResult : NSObject
@property(nonatomic,strong) phases* phase;
@property(nonatomic,strong) NSString *phaseId;
@property(nonatomic,strong) NSString *detectionId;
@property(nonatomic,assign) enum detectionType Type;
@property(nonatomic,strong) NSString* content;
@end
//成功返回Model
@interface SuccessModel : NSObject
@property(nonatomic,strong) CheckResult * checkResult;//检测项
@property(nonatomic,strong) FaceDetectionOutput * faceOutput;//人脸结果返回
@property(nonatomic,strong) NSString * sign_action_Result;//手势结果返回
@property(nonatomic,strong) NSString * static_hand_Result;//静态手势结果返回
@property(nonatomic,strong) IDCardDetectionOutput * ocrOutput;//身份证结果返回
@property(nonatomic,strong) NSString* speech_word_Result;//返回文本信息
@property(nonatomic,strong) NSString* other;
@property(nonatomic,assign) int sign_classify_Result;//是否为手写体,0:是，1:否
@end

//UI使用
@interface faceUIAndName : NSObject
@property (nonatomic,assign) CGRect rect;//人脸位置
@property (nonatomic,strong) NSString *name;//人物名称
@property (nonatomic,assign) int isLiveness;//是否为活体,0:不检测1:活体2:非活体

@property (nonatomic,assign) NSInteger faceId;//人脸编号
@property (nonatomic,assign) int livenessType;//类型 0真人，1翻拍
@property (nonatomic,assign) float livenessScore;//分数
@end

@interface handUIAndLeftorright : NSObject
@property (nonatomic,assign) CGRect rect;//手部位置
@property (nonatomic, assign) int left_or_right;  // 左手还是右手(左:0/右:1)
@end

@interface faceFeatureAndName : NSObject
@property (nonatomic,strong) NSArray<NSNumber*> *feature;
@property (nonatomic,strong) NSString *name;
@end

@interface aidetection : NSObject
@property (nonatomic,strong)NSString *aiId;
@property (nonatomic,assign)long duration;
@property (nonatomic,strong)NSString *role;
@property (nonatomic,assign)BOOL isRequired;
@end

@interface facedetection : NSObject
@property (nonatomic,strong)NSString *faceId;
@property (nonatomic,assign)long duration;
@property (nonatomic,strong)NSString *role;
@property (nonatomic,assign)BOOL isRequired;
@property (nonatomic,assign)BOOL isGlobal;
@end

@interface detections : NSObject
@property (nonatomic,strong)NSArray<aidetection*>* aidetections;
@property (nonatomic,strong)NSArray<facedetection*>* facedatections;
@end

@interface TTS : NSObject
@property (nonatomic,strong)NSString * ttsText;
@property (nonatomic,strong)NSString * speed;
@property (nonatomic,strong)NSString * fontName;
@end

@interface MP3 : NSObject
@property (nonatomic,strong)NSString * playFileName;
@property (nonatomic,strong)NSString * playFilePath;
@end

@interface Voice : NSObject
@property (nonatomic,strong)NSString * type;
@property (nonatomic,strong)TTS * tts;
@property (nonatomic,strong)MP3 * mp3;
@end

@interface phases : NSObject
@property (nonatomic,strong)NSString *phaseId;
@property (nonatomic,strong)NSString *type;
@property (nonatomic,strong)NSString *content;
@property (nonatomic,strong)Voice *voice;
@property (nonatomic,strong)detections *detection;
@end

typedef enum : NSUInteger {
    ERROR_TYPE_IDRS = 1,
    ERROR_TYPE_PHASE_NULL = 2,
    ERROR_TYPE_RECORD_ERROR = 3,
    ERROR_TYPE_PROCESS_CONTENT = 4,
    ERROR_TYPE_UPLOAD = 5,
    ERROR_TYPE_AUDIO_DOWNLOAD = 6,
} ERROR_TYPE;

//静态手势返回结果说明
//switch (type) {
//    case 0:
//        return @"未知手势";
//        break;
//    case 1:
//        return @"模糊手势";
//        break;
//    case 2:
//        return @"OK手势";
//        break;
//    case 3:
//        return @"数字5/手掌手势";
//        break;
//    case 4:
//        return @"数字1/食指手势";
//        break;
//    case 5:
//        return @"数字8/手枪手势";
//        break;
//    case 6:
//        return @"单手比心手势";
//        break;
//    case 7:
//        return @"拳头手势";
//        break;
//    case 8:
//        return @"托举手势";
//        break;
//    case 9:
//        return @"抱拳作揖/拜托手势";
//        break;
//    case 10:
//        return @"数字2/Yeah/剪刀手手势";
//        break;
//    case 11:
//        return @"双手爱心手势";
//        break;
//    case 12:
//        return @"点赞/拇指向上手势";
//        break;
//    case 13:
//        return @"摇滚手势";
//        break;
//    case 14:
//        return @"数字3手势";
//        break;
//    case 15:
//        return @"数字4手势";
//        break;
//    case 16:
//        return @"数字6手势";
//        break;
//    case 17:
//        return @"数字7手势";
//        break;
//    case 18:
//        return @"数字9手势";
//        break;
//    case 19:
//        return @"拜年/恭贺手势";
//        break;
//    case 20:
//        return @"祈祷手势";
//        break;
//    case 21:
//        return @"拇指向下手势";
//        break;
//    case 22:
//        return @"拇指向左手势";
//        break;
//    case 23:
//        return @"拇指向右手势";
//        break;
//    case 24:
//        return @"双手Hello手势";
//        break;
//    case 25:
//        return @"安静手势";
//        break;
//
//    default:
//        break;
//}
#endif
