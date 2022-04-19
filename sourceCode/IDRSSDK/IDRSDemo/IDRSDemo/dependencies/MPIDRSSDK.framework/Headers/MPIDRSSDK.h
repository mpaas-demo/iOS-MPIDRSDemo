//
//  MPIDRSSDK.h
//  MPIDRSSDK
//
//  Created by shaochangying.scy on 2022/2/11.
//  Copyright © 2022 Alipay. All rights reserved.
//

#if __has_include(<ARTVC/ARTVC.h>)
#define BUILD_FOR_REMOTERECORD
#endif
#import <UIkit/UIkit.h>
#import <AVFoundation/AVFoundation.h>
#import <MPIDRSSDK/IDRSUploadManager.h>

/**
   人脸检测参数类型
 */
typedef NS_ENUM (int, IDRSFaceDetectInputType) {
    IDRSFaceDetectInputTypeImage, // UIImage
    IDRSFaceDetectInputTypeChar, // char *, should appoint {tb_pixel_format, width, height}
    IDRSFaceDetectInputTypePixelBuffer, // CVPixelBufferRef
};

///*************************** 人脸检测阈值调整函数 *********************************
/// @brief face param 人脸参数类型，目前共有12个参数阈值
typedef enum {
    IDRS_FACE_PARAM_DETECT_INTERVAL = 1, /// 人脸检测的帧率（默认值30，即每隔30帧检测一次）
    IDRS_FACE_PARAM_SMOOTH_THRESHOLD = 2, /// 人脸关键点平滑系数（默认值0.25）.
    IDRS_FACE_PARAM_POSE_SMOOTH_THRESHOLD = 4, /// 姿态平衡系数(0,1], 越大平滑成都越大
    IDRS_FACE_PARAM_DETECT_THRESHOLD = 5, /// 人脸检测阈值(0,1), 阈值越大，误检越少，但漏检测会增加, default 0.95 for faster rcnn; default 0.3 for SSD
    // 脸部动作
    IDRS_FACE_ACTION_EYE_BLINK = 6, ///< 眨眼
    IDRS_FACE_ACTION_MOUTH_AH = 7, ///< 嘴巴大张
    IDRS_FACE_ACTION_HEAD_YAW = 8, ///< 摇头
    IDRS_FACE_ACTION_HEAD_PITCH = 9, ///< 点头
    IDRS_FACE_ACTION_BROW_JUMP = 10, ///< 挑眉

    //
    IDRS_FACE_PARAM_ALIGNMENT_INTERVAL = 11, /// 人脸检测对齐间隔，默认1，一般不要超过5
    IDRS_FACE_PARAM_MAX_FACE_SUPPORT = 12, /// 最多支持检出的人脸个数，最大设为32, 主要针对faster rcnn
    IDRS_FACE_PARAM_DETECT_IMG_SIZE = 13, /// 人脸检测输入的图像大小，default： 320 for faster rcnn, recommend set 320 for tiny face detecton. recomand value(tiny->large): 320, 480, 640, 720, 880, 960, 1280
} idrs_face_param_type;

/**
   身份证检测参数类型
 */
typedef NS_ENUM (int, IDRSIDCardInputType) {
    IDRSIDCardInputTypePixelBuffer, // CVPixelBufferRef
    IDRSIDCardInputTypeRGBData, // char *, RGB数据
    IDRSIDCardInputTypeImage, // Image，图片
};

/**
   手势检测参数类型
 */
typedef NS_ENUM (int, IDRSHandInputType) {
    IDRSHandInputTypeBGRA, // BGRA类型数据
    IDRSHandInputTypeRGBA, // RGBA类型数据
};

/**
 *传入音视频流的类型
 */
typedef NS_ENUM (NSInteger,BufferType){
    CAMERA_VIDEO, // 相机视频流
    CAMERA_AUDIO, // 相机音频流
    RP_Video, // 录屏视频流
    RP_Audio, // 录屏音频流
    RP_AudioMic, // 录屏麦克风流
};

