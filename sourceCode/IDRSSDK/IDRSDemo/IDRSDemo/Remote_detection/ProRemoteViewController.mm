//
//  ProRemoteViewController.m
//  ProRemoteViewController
//
//  Created by shaochangying.scy on 2022/1/5.
//
#if defined(__arm64__)
#import "ProRemoteViewController.h"
#import "AppDelegate.h"
#import <ARTVC/ARTVC.h>
#import "ProRemoteCell.h"
#import "ARTVCRenderUnit.h"
#import "ARTVCRenderUnit.h"
#import "UIView+ARTVCToast.h"
#import <MPIDRSSDK/MPIDRSSDK.h>
#import "MPDrawView.h"
#import "MPButtonView.h"
#import "MPResample.hpp"//重采样
#import "DemoSetting.h"
#import <MPIDRSSDK/MPIDRSSDK.h>
#import <MPIDRSSDK/IDRSUploadManager.h>
#import <MPIDRSSDK/IDRSUtils.h>

#define AppId [DemoSetting sharedInstance].appId
#define PackageName [DemoSetting sharedInstance].packageName
#define Ak [DemoSetting sharedInstance].ak
#define Sk [DemoSetting sharedInstance].sk
#define WatermarkId [DemoSetting sharedInstance].watermarkId

@interface ProRemoteViewController ()<ARTVCEngineDelegate,UICollectionViewDataSource,UICollectionViewDelegate,MPButtonViewDelegate,IDRSNUITTSDelegate>

@property (nonatomic, strong) UILabel *roomInfoLabel;

@property (nonatomic, strong) ARTVCEngine *artvcEgnine;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *feedSource;

@property (nonatomic, strong) NSLock *viewLock;

@property (nonatomic, strong) UIView *contentView;

@property (nonatomic, strong) MPIDRSSDK * idrs;

@property (nonatomic, strong) MPDrawView *drawView;

@property (nonatomic, strong) MPButtonView *buttonView;

@property (nonatomic, strong) UILabel *resultLabel;

@property (nonatomic, strong) UIImageView *imageView;

/** 是否开启人脸检测*/
@property (nonatomic, assign) BOOL isFaceCheck;
/** 是否开启动态手势检测*/
@property (nonatomic, assign) BOOL isHandDet;
/** 是否开启静态手势检测*/
@property (nonatomic, assign) BOOL isStaticHandDet;
/** 是否开启身份证（头像面）检测*/
@property (nonatomic, assign) BOOL isOCR_Front;
/** 是否开启身份证（国徽面）检测*/
@property (nonatomic, assign) BOOL isOCR_Back;
/** 是否开启手写体检测*/
@property (nonatomic, assign) BOOL isWrite;
/** 是否开启关键词检测*/
@property (nonatomic, assign) BOOL isNui;
/** 是否开启远端关键词检测*/
@property (nonatomic, assign) BOOL isRemoteNui;
/** 是否对端检测*/
@property (nonatomic, assign) BOOL isOther;

@property (nonatomic, strong) NSString *recordId;
@property (nonatomic, strong) NSDate *startTime;
@property (nonatomic, assign) long duration;

@property(nonatomic,strong) ARTVCCustomVideoCapturer* customCapturer;

@property (nonatomic, strong) NSMutableData *customAudioData;

@property (nonatomic, assign) int customAudioDataIndex;

@property (strong, nonatomic) AVPlayer *player;//播放器对象
@end

@implementation ProRemoteViewController
{
    ARTVCFeed *_localFeed;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.allowRotation = YES;//(以上2行代码,可以理解为打开横屏开关)
    [self setNewOrientation:YES];//调用转屏代码
    
    self.isFaceCheck = true;
    self.viewLock = [[NSLock alloc] init];
    UIView *contentView = [[UIView alloc] init];
    contentView.frame = self.view.bounds;
    self.contentView = contentView;
    [self.view addSubview:self.contentView];
    [self.view addSubview:self.roomInfoLabel];
    
    self.feedSource = [NSMutableArray array];
    [self updateUI];
    [self.view addSubview:self.collectionView];
    
    [self initIDRSSDK];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self initRTCSDK];
    });
    NSURL *url = [[NSBundle mainBundle] URLForResource:@"yxqc.mp3" withExtension:nil];
    
    // 2.创建AVPlayerItem
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:url];
    
    // 3.创建AVPlayer
    self.player = [AVPlayer playerWithPlayerItem:item];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self Reinstatement];
    [_artvcEgnine stopCameraPreview];
    [_artvcEgnine leaveRoom];
    [_idrs releaseResources];
    _idrs = nil;
}

- (void)updateUI
{
    [self.view addSubview:({
        _drawView = [[MPDrawView alloc] init];
        _drawView.frame = CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width);
        //        _drawView.faceDetectView.isFront = true;
        _drawView.faceDetectView.presetSize = CGSizeMake(1280, 720);
        //        _drawView.handDetectView.isFront = true;
        _drawView.handDetectView.presetSize = CGSizeMake(1280, 720);
        _drawView.faceDetectView.isRTC = true;
        _drawView.handDetectView.isRTC = true;
        _drawView;
    })];
    NSArray *buttonTextArr ;
    if (!self.roomId) {
        buttonTextArr = @[@"切摄像头",@"动态手势",@"静态手势",@"身份证正面",@"身份证反面",@"手写体",@"激活词",@"TTS",@"TTS暂停",@"对端检测",@"录制"];
    }else{
        buttonTextArr = @[@"切摄像头"];
    }
    [self.view addSubview:({
        _buttonView = [[MPButtonView alloc] initWithFrame:CGRectMake(50, 100, self.view.frame.size.height/2 - 20, self.view.frame.size.width - 100) andNameArray:buttonTextArr];
        _buttonView.delegate = self;
        _buttonView;
    })];
    
    [self.view addSubview:({
        _resultLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.size.height/2 -100, 44, 200, 44)];
        _resultLabel.textAlignment = NSTextAlignmentCenter;
        _resultLabel.textColor = [UIColor whiteColor];
        _resultLabel;
    })];
    [self.view addSubview:({
        CGRect rect = self.view.bounds;
        CGRect scanFrame = CGRectMake(rect.size.height*0.2, rect.size.width*0.2, rect.size.height*0.6, rect.size.width*0.6);
        NSString *bundlePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"MPIDRSSDK.bundle"];
        NSString * scanImagePath = [bundlePath stringByAppendingPathComponent:@"scan"];
        UIImage *scanImage = [UIImage imageNamed:scanImagePath];
        _imageView = [[UIImageView alloc] initWithFrame:scanFrame];
        _imageView.image = scanImage;
        _imageView.backgroundColor = [UIColor clearColor];
        _imageView.hidden = true;
        _imageView;
    })];
}
- (void)initRTCSDK
{
    NSString *userId = [[DemoSetting sharedInstance] userId];
    [MPIDRSSDK initRTCWithUserId:userId appId:AppId success:^(id  _Nonnull responseObject) {
        self.artvcEgnine = responseObject;
        
        self.artvcEgnine.delegate = self;
        self.artvcEgnine.videoProfileType = ARTVCVideoProfileType_640x360_15Fps;
        // 发布
        ARTVCPublishConfig *publishConfig = [[ARTVCPublishConfig alloc] init];
        publishConfig.videoProfile = self.artvcEgnine.videoProfileType;
        publishConfig.audioEnable = YES;
        publishConfig.videoEnable = YES;
        self.artvcEgnine.autoPublishConfig = publishConfig;
        self.artvcEgnine.autoPublish = YES;
        // 订阅
        ARTVCSubscribeOptions *subscribeOptions = [[ARTVCSubscribeOptions alloc] init];
        subscribeOptions.receiveAudio = YES;
        subscribeOptions.receiveVideo = YES;
        self.artvcEgnine.autoSubscribe = subscribeOptions;
        self.artvcEgnine.autoSubscribe = YES;
        
        //订阅本地视频流和音频流
        self.artvcEgnine.enableAudioBufferOutput = YES;
        self.artvcEgnine.enableCameraRawSampleOutput = YES;
        //订阅远端音频流
        self.artvcEgnine.enableRemoteMixedAudioBufferOutput = YES;
        
        self.artvcEgnine.expectedAudioPlayMode = ARTVCAudioPlayModeSpeaker;
        self.artvcEgnine.degradationPreference = ARTVCDegradationPreferenceMAINTAIN_FRAMERATE;
        [self.artvcEgnine startCameraPreviewUsingBackCamera:NO];
        [self createRoomIfNeeded];
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
}


- (void)initIDRSSDK
{
    NSString * userId = [[DemoSetting sharedInstance] userId];
    [MPIDRSSDK initWithRecordType:IDRSRecordRemote userId:userId appId:AppId packageName:PackageName AK:Ak SK:Sk success:^(id responseObject) {
        self->_idrs = responseObject;
        self->_idrs.nui_tts_delegate = self;
    } failure:^(NSError *error) {
        [self showToastWith:@"Code: 1 msg: sdk init error" duration:2];
        NSLog(@"");
    }];
}


- (void)createRoomIfNeeded {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.roomId && self.rtoken) {
            self.isOther = false;
            //需要在主线程调用
            [MPIDRSSDK joinRoom:self.roomId token:self.rtoken];
            self.title = [NSString stringWithFormat:@"%@ - %@",self.roomId,self.rtoken];
        }else {
            self.isOther = true;
            //需要在主线程调用
            [MPIDRSSDK createRoom];
        }
    });
}

- (NSUInteger)cellCount {
    [self.viewLock lock];
    NSUInteger count = [self.feedSource count];
    [self.viewLock unlock];
    return count;
}

-(void)startCustomAudioCapture{
    // Attention: the code below is a beta version!
    ARTVCCreateCustomVideoCaputurerParams* params = [[ARTVCCreateCustomVideoCaputurerParams alloc] init];
    params.audioSourceType = ARTVCAudioSourceType_Custom;
    params.customAudioFrameFormat.sampleRate = 16000;
    params.customAudioFrameFormat.samplesPerChannel = 160;
    ARTVCPublishConfig* config = [[ARTVCPublishConfig alloc] init];
    config.videoSource = ARTVCVideoSourceType_Custom;
    // Attention: 即使自定义推流仅用到音频，config.videoEnable也要设置为YES，否则推流失败。这个逻辑后续立即会进行优化。
    config.videoEnable = YES;
    // config.audioSource 必须设置为ARTVCAudioSourceType_Custom，否则将会使用麦克风采集。
    config.audioSource = ARTVCAudioSourceType_Custom;
    
    self.customCapturer = [_artvcEgnine createCustomVideoCapturer:params];
    _artvcEgnine.autoPublish = NO;
    // 这里需要主动调用publish
    [_artvcEgnine publish:config];
//    [self pubishCustomVideo];
}