// TTS语音合成事件
typedef enum : NSUInteger {
    ISDR_TTS_EVENT_START = 0,
    ISDR_TTS_EVENT_END = 1,
    ISDR_TTS_EVENT_CANCEL = 2,
    ISDR_TTS_EVENT_PAUSE = 3,
    ISDR_TTS_EVENT_RESUME = 4,
    ISDR_TTS_EVENT_ERROR = 5,
    ISDR_TTS_EVENT_CACEH_START = 6,
    ISDR_TTS_EVENT_CACEH_END = 7,
    ISDR_TTS_EVENT_CACEH_CANCEL = 8,
    ISDR_TTS_EVENT_CACEH_DELETE = 9,
    ISDR_TTS_EVENT_CACEH_ERROR = 10,
    ISDR_TTS_EVENT_FONT_EVENT_START = 11,
    ISDR_TTS_EVENT_FONT_DOWNLOAD = 12,
    ISDR_TTS_EVENT_FONT_END = 13,
    ISDR_TTS_EVENT_FONT_PAUSE = 14,
    ISDR_TTS_EVENT_FONT_RESUME = 15,
    ISDR_TTS_EVENT_FONT_CANCEL = 16,
    ISDR_TTS_EVENT_FONT_ERROR = 17
} ISDRTtsEvent;

// 静态手势检测结果
enum StaticActionType {
    /// 单个手势
    IDRS_HAND_UNKNOWN =              0,      ///< 未知手势
    IDRS_HAND_BLUR =                 1,      ///< 模糊手势
    IDRS_HAND_OK =                   2,      ///< OK手势
    IDRS_HAND_PALM =                 3,      ///< 数字5/手掌手势
    IDRS_HAND_FINGER =               4,      ///< 数字1/食指手势
    IDRS_HAND_NUM8 =                 5,      ///< 数字8/手枪手势
    IDRS_HAND_HEART =                6,      ///< 单手比心手势
    IDRS_HAND_FIST =                 7,      ///< 拳头手势
    IDRS_HAND_HOLDUP =               8,      ///< 托举手势
    IDRS_HAND_CONGRATULATE =         9,      ///< 抱拳作揖/拜托手势
    IDRS_HAND_YEAH =                 10,     ///< 数字2/Yeah/剪刀手手势
    IDRS_HAND_LOVE =                 11,     ///< 双手爱心手势
    IDRS_HAND_GOOD =                 12,     ///< 点赞/拇指向上手势
    IDRS_HAND_ROCK =                 13,     ///< 摇滚手势
    IDRS_HAND_NUM3 =                 14,     ///< 数字3手势
    IDRS_HAND_NUM4 =                 15,     ///< 数字4手势
    IDRS_HAND_NUM6 =                 16,     ///< 数字6手势
    IDRS_HAND_NUM7 =                 17,     ///< 数字7手势
    IDRS_HAND_NUM9 =                 18,     ///< 数字9手势
    IDRS_HAND_GREETING =             19,     ///< 拜年/恭贺手势
    IDRS_HAND_PRAY =                 20,     ///< 祈祷手势
    IDRS_HAND_THUMBS_DOWN =          21,     ///< 拇指向下手势
    IDRS_HAND_THUMBS_LEFT =          22,     ///< 拇指向左手势
    IDRS_HAND_THUMBS_RIGHT =         23,     ///< 拇指向右手势
    /// 组合手势
    IDRS_HAND_HELLO =                24,     ///< 双手Hello手势
    /// 人脸手势
    IDRS_HAND_SILENCE =              25,     ///< 安静手势
};

NS_ASSUME_NONNULL_BEGIN

/**
   人脸检测结果对象
 */
@interface FaceDetectionOutput : NSObject

@property (nonatomic, assign) CGRect rect;                  // 面部表情区域
@property (nonatomic, assign) NSInteger faceId;             // faceID: 每个检测到的人脸拥有唯一的faceID.人脸跟踪丢失以后重新被检测到,会有一个新的faceID
@property (nonatomic, assign) CGPoint *keyPoints;           // 人脸106关键点的数组
@property (nonatomic, assign) CGFloat score;                // 人脸置信度
// attribute
@property (nonatomic, strong) NSDictionary *attributes;     // 人脸属性, {@"categoryvalue":{@"label":label, @"score":score}}
@property (nonatomic, strong) NSArray<NSNumber*> *feature;
@property (nonatomic, assign) int livenessType;             // 0是真人，1是打印/照片翻拍，2是视频翻拍
@property (nonatomic, assign) float livenessScore;
@property (nonatomic, copy) NSString *label;                // 人脸label
@property (nonatomic, assign) unsigned int faceAction;      // 人脸动作，参见MobileDLFace.h "检测结果 detect_config 配置选项"
@property (nonatomic, assign) CGFloat pitch;                // 俯仰角,真实度量的上负下正