- (void)didCustomAudioDataNeeded{
    // 这里保证不会越界。
    // 数据发送完后，要调用stopCustomAudioCapture，否则下次调用start会失败
    if (_customAudioDataIndex + 320 > (int)[_customAudioData length]) {
        return ;
    }
    
    // 每次送入960字节（10ms）的数据，注意 当前自定义推流仅支持48000采样率、单声道、16位的PCM格式
    // 960 = 48000 / (1000ms / 10ms) * 2
    NSRange range = NSMakeRange (_customAudioDataIndex, 320);
    NSData *data = [_customAudioData subdataWithRange:range];
    [_artvcEgnine sendCustomAudioData:data];
    _customAudioDataIndex += 320;
}

#pragma mark -- IDRSNUITTS Delegate
- (void)onPlayerDidFinish{
    NSLog(@"remote :: 播放完成");
    //关闭自定义音频通道
    isOpen = true;
//    [_artvcEgnine stopCustomAudioCapture];

}
- (void)onNuiTtsEventCallback:(ISDRTtsEvent)event taskId:(NSString *)taskid code:(int)code{
    NSLog(@"remote :: onNuiTtsEventCallback:%lu",(unsigned long)event);
}

BOOL isOpen = true;
- (void)onNuiTtsUserdataCallback:(NSString *)info infoLen:(int)info_len buffer:(char *)buffer len:(int)len taskId:(NSString *)task_id{
    NSLog(@"remote :: onNuiTtsUserdataCallback:%@ -- %d",info,info_len);
    if (buffer) {
        if (isOpen) {
            isOpen = false;
        }
        NSData *audioData = [NSData dataWithBytes:buffer length:len];
        if (!self.customAudioData) {
            self.customAudioData = [NSMutableData data];
        }
        [self.customAudioData appendData:audioData];
    }
}


- (void)onNuiKwsResultCallback:(NSString *)result{
    NSLog(@"remote :: onNuiKwsResultCallback:%@",result);
    if (result.length > 0) {
        [self showToastWith:result duration:1.0];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self cellCount];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ProRemoteCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:NSStringFromClass(ProRemoteCell.class) forIndexPath:indexPath];
    NSUInteger index = [indexPath indexAtPosition:1];
    ARTVCRenderUnit* info;
    [_viewLock lock];
    info = [_feedSource objectAtIndex:index];
    [_viewLock unlock];
    [cell updateUI:info];
    return cell;
}
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}
#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(80, 80);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    CGFloat padding = 10;
    return UIEdgeInsetsMake(padding, 0, padding, 0);
}

//设置每个item水平间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}


//设置每个item垂直间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 10;
}

#pragma mark - ARTVCDelegate
- (void)didReceiveRoomInfo:(ARTVCRoomInfomation*)roomInfo {
    self.roomInfoLabel.text = [NSString stringWithFormat:@"%@ \n %@ \n %@",roomInfo.roomId,roomInfo.rtoken,[DemoSetting sharedInstance].userId];
    self.roomInfoLabel.numberOfLines = 0;
    NSLog(@" roomId : %@ passWord : %@",roomInfo.roomId,roomInfo.rtoken);
    self.roomId = roomInfo.roomId;
    [self.roomInfoLabel sizeToFit];
    [self.view bringSubviewToFront:self.roomInfoLabel];
}

- (void)didJoinroomSuccess {
    NSLog(@"加入成功");
}

- (void)didReceiveLocalFeed:(ARTVCFeed*)localFeed {
    _localFeed = localFeed;
}

- (void)didVideoRenderViewInitialized:(UIView*)renderView forFeed:(ARTVCFeed*)feed {
    BOOL isLocalFeed;
    [self.viewLock lock];
    ARTVCRenderUnit *renderUnit = [[ARTVCRenderUnit alloc] init];
    renderUnit.renderView = renderView;
    renderUnit.feed = feed;
    isLocalFeed = [feed isEqual:_localFeed];
    if (isLocalFeed) {
        renderUnit.renderView.frame = self.view.frame;
        [self.contentView addSubview:renderUnit.renderView];
    }else {
        [self.feedSource addObject:renderUnit];
        [self.collectionView reloadData];
    }
    [self.viewLock unlock];
}

- (void)didAudioPlayModeChangedTo:(ARTVCAudioPlayMode)audioPlayMode {
    NSLog(@"");
}

- (void)didNetworkChangedTo:(APMNetworkReachabilityStatus)netStatus {
    NSLog(@"");
}