@end

/**
   手势检测结果对象
 */
@interface HandDetectionOutput : NSObject

@property (nonatomic, assign) CGRect rect;// 手区域
@property (nonatomic, assign) CGRect face_rect;  // 主体人脸区域
@property (nonatomic, assign) CGPoint *body_key_points;   ///< 手属于的人体关键点
@property (nonatomic, assign) CGFloat *body_key_points_score; ///< 手属于的人体关键点的置信度[0,1]
@property (nonatomic, assign) int left_or_right;  // 左手还是右手(左:0/右:1)
@property (nonatomic, assign) int handId;// handID: 每个检测到的手拥有唯一的handID.手跟踪丢失以后重新被检测到,会有一个新的handID
@property (nonatomic, assign) Boolean phone_touched;// 是否手持手机
@property (nonatomic, assign) CGFloat phone_touched_score;// 手持手机置信度
@property (nonatomic, assign) int hand_phone_action; // 0是未检测出，1是签字，2是翻页

@property (nonatomic, assign) int hand_action_type; // 0是静态手势，1是手机手势
@property (nonatomic, assign) int hand_static_action; // 静态手势类型，结果是StaticActionType
@property (nonatomic, assign) float hand_static_action_score; // 静态手势分数

@end

/**
 * 身份证检测结果对象
 */
@interface IDCardDetectionOutput : NSObject
@property (nonatomic, copy) NSString *name; // 姓名
@property (nonatomic, copy) NSString *sex; // 性别
@property (nonatomic, copy) NSString *nationality; // 民族
@property (nonatomic, copy) NSString *birth; // 出生
@property (nonatomic, copy) NSString *address; // 住址
@property (nonatomic, copy) NSString *num; // 身份证号
@property (nonatomic, copy) NSString *issue; //身份证背面签发机关
@property (nonatomic, copy) NSString *startDate; //身份证背面有效期开始时间
@property (nonatomic, copy) NSString *endDate; //身份证背面有效期结束时间
@end

#define IDRSFaceDetectParam(param, pDataType, pAngle) \
    IDRSFaceDetectParam *param = [IDRSFaceDetectParam new]; \
    param.dataType = pDataType; \
    param.angle = pAngle;
@interface IDRSFaceDetectParam : NSObject
@property (nonatomic, assign) IDRSFaceDetectInputType dataType;
@property (nonatomic, assign) float inputAngle;// 角度
@property (nonatomic, assign) float outputAngle;
@property (nonatomic, assign) float output_flip_axis; //flip x/y 0(no flip)/1(flip X axis)/2(flip Y axis)
@property (nonatomic) CVPixelBufferRef buffer;
@property (nonatomic, assign) int format; // 0: TB_PIXEL_FORMAT_YUV_NV12; 1: TB_PIXEL_FORMAT_RGBA8888; 2: TB_PIXEL_FORMAT_BGRA8888
#if TARGET_OS_IPHONE
@property (nonatomic, strong) UIImage *image;
#endif
@property (nonatomic) unsigned char* data;
@property (nonatomic, assign) float width;
@property (nonatomic, assign) float height;
@property (nonatomic, assign) BOOL supportFaceLiveness;//活体
@property (nonatomic, assign) BOOL supportFaceRecognition;//特征值
@property (nonatomic, assign) int faceNetType; //0: imageFaceNet; 1: videoFaceNet; 2: remoteVideoFaceNet //如果设置上述两个参数、必须设置此参数
@end

/*
 * 身份证检测参数
 */