- (void)didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer {
    __weak __typeof(self) weakSelf = self;
    //创建串行队列
    dispatch_queue_t testqueue = dispatch_queue_create("subVideo", NULL);
    //同步执行任务
    dispatch_sync(testqueue, ^{
        
        CVPixelBufferRef newBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) ;
        
        if (_isWrite) {//签名检测；
            UIImage * image = [self.idrs getImageFromRPVideo:newBuffer];
            NSArray<NSNumber*> *kXMediaOptionsROIKey = @[@(0.2),@(0.2),@(0.6),@(0.6)];
            NSArray<IDRSSignConfidenceCheck *>*sings = [self.idrs checkSignClassifyWithImage:image AndROI:kXMediaOptionsROIKey];
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString*string = @"";
                float max = 0.0;
                for (IDRSSignConfidenceCheck* Confidence in sings) {
                    if (Confidence.confidence > max) {
                        string = Confidence.label;
                        max = Confidence.confidence;
                    }
                }
                if ([string isEqual:@"hand"] && max > 0.95) {
                    self.resultLabel.text = [NSString stringWithFormat:@"手写体"];
                    [self didsendMessage:@"检测到手写体" isOn:true type:0];
                }
            });
        }

      
        if(_isFaceCheck){
            @autoreleasepool {
                //用data检测
                uint8_t *data = [IDRSUtils convert420PixelBufferToRawData:newBuffer];
                float width = CVPixelBufferGetWidth(newBuffer);
                float height = CVPixelBufferGetHeight(newBuffer);
                IDRSFaceDetectParam *detectParam = [[IDRSFaceDetectParam alloc]init];
                detectParam.dataType = IDRSFaceDetectInputTypeChar;
                detectParam.data = data;
                detectParam.width = width;
                detectParam.height = height;
                detectParam.format = 0;
                detectParam.inputAngle = 0;
                detectParam.outputAngle = 0;
                detectParam.faceNetType = 1;
                detectParam.supportFaceRecognition = true;
                detectParam.supportFaceLiveness = true;
                
//                IDRSFaceDetectParam *detectParam = [[IDRSFaceDetectParam alloc]init];
//                detectParam.dataType = IDRSFaceDetectInputTypePixelBuffer;
//                detectParam.buffer = newBuffer;
//                detectParam.inputAngle = 0;
//                detectParam.outputAngle = 0;
//                detectParam.faceNetType = 1;
//                detectParam.format = 0;
//                detectParam.supportFaceRecognition = true;
//                detectParam.supportFaceLiveness = true;
                
                [_idrs faceTrackFromVideo:detectParam faceDetectionCallback:^(NSError *error, NSArray<FaceDetectionOutput *> *faces) {
                    //脸的标识框：
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.drawView.faceDetectView.detectResult = faces;
                    });
                }];
                free(data);
            }
        }else{
            dispatch_async(dispatch_get_main_queue(), ^{
                self.drawView.faceDetectView.detectResult = nil;
            });
        }//人脸框结束;
        
        if (weakSelf.isOCR_Front || weakSelf.isOCR_Back) {
            @autoreleasepool {
                BOOL isForont = weakSelf.isOCR_Front? true:false;
                // 2. ocr身份证。
                IDRSIDCardDetectParam *idCardParam = [[IDRSIDCardDetectParam alloc]init];
                idCardParam.dataType = IDRSIDCardInputTypePixelBuffer;
                idCardParam.buffer = newBuffer;
                NSArray<NSNumber*> *kXMediaOptionsROIKey = @[@(0.2),@(0.2),@(0.6),@(0.6)];
                IDCardDetectionOutput *ocrResult = [_idrs detectIDCard:idCardParam roiKey:kXMediaOptionsROIKey rotate:@(0) isFrontCamera:NO isDetectFrontIDCard:isForont];

                if (ocrResult!=nil) {
                    NSString *result = @"";
                    if (ocrResult.num.length > 0) {
                        result = ocrResult.num;
                    }else if (ocrResult.endDate.length > 0){
                        result = ocrResult.endDate;
                    }
                    // 采集到了身份证信息
                    dispatch_async(dispatch_get_main_queue(), ^{
                        // 显示身份证信息
                        self.resultLabel.text = result;
                        [self didsendMessage:result isOn:true type:0];
                    });
                }
            }
        }

        // 3. 手势检测
        if (weakSelf.isHandDet) {
            @autoreleasepool {
                IDRSHandDetectParam *handParam = [[IDRSHandDetectParam alloc]init];
                handParam.dataType = IDRSHandInputTypeRGBA;
                handParam.buffer = newBuffer;
                handParam.outAngle = 0;
                NSArray<HandDetectionOutput *> *handResults = [_idrs detectHandGesture:handParam];

                if(handResults.count > 0) {
                    // 判断签字
                    if (handResults[0].phone_touched_score>0) {
                        //手写框
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.drawView.handDetectView.detectResult = handResults;
                            if(handResults[0].hand_phone_action == 1 || handResults[0].hand_phone_action == 2) {
                                self.resultLabel.text = @"签字成功";
                                [self didsendMessage:@"签字成功" isOn:true type:0];
                            }
                        });
                    }
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        weakSelf.drawView.handDetectView.detectResult = nil;
                    });
                }
            }
        }
        //静态手势检测
        if(self.isStaticHandDet) {
            @autoreleasepool {
                IDRSHandDetectParam *handParam = [[IDRSHandDetectParam alloc]init];
                handParam.dataType = IDRSHandInputTypeRGBA;
                handParam.buffer = newBuffer;
                handParam.outAngle = 0;

                NSArray<HandDetectionOutput *> *handResults = [_idrs detectHandStaticGesture:handParam];
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (handResults.count > 0) {
                        weakSelf.drawView.handDetectView.detectResult = handResults;

                        HandDetectionOutput *handResult = handResults[0];
                        if (handResult.hand_action_type == 0 && handResult.hand_static_action > 0) {
                            NSString *result = [self handStaticActionTypeToText:handResult.hand_static_action];
                            self.resultLabel.text = result;
                            [self didsendMessage:result isOn:true type:0];

                        }
                    }else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            weakSelf.drawView.handDetectView.detectResult = nil;
                        });
                    }
                });
            }
        }
        if (!weakSelf.isHandDet && !weakSelf.isStaticHandDet) {
            dispatch_async(dispatch_get_main_queue(), ^{
                weakSelf.drawView.handDetectView.detectResult = nil;
            });
        }
    });

}

- (void)didOutputAudioBuffer:(ARTVCAudioData*)audioData {
    if (_isNui) {
        NSLog(@"Remote :: 检测本地音频");
        if (audioData.audioBufferList->mBuffers[0].mData != NULL && audioData.audioBufferList->mBuffers[0].mDataByteSize > 0) {
            
            pcm_frame_t pcmModelInput;
            pcmModelInput.len = audioData.audioBufferList->mBuffers[0].mDataByteSize;
            pcmModelInput.buf =  (uint8_t*)audioData.audioBufferList->mBuffers[0].mData;
            pcmModelInput.sample_rate = audioData.sampleRate;
            
            pcm_frame_t pcmModelOutput;
            pcm_resample_16k(&pcmModelInput, &pcmModelOutput);
            
            NSData *srcData = [NSData dataWithBytes:pcmModelOutput.buf length:pcmModelOutput.len];
            //传给nuiSDK----需要16000数据
            [self.idrs feedAudioFrame:srcData];
            
        }
    }
}

- (void)didOutputRemoteMixedAudioBuffer:(ARTVCAudioData *)audioData
{
    if (_isRemoteNui) {
        NSLog(@"Remote :: 检测远端音频");
        if (audioData.audioBufferList->mBuffers[0].mData != NULL && audioData.audioBufferList->mBuffers[0].mDataByteSize > 0) {

            pcm_frame_t pcmModelInput;
            pcmModelInput.len = audioData.audioBufferList->mBuffers[0].mDataByteSize;
            pcmModelInput.buf =  (uint8_t*)audioData.audioBufferList->mBuffers[0].mData;
            pcmModelInput.sample_rate = audioData.sampleRate;

            NSData * data = [NSData dataWithBytes:pcmModelInput.buf length:pcmModelInput.len];

            pcm_frame_t pcmModelOutput;
            pcm_resample_16k(&pcmModelInput, &pcmModelOutput);

            NSData *srcData = [NSData dataWithBytes:pcmModelOutput.buf length:pcmModelOutput.len];
            //传给nuiSDK----需要16000数据
            [self.idrs feedAudioFrame:srcData];
        }
    }
}


- (void)didEncounterError:(NSError *)error forFeed:(ARTVCFeed*_Nullable)feed {
    NSLog(@"");
}

- (void)didConnectionStatusChangedTo:(ARTVCConnectionStatus)status forFeed:(ARTVCFeed*)feed {
    [self showToastWith:[NSString stringWithFormat:@"connection status:%d\nfeed:%@",status,feed] duration:1.0];
    if((status == ARTVCConnectionStatusClosed)  && [feed isEqual:_localFeed]){
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didFirstVideoFrameRendered:(UIView*)renderView forFeed:(ARTVCFeed*)feed {
    NSLog(@"");
}

- (void)didVideoViewRenderStopped:(UIView*)renderView forFeed:(ARTVCFeed*)feed {
    NSLog(@"");
}

- (void)didParticepantsEntered:(NSArray<ARTVCParticipantInfo*>*)participants {
    NSLog(@"");
}

- (void)didParticepant:(ARTVCParticipantInfo*)participant leaveRoomWithReason:(ARTVCParticipantLeaveRoomReasonType)reason {
    NSLog(@"");
}

- (void)didNewFeedAdded:(ARTVCFeed*)feed {
    NSLog(@"");
}

- (void)didFeedRemoved:(ARTVCFeed*)feed {
    for (int i = 0; i < self.feedSource.count; i++) {
        ARTVCRenderUnit *unit = self.feedSource[i];
        if ([unit.feed isEqual:feed]) {
            [_viewLock lock];
            [self.feedSource removeObjectAtIndex:i];
            [_viewLock unlock];
            [self.collectionView reloadData];
            return;
        }
    }
    
    NSLog(@"");
}
/**
 receive this callback under these scenarios:
 1. cellular call connected
 2. dialing a cellular call
 */
- (void)callWillBeClosedAsInterruptionHappened {
    NSLog(@"");
}

#pragma mark - Toast error
-(void)showToastWith:(NSString*)text duration:(NSTimeInterval)duration{
    __weak ProRemoteViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong ProRemoteViewController *strongSelf = weakSelf;
        [strongSelf.navigationController.view makeToast:text duration:duration position:ARTVCToastPositionCenter];
    });
}

- (int)getRandomNumber:(int)from to:(int)to {
    return (int)(from + (arc4random() % (to - from + 1)));
}