@interface IDRSIDCardDetectParam : NSObject
@property (nonatomic, assign) IDRSIDCardInputType dataType; // 输入数据类型
@property (nonatomic) CVPixelBufferRef buffer; //视频PixelBufferRef
@property (nonatomic, strong) UIImage *image; //图片数据
@property (nonatomic) unsigned char* baseBuffer; //视频RGB数据。baseBuffer、uvBuffer、width、height要同时提供
@property (nonatomic) unsigned char* uvBuffer;
@property (nonatomic, assign) float width;
@property (nonatomic, assign) float height;
@end

/// 签名可信度检测
@interface IDRSSignConfidenceCheck : NSObject

@property (nonatomic, copy) NSString *label;//
@property (nonatomic, assign) float confidence;

@end
/*
 * 手势检测参数
 */
@interface IDRSHandDetectParam : NSObject
@property (nonatomic, assign) IDRSHandInputType dataType; // 输入数据类型
@property (nonatomic) CVImageBufferRef buffer;
@property (nonatomic, assign) float outAngle;
@end

/*
   手势检测配置参数设置。可选配置，可以不设置，全部使用默认值
 */
@interface IDRSHandDetectionConfig : NSObject
@property (nonatomic, assign) Boolean isFaceDetect;  // 是否开启动作主体识别
@property (nonatomic, assign) NSInteger imgSize;  // 手部检测输入的图像大小, default: 480, recommend set 480 for tiny hand detecton. recomand value(tiny->large): 320, 480, 640, 720, 880, 960, 1280
@property (nonatomic, assign) float classifyThreshold;  /// 手势识别阈值[0,1], 阈值越大, 误识别越少, 但漏识别会增加, default 0.90
@property (nonatomic, assign) float phoneActionIOU; /// 手持手机IOU阈值, 范围[0,1], 参数值越大, 手持手机动作需要的IOU越大, default 0.05
@property (nonatomic, assign) float phoneActionTime; /// 手持手机时间阈值, 范围[0,1], 参数值越大, 手持手机动作需要的时间越长, default 0.5
@property (nonatomic, assign) float phoneActionSign; /// 手持手机签字阈值, 范围[0,1], 参数值越大, 手持手机签字需要划动的范围越大, default 0.05
@property (nonatomic, assign) float phoneActionScroll; /// 手持手机翻页阈值, 范围[0,1], 参数值越大, 手持手机翻页需要划动的范围越大, default 0.15
@property (nonatomic, assign) float interlacingBody;//隔帧检测---火柴人，范围[0，10]，正整数
@end

@protocol IDRSNUITTSDelegate <NSObject>

/// player播放完成
- (void)onPlayerDidFinish;

/// tts合成状态
/// @param event 状态
/// @param taskid 任务id
/// @param code code
- (void)onNuiTtsEventCallback:(ISDRTtsEvent)event taskId:(NSString *)taskid code:(int)code;

/// tts合成数据
/// @param info 文本信息
/// @param info_len 下角标（不是很准、推荐使用info.length）
/// @param buffer 音频数据流
/// @param len 数据流长度
/// @param task_id 任务id
- (void)onNuiTtsUserdataCallback:(NSString *)info infoLen:(int)info_len buffer:(char*)buffer len:(int)len taskId:(NSString *)task_id;

/// nui识别结果
/// @param result 激活词识别的结果
- (void)onNuiKwsResultCallback:(NSString *)result;

@end

typedef void (^RecordCallBackBlock) (NSString *text); // 录像结果
typedef void (^FaceDetectionCallBackBlock) (NSArray<FaceDetectionOutput*> *faces); // 人照对比结果

@interface MPIDRSSDK : NSObject

@property (nonatomic, weak) id<IDRSNUITTSDelegate> nui_tts_delegate;

@property (nonatomic, strong) RecordCallBackBlock onRecordCallback; // 结束录像回调

/// 统计标识
@property (nonatomic, copy, readonly) NSString *feedId;

#pragma mark -- detection SDK init
/// 初始化
/// @param recordType 录制类型
/// @param userId userId
/// @param appId appid
/// @param packageName packageName
/// @param ak ak
/// @param sk sk
/// @param success sdk返回
/// @param failure 失败返回
+ (void)initWithRecordType:(IDRSRecordType)recordType
        userId:(NSString *)userId
        appId:(NSString *)appId
        packageName:(NSString *)packageName
        AK:(NSString*)ak
        SK:(NSString*)sk
        success:(void (^)(id responseObject))success
                         failure:(void (^)(NSError *error))failure;