- (UILabel *)roomInfoLabel {
    if (!_roomInfoLabel) {
        _roomInfoLabel = [[UILabel alloc] init];
        _roomInfoLabel.font = [UIFont systemFontOfSize:15];
        _roomInfoLabel.textColor = [UIColor redColor];
        CGFloat navigatorHeight = self.navigationController.navigationBar.frame.size.height;
        CGFloat statusBarHeight = [[UIApplication sharedApplication] statusBarFrame].size.height;
        _roomInfoLabel.frame = CGRectMake(10, navigatorHeight + statusBarHeight + 10, 0, 0);
    }
    return _roomInfoLabel;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CGFloat collectionViewWidth = 80;
        CGFloat collectionViewHeight = collectionViewWidth * 4;
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(self.view.frame.size.height - collectionViewWidth - 10, self.roomInfoLabel.frame.origin.y, collectionViewWidth, collectionViewHeight) collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        _collectionView.backgroundColor = [UIColor clearColor];
        [_collectionView registerClass:[ProRemoteCell class] forCellWithReuseIdentifier:NSStringFromClass(ProRemoteCell.class)];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
    }
    return _collectionView;
}

#pragma mark -- ButtonViewDelegate
- (void)clickButton:(UISwitch *)btn andWithtpye:(int)state {
    switch (state) {
        case 0:
            [self revertCameraButtonAction];//换摄像头
            break;
        case 1:
            [self handButtonAction:btn.isOn];//动态手势
            //            [self face1ButtonAction:btn.isOn];//采集人脸
            break;
        case 2:
            [self staticHandButtonAction:btn.isOn];//静态手势
            //
            break;
        case 3:
            [self ocrCheckHeadButtonAction:btn.isOn];//身份证(头像)
            break;
        case 4:
            [self ocrCheckEmblemButtonAction:btn.isOn];//身份证(国徽)
            break;
        case 5:
            [self handWriteButtonAction:btn.isOn];//手写体识别
            //
            break;
        case 6:
            [self nuiButtonAction:btn.isOn];//激活词
            //
            break;
        case 7:
            [self startTtsButtonAction:btn.isOn];//文字转语音
            
            break;
        case 8:
            [self pauseTtsButtonAction:btn.isOn];//暂停播报
            break;
        case 9:
            [self otherPersonDoit:btn.isOn];//对端检测
            break;
        case 10:
            [self rtcRecoder:btn.isOn];//录制
            break;
            
        default:
            break;
    }
    //            if (@available(iOS 12.4, *)) {
    //                //应用内共享
    //                [self startScreenshare:btn.isOn];//屏幕共享
    //            }else{
    //                //应用外共享
    //                [self startAllScreenshare:btn.isOn];
    //            }
    
}
#pragma mark -- Button - Action
- (void)revertCameraButtonAction
{
    [self.artvcEgnine switchCamera];
}

- (void)handWriteButtonAction:(BOOL)isOn
{
    [self didsendMessage:isOn?@"开启手写体检测":@"关闭手写体检测" isOn:isOn type:2];
    if (self.isOther) {
        self.isWrite = isOn;
    }
}

- (void)handButtonAction:(BOOL)isOn
{
    if (self.isOther) {
        self.isHandDet = isOn;
        self.isFaceCheck = !isOn;
    }
    [self didsendMessage:isOn?@"开启动态手势检测":@"关闭动态手势检测" isOn:isOn type:3];
}

- (void)staticHandButtonAction:(BOOL)isOn
{
    if (self.isOther) {
        self.isStaticHandDet = isOn;
        self.isFaceCheck = !isOn;
    }
    [self didsendMessage:isOn?@"开启静态手势检测":@"关闭静态手势检测" isOn:isOn type:4];
}

- (void)nuiButtonAction:(BOOL)isOn
{
    self.isNui = NO;
    [self didsendMessage:isOn?@"开启激活词检测":@"关闭激活词检测" isOn:isOn type:5];
    if (self.isOther) {
        self.isNui = isOn;
        if (isOn) {
            [self.idrs startDialog];
        }else{
            [self.idrs stopDialog];
        }
    }else{
        self.isRemoteNui = isOn;
        if (isOn) {
            [self.idrs startDialog];
        }else{
            [self.idrs stopDialog];
        }
    }
}
- (void)startTtsButtonAction:(BOOL)isOn
{
    if (isOn) {
        [self startCustomAudioCapture];
        NSString * string = @"您所购买的是中国人寿保险股份有限公司名为国寿附加国寿福豁免保险费重大疾病保险（盛典版）的保险产品";
        _customAudioData = [[NSMutableData alloc] init];
        _customAudioDataIndex = 0;
        [self.idrs setTTSParam:@"extend_font_name" value:@"xiaoyun"];
        [self.idrs setTTSParam:@"speed_level" value:@"1"];
        [self.idrs startTTSWithText:string];
    }else{
//        [self.idrs stopTTS];
        NSString * string = @"您所购买的是中国人寿保险股份有限公司名为国寿附加国寿福豁免保险费重大疾病保险（盛典版）的保险产品";
//        _customAudioData = [[NSMutableData alloc] init];
//        _customAudioDataIndex = 0;
//        [self.idrs setTTSParam:@"extend_font_name" value:@"xiaoyun"];
//        [self.idrs setTTSParam:@"speed_level" value:@"1"];
        [self.idrs startTTSWithText:string];
    }
}