- (instancetype)init NS_UNAVAILABLE;

#pragma mark -- AI And Setting
/// 设置人脸检测的参数
/// @param value  参数的值,详情见idrs_face_param_type枚举
/// @param key idrs_face_param_type枚举
- (void)setFaceDetectParameter:(float)value forKey:(idrs_face_param_type)key;

/// 检测人脸特征值
/// @param faceDetectParam IDRSFaceDetectParam
- (NSArray<FaceDetectionOutput *> *)detectFace:(nonnull IDRSFaceDetectParam *)faceDetectParam;

// 人照比对
/// @param faceFea1 脸1的特征值
/// @param faceFea2 脸2的特征值
- (float)faceRecognitionSimilarity:(nonnull NSArray<NSNumber*>*)faceFea1
        feature2:(nonnull NSArray<NSNumber*>*)faceFea2;

/// 用图片引擎做人脸追踪
/// @param faceDetectParam IDRSFaceDetectParam
/// @param block 结果返回
- (void)faceTrackFromImage:(nonnull IDRSFaceDetectParam *)faceDetectParam
        faceDetectionCallback:(void (^)(NSError *error, NSArray<FaceDetectionOutput*> *faces))block;// 非主线程回调;

/// 用视频引擎中人脸追踪
/// @param faceDetectParam IDRSFaceDetectParam
/// @param faceDetectionCallbackBlock 结果返回
- (void)faceTrackFromVideo:(nonnull IDRSFaceDetectParam *)faceDetectParam
        faceDetectionCallback:(void (^)(NSError *error, NSArray<FaceDetectionOutput*> *faces))faceDetectionCallbackBlock;

/// 用视频引擎中RTC_远端窗口--人脸追踪
/// @param faceDetectParam IDRSFaceDetectParam
/// @param faceDetectionCallbackBlock 结果返回
- (void)faceTrackFromRemoteVideo:(nonnull IDRSFaceDetectParam *)faceDetectParam
        faceDetectionCallback:(void (^)(NSError *error, NSArray<FaceDetectionOutput*> *faces))faceDetectionCallbackBlock;

/// 设置手势检测参数。需要在调用detectHandGesture之前调用，才能起作用
/// @param handDetectConfig IDRSHandDetectionConfig
-(void)setHandDetectConfig:(nonnull IDRSHandDetectionConfig *)handDetectConfig;

/// 检测动态手势，手持手机签字
/// @param handParam IDRSHandDetectParam
- (NSArray<HandDetectionOutput *> *)detectHandGesture:(nonnull IDRSHandDetectParam *)handParam;

/// 检测静态手势
/// @param handParam IDRSHandDetectParam
- (NSArray<HandDetectionOutput *> *)detectHandStaticGesture:(nonnull IDRSHandDetectParam *)handParam;

/// 签名类型检测
/// @param cameraFrame 相机流
/// @param roikey ROI数组
-(NSArray <IDRSSignConfidenceCheck *>*)checkSignClassifyWithCameraBuffer:(CVPixelBufferRef)cameraFrame AndROI:(NSArray<NSNumber*>*)roikey;

/// 签名类型检测
/// @param image 所检测的image
/// @param roikey ROI数组
-(NSArray <IDRSSignConfidenceCheck *>*)checkSignClassifyWithImage:(UIImage*)image AndROI:(NSArray<NSNumber*>*)roikey;

// isFrontCamera： 是否是前置摄像头；isDetectFrontIDCard： 是否开启身份证背面识别
/// 检测身份证OCR
/// @param idCardParam IDRSIDCardDetectParam
/// @param roiKey ROI数组
/// @param rotate 角度
/// @param frontCamera 是否为前置摄像头：YES：前置，NO：后置
/// @param frontIDCard 是否检测身份证带人面：YES：带人面，NO：国徽面
- (IDCardDetectionOutput *)detectIDCard:(nonnull IDRSIDCardDetectParam *)idCardParam
                                 roiKey:(nonnull NSArray<NSNumber*>*)roiKey
                                 rotate:(NSNumber*)rotate
                          isFrontCamera:(BOOL)frontCamera
                    isDetectFrontIDCard:(BOOL)frontIDCard;

/// 开启激活词检测
- (void)startDialog;

/// 结束激活词检测
- (void)stopDialog;

/**
   激活词外部输入数据
   @param voiceFrame 音频数据(需要：pcm、单声道、16k采样率)
 */
- (void)feedAudioFrame:(NSData*)voiceFrame;

/// 开始TTS合成
/// @param text 需要合成语音的文本，如：@“这是测试文本”
- (void)startTTSWithText:(NSString *)text;

/// 结束TTS合成
- (void)stopTTS;

/// 暂停当前播放（与resume相反）
- (void)pauseTTS;

/// 重启当前播放（与pause相反）
- (void)resumeTTS;

/// 设置参数，设置成功后下次合成将采用新的参数
/// @param param param:  extend_font_name:语音模型  value: (xiaoyun/xiaogang)
/// param:  speed_level:语音速度 value：(0-2],默认1.0
/// param:  volume: 音量 value: [0,2],推荐1.5以下
/// param:  pitch_level：音调，value：[-500,500]
- (void)setTTSParam:(NSString *)param
        value:(NSString *)value;

/// 获取TTS参数
/// @param param font_name、mode_type、speed_level、volume
-(NSString *)getTTSParam:(NSString *)param;

#pragma mark -- record
/// 手机摄像头捕捉音视频，为录像提供数据
/// @param sampleBuffer CMSampleBufferRef
/// @param dataType BufferType
- (void)getAudioVideoForRecord:(nonnull CMSampleBufferRef)sampleBuffer
        dataType:(BufferType)dataType;
/// 开始录像
/// @param fileName 文件名
/// @param filePath 文件路径
- (void)startRecordWithFileName:(NSString*)fileName andFilePath:(NSString*)filePath;

/// 设置是否保存视频到相册
/// @param isSaveToPhoto 默认为true：保存
- (void)setSaveToPhotoWithTrue:(BOOL)isSaveToPhoto;

/// 结束录像
- (void)stopRecord;

/// 获取本地录制视频的地址（本地双录中使用）
-(NSString*)getLocationVideoPath;

#pragma mark -- meta Write
/// 初始化meta文件及result文件计时器
-(void)startInitTime;

/// 保存Meta文件
/// @param fileName 文件名，需带后缀：xxx.meta
/// @param filePath 文件路径，如果为nil或@""，则存在默认路径
-(NSString*)saveMetaWithfileName:(NSString*)fileName andfilePath:(NSString*)filePath;

/// @param sequence 可理解为：章节
- (void)startSegment:(NSString *)sequence;

/// @param idCard 给某个章节添加身份证号
- (void)addSegment:(NSString *)sequence andIDCard:(NSString*)idCard;

- (void)endSegment:(NSString *)sequence;

/// @param actionName 开始某个章节的actionName检测项
- (void)startActionInSegment:(NSString *)sequence
        actionName:(NSString *)actionName;

- (void)endActionInSegment:(NSString *)sequence
        actionName:(NSString *)actionName;

/// @param word 识别激活词
- (void)startAddWord:(NSString *)word;

- (void)endAddWord:(NSString *)word;

/// @param label 人物名称
/// @param imageBase64 人脸照片的base64
- (void)addFace:(NSString *)label
        image:(NSString *)imageBase64;


/// @param holderIdCardNumber 身份证号
/// @param title 文档标题
- (void)addPolicy:(NSString *)holderIdCardNumber
        title:(NSString *)title;

/// @param detection 多端检测统一码
-(void)addDetection:(NSString*)detection;

#pragma mark -- result Write

/// 添加人物信息
/// @param label 人名
/// @param imageBase64 人脸照片
- (void)resultAddFace:(NSString *)label
          image:(NSString *)imageBase64;

/// 设置章节
/// @param sequence 第几章
/// @param title 标题名称
- (void)resultStartSegment:(NSString *)sequence withTitle:(NSString *)title;

/// 添加自定义章节结果
/// @param sequence 第几章
/// @param result 自定义结果
- (void)resultAddSegment:(NSString *)sequence withCustomResult:(NSString *)result;