- (void)pauseTtsButtonAction:(BOOL)isOn
{
    if (isOn) {
        [self.idrs pauseTTS];
    }else{
        [self.idrs resumeTTS];
    }
}

- (void)ocrCheckHeadButtonAction:(BOOL)isOn
{
    [self didsendMessage:isOn?@"开启身份证正面检测":@"关闭身份证正面检测" isOn:isOn type:6];
    if (self.isOther) {
        _imageView.hidden = !isOn;
        self.isOCR_Front = isOn;
        self.isFaceCheck = !isOn;
    }
}

- (void)ocrCheckEmblemButtonAction:(BOOL)isOn
{
    [self didsendMessage:isOn?@"开启身份证反面检测":@"关闭身份证反面检测" isOn:isOn type:7];
    if (self.isOther) {
        _imageView.hidden = !isOn;
        self.isOCR_Back = isOn;
        self.isFaceCheck = !isOn;
    }
}

- (void)otherPersonDoit:(BOOL)isOn
{
    self.isOther = !isOn;
    [self didsendMessage:@"" isOn:isOn type:1];
}

- (void)rtcRecoder:(BOOL)isOn{
    if (isOn) {
        [self rtcBindServer];
    }else{
        [MPIDRSSDK stopRemoteRecord:self.recordId];
    }
}


- (void)startScreenshare:(BOOL)isOn
{
    
}

- (void)startAllScreenshare:(BOOL)isOn
{
    
}

#pragma mark - screen capturer
//-(void)startScreenSharing {
//    ARTVCCreateScreenCaputurerParams* screenParams = [[ARTVCCreateScreenCaputurerParams alloc] init];
//    screenParams.provideRenderView = YES;
//    [self.artvcEgnine startScreenCaptureWithParams:screenParams complete:^(NSError* error){
//        if(error){
//            [self showToastWith:[NSString stringWithFormat:@"Error:%@",error] duration:1.0];
//        }else{
//            ARTVCPublishConfig* config = [[ARTVCPublishConfig alloc] init];
//            config.videoSource = ARTVCVideoSourceType_Screen;
//            config.audioEnable = NO;
//            config.videoProfile = ARTVCVideoProfileType_1280x720_30Fps;
//            [self.artvcEgnine publish:config];
//        }
//    }];
//}
//-(void)stopScreenSharing{
//    [self.artvcEgnine stopScreenCapture];
//    ARTVCUnpublishConfig* config = [[ARTVCUnpublishConfig alloc] init];
//    //    config.feed = self.screenLocalFeed;
//    [self.artvcEgnine unpublish:config complete:^(){
//        dispatch_async(dispatch_get_main_queue(), ^{
//
//        });
//    }];
//}
#pragma mark -- IM
//发送消息
- (void)didsendMessage:(NSString *)message isOn:(BOOL)isOn type:(int)type{
    
    NSDictionary* dic = @{@"mes":message,@"isOn":@(isOn),@"type":@(type)};
    ARTVCIMMessage* msg = [[ARTVCIMMessage alloc] init];
    msg.msg = [self DataTOjsonString:dic];
    [_artvcEgnine sendMessage:msg toPariticipants:@[] complete:^(NSError * _Nonnull error) {
        if(!error){
            NSLog(@"IM 发送： 成功");
        }else{
            [self showToastWith:[error description] duration:1.0];
        }
    }];
}
- (void)didReceiveIMMessage:(ARTVCIMMessage *)message fromParticipant:(NSString *)participant{
    if (![[DemoSetting sharedInstance].userId isEqual:participant]) {
        NSLog(@"IM 接收： %@",message.msg);
        NSDictionary *dic = [self getDictionaryWithJSONString:message.msg];
        [self messageShow:dic];
        BOOL isOn = [dic[@"isOn"] boolValue];
        int IMType = [dic[@"type"] intValue];
        switch (IMType) {
            case 0: {
                
            }
                break;
            case 1:{
                self.isOther = isOn;
            }
                break;
            case 2:{
                if (self.isOther) {
                    self.isWrite = isOn;
                }
            }
                break;
            case 3:{
                if (self.isOther) {
                    self.isHandDet = isOn;
                }
            }
                break;
            case 4:{
                if (self.isOther) {
                    self.isStaticHandDet = isOn;
                }
            }
                break;
            case 5:{
                if (self.isOther) {
                    self.isNui = isOn;
                    if (isOn) {
                        [self.idrs startDialog];
                    }else{
                        [self.idrs stopDialog];
                    }
                }
            }
                break;
            case 6:{
                if (self.isOther) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.isOCR_Front = isOn;
                        self->_imageView.hidden = !isOn;
                        self.isFaceCheck = !isOn;
                    });
                }
            }
                break;
            case 7:{
                if (self.isOther) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.isOCR_Back = isOn;
                        _imageView.hidden = !isOn;
                        self.isFaceCheck = !isOn;
                    });
                }
            }
                break;
            default:
                break;
        }
    }
}

- (void)messageShow:(NSDictionary *)dic{
    [self showToastWith:dic[@"mes"] duration:2];
}
#pragma mark -- 录制相关
//录制信息绑定--AssociateRoom---AppId---RoomId
- (void)rtcBindServer
{
    if (!self.watermarkId) {
        self.watermarkId = WatermarkId;
    }
    [MPIDRSSDK openRemoteRecordWithRoomId:self.roomId waterMarkId:self.watermarkId waterMarkHandler:^(NSError * _Nonnull error) {
        [self showToastWith:@"绑定或者水印获取失败" duration:3];
    }];
}

///录制的回调
- (void)didReceiveCustomSignalingResponse:(NSDictionary *)dictionary{
    id opcmdObject = [dictionary objectForKey:@"opcmd"];
    if ([opcmdObject isKindOfClass:[NSNumber class]]) {
        int opcmd = [opcmdObject intValue];
        switch (opcmd) {
            case 1032: {
                NSLog(@"开始录制");
                self.startTime = [NSDate date];
                self.recordId = [dictionary objectForKey:@"recordId"];
            }
                break;
            case 1034: {
                NSLog(@"结束录制");
                self.duration = [[NSDate date] timeIntervalSince1970] - [self.startTime timeIntervalSince1970];
                //调一个接口、上报录制完成（上传meta及）result文件
                
                IDRSUploadManagerParam *param = [[IDRSUploadManagerParam alloc] init];
                param.duration = self.duration;
                param.appId = AppId;
                param.ak = Ak;
                param.sk = Sk;
                param.type = IDRSRecordRemote;
                param.recordAt = self.startTime;
                param.roomId = self.roomId;
                
                [IDRSUploadManager uploadFileWithParam:param success:^(id  _Nonnull responseObject) {
                    NSLog(@"remote :: %@",responseObject);
                } failure:^(NSError * _Nonnull error, IDRSUploadManagerParam * _Nonnull upLoadParam) {
                    //
                    if (upLoadParam) {
                        [self showToastWith:@"upload error" duration:3];
                        //储存上传信息、下次再次上传
                    }
                }];
            }
                break;
            case 1036: {
                NSLog(@"录制结果回调%@",dictionary);
                
            }
                break;
            default:
                break;
        } }
}

-(NSString*)DataTOjsonString:(id)object{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}
- (NSDictionary *)getDictionaryWithJSONString:(NSString *)jsonString{
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"%@",err);
        return nil;
    }
    return dic;
}
#pragma mark -- private
- (NSString*)handStaticActionTypeToText:(int)type {
    NSArray *action = @[@"Unknown",
                        @"Blur",
                        @"OK",
                        @"Palm",
                        @"Finger",
                        @"NO.8",
                        @"Heart",
                        @"Fist",
                        @"Holdup",
                        @"Congratulate",
                        @"Yeah",
                        @"Love",
                        @"Good",
                        @"Rock",
                        @"NO.3",
                        @"NO.4",
                        @"NO.6",
                        @"NO.7",
                        @"NO.9",
                        @"Greeting",
                        @"Pray",
                        @"Thumbs_down",
                        @"Thumbs_left",
                        @"Thumbs_right",
                        @"Hello",
                        @"Silence",];
    
    
    return [action objectAtIndex:type];;
}

- (void)createStaticMeta
{
    [_idrs startInitTime];
    
}
#pragma mark - 强制转屏
-(void)Reinstatement {
    AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;

    appDelegate.allowRotation = NO;//关闭横屏仅允许竖屏

    [self setNewOrientation:NO];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)setNewOrientation:(BOOL)fullscreen {

    if (fullscreen) {

        NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];

        [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];

        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeLeft];

        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];

    }else{

        NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];

        [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];

        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];

        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];

    }

}
#pragma mark -- 保存本地文件
//创建文件夹
-(void)fileWirteWithData:(NSData*)content withName:(NSString*)name{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString * path = [NSString stringWithFormat:@"%@/%@",documentsDirectory,@"audios"];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir;
    if  (![fileManager fileExistsAtPath:path isDirectory:&isDir]) {//先判断目录是否存在，不存在才创建
        BOOL res=[fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [self createFile:path content:content withName:name];
}
//创建文件
-(void)createFile:(NSString *)path content:(NSData*)content withName:(NSString*)name{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *testPath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.pcm",name]];//在传入的路径下创建test.log文件
    if (![fileManager fileExistsAtPath:testPath]) {
        BOOL res=[fileManager createFileAtPath:testPath contents:nil attributes:nil];
        NSLog(@"文件创建：%@",res?@"成功":@"失败");
    }else{
    }
    [self writeFile:testPath content:content];
}
//写入内容
-(void)writeFile:(NSString *)path content:(NSData*)cont{

    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:path];
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:cont];
    [fileHandle closeFile];
    //[self deleteFileLog];
}
//删除内容
-(void)deleteFileLog {
    NSLog(@"deleteFileLog");
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString * path = [NSString stringWithFormat:@"%@/%@",documentsDirectory,@"audios"];
    NSString *testPath1 = [path stringByAppendingPathComponent:@"remote_16K.pcm"];
    NSString *testPath2 = [path stringByAppendingPathComponent:@"remote_48K.pcm"];
    if ([fileManager fileExistsAtPath:testPath1]) {
        [fileManager removeItemAtPath:testPath1 error:nil];
    }
    if ([fileManager fileExistsAtPath:testPath2]) {
        [fileManager removeItemAtPath:testPath2 error:nil];
    }
}
@end
#endif