/// 结束章节
/// @param sequence 第几章
- (void)resultEndSegment:(NSString *)sequence;

/// 开始某章某节的检测项
/// @param sequence 第几章
/// @param action 第几小节（用于区分同一章节多个相同的检测）
/// @param actionName 检测项名称
- (void)resultStartActionInSegment:(NSString *)sequence
                      action:(NSString *)action
                        actionName:(NSString *)actionName;

- (void)resultEndActionInSegment:(NSString *)sequence
                          action:(NSString *)action;

/// 给某一章某一节添加结果
/// @param sequence 第几章
/// @param action 第几小节
/// @param result 检测结果
- (void)resultAddActionInSegment:(NSString *)sequence
                action:(NSString *)action
                          result:(NSString *)result;

/// 给某一章某一节添加照片（base64）
/// @param sequence 第几章
/// @param action 第几小节
/// @param image 图片（暂时只获取身份证图片）
- (void)resultAddActionInSegment:(NSString *)sequence
                    action:(NSString *)action
                           image:(NSString *)image;

/// @param md5String 录制视频的md5加密
- (void)resultAddVideoMD5:(NSString *)md5String;

/// @param detection 统一标识码
- (void)resultAddDetection:(NSString *)detection;

/// 获取resultJson
- (NSString *)resultGetMetaJson;

/// 保存result文件
/// @param fileName 文件名，需带后缀：xxx.result.meta
/// @param filePath 文件路径，如果为nil或@""，则存在默认路径
- (NSString *)resultSaveToFile:(NSString *)fileName andPath:(NSString*)filePath;

#pragma mark -- tools
/// 获取SDK版本号
+ (NSString*)getVersion;

/// 将相机中获取的sampleBuffer保存到相册
/// @param sampleBuffer CMSampleBufferRef
- (void)saveSampleBufferFromCamera: (CMSampleBufferRef)sampleBuffer;

/// 将rtc视频流转成图片
/// @param imageBuffer CVPixelBufferRef、CVPixelBufferRef
- (UIImage *) getImageFromRPVideo: (CVImageBufferRef)imageBuffer;

#pragma mark -- relesae
/// 释放资源
- (void)releaseResources;

#ifdef BUILD_FOR_REMOTERECORD

#pragma mark -- RTC

/// 初始化RTC 实例
/// @param userId userId
/// @param appId appId
/// @param success sdk返回
/// @param failure 失败返回
+ (void)initRTCWithUserId:(NSString *)userId
                    appId:(NSString *)appId
                  success:(void (^)(id responseObject))success
                  failure:(void (^)(NSError *error))failure;
/// 创建RTC Room
+ (void)createRoom;

/// 加入RTC Room
+ (void)joinRoom:(NSString *)roomId token:(NSString *)token;

/// 开启远程录制
/// @param roomId 房间ID
/// @param waterMarkId 水印ID
/// @param waterMarkHandler 回调
+ (void)openRemoteRecordWithRoomId:(NSString *)roomId
                       waterMarkId:(NSString *)waterMarkId
                  waterMarkHandler:(void (^)(NSError * _Nonnull error))waterMarkHandler;

/// 匹配流tag前缀开启远程录制
/// @param roomId 房间ID
/// @param waterMarkId 水印ID
/// @param recordTagPrefix tag前缀
/// @param dictionary dictionary :  key : LOCATION value:要传的位置信息
/// @param waterMarkHandler 回调
+ (void)openRemoteRecordWithRoomId:(NSString *)roomId
                       waterMarkId:(nullable NSString *)waterMarkId
                   recordTagPrefix:(nullable NSString *)recordTagPrefix
                           extInfo:(NSDictionary*)dictionary
                  waterMarkHandler:(void (^)(NSError * _Nonnull error))waterMarkHandler;

/// 关闭远程录制
+ (void)stopRemoteRecord:(NSString *)recordId;

/// @param roomId roomId
/// @param recordId recordId
/// @param mediaType 文件内容类型：0：音视频（默认），1：纯音频，2：纯视频
//+ (void)getRemoteRecordResult:(NSString *)roomId
//                     recordId:(NSString *)recordId
//                    mediaType:(NSUInteger)mediaType;
#endif

@end
NS_ASSUME_NONNULL_END
