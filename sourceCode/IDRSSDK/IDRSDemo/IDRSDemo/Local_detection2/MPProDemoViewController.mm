//
//  FaceSDKDemoViewController.m
//  IDRSSDKDemo
//
//  Created by cuixling on 2020/3/14.
//  Copyright © 2020年 cuixling. All rights reserved.
//
#if defined(__arm64__)
#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "MPProDemoViewController.h"
#import <CoreMotion/CoreMotion.h>
#import "MProScollLabelView.h"
#import "MProFaceDetectView.h"
#import "MProHandDetectView.h"
#import <MPIDRSProcess/MPIDRSProcess.h>
#import "DemoSetting.h"
//#import <mPaas/MPRotateDevice.h>

#define ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight                        [[UIScreen mainScreen] bounds].size.height

#define segmentedWordsNumber 10
#define AppId [DemoSetting sharedInstance].appId
#define PackageName [DemoSetting sharedInstance].packageName
#define Ak [DemoSetting sharedInstance].ak
#define Sk [DemoSetting sharedInstance].sk
#define ProcessId [DemoSetting sharedInstance].processId

@interface MPProDemoViewController ()<IDRSFlowDelegate,XLMaskViewDelegate>

@property (nonatomic, strong) UIImageView *imageView;//身份证框
@property (nonatomic, strong) IDRSFlow * processSdk;
@property (nonatomic, strong) MProFaceDetectView *faceView;//人脸画框
@property (nonatomic, strong) MProHandDetectView *handView;//手势画框
@property (nonatomic, strong) UILabel *operateResult;//结果显示
@property (nonatomic, strong) UIView  *greenpick;//签名框

@property (nonatomic, strong) NSArray *dataArr;//界面按钮数据
@property (nonatomic, strong) NSString *curPhaseId;//当前章节
@end

@implementation MPProDemoViewController

#pragma mark - life cycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self makeSubViews];//UI添加
    [self makeLayout];//UI位置
    [self makeControl];//SDK初始化
    [self.processSdk wipeCache];//清空保存的数据
    
    //随意修改可变参数: 例：
//    FlowConfig*flowConfig = [FlowConfig sharedInstance];
//    flowConfig.handOutAngle = 0;
//    flowConfig.inputAngle = 0;
//    flowConfig.outputAngle = 0;

}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAll;
}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//if(self.isLandscapeFullScreenPlay){
//return UIInterfaceOrientationMaskLandscapeRight;
//}
//return UIInterfaceOrientationMaskPortrait;
//}

- (void)viewWillAppear:(BOOL)animated{
    if (@available(iOS 16.0, *)) {
//        [self configSupportedInterfaceOrientations:2];
        AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate.allowRotation = YES;
        [self setNeedsUpdateOfSupportedInterfaceOrientations];
        [self.navigationController setNeedsUpdateOfSupportedInterfaceOrientations];
//        
        NSArray *array = [[[UIApplication sharedApplication] connectedScenes] allObjects];
        UIWindowScene *ws = (UIWindowScene *)array[0];
        
        UIWindowSceneGeometryPreferencesIOS *geometryPreferences = [[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:UIInterfaceOrientationMaskLandscapeRight];
        [ws requestGeometryUpdateWithPreferences:geometryPreferences
                                    errorHandler:^(NSError * _Nonnull error) {
            NSLog(@"转错：%@",error);
        }];
    }else{
        [self setNewOrientation:YES];//调用转屏代码
//    if ([[UIDevice currentDevice] respondsToSelector:@selector(setOrientation:)]) {
//           SEL selector = NSSelectorFromString(@"setOrientation:");
//           NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:[UIDevice instanceMethodSignatureForSelector:selector]];
//           [invocation setSelector:selector];
//           [invocation setTarget:[UIDevice currentDevice]];
//           UIDeviceOrientation val = UIDeviceOrientationLandscapeLeft;
//           [invocation setArgument:&val atIndex:2];
//           [invocation invoke];
//       }
    }
    [self startCamera];
}

- (void)viewDidDisappear:(BOOL)animated
{
    if (@available(iOS 16.0, *)) {
        AppDelegate * appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        appDelegate.allowRotation = NO;
        [self setNeedsUpdateOfSupportedInterfaceOrientations];
//        [self.navigationController setNeedsUpdateOfSupportedInterfaceOrientations];
//
        NSArray *array = [[[UIApplication sharedApplication] connectedScenes] allObjects];
        UIWindowScene *ws = (UIWindowScene *)array[0];
        
        UIWindowSceneGeometryPreferencesIOS *geometryPreferences = [[UIWindowSceneGeometryPreferencesIOS alloc] initWithInterfaceOrientations:UIInterfaceOrientationMaskPortrait];
        [ws requestGeometryUpdateWithPreferences:geometryPreferences
                                    errorHandler:^(NSError * _Nonnull error) {
            NSLog(@"转错：%@",error);
        }];
       
    }else{
        [self setNewOrientation:NO];
    }
    [_processSdk destroy];
    [[MProScollLabelView shareManager] dismissTextView];
}

#pragma mark -- Flow Delegate;
- (void)flowCameraView:(UIView *)cameraView didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    //相机流回调
}
//人脸位置
-(void)onFaceDetectUi:(NSArray<faceUIAndName *> *)resules
{
    self.faceView.detectResult = resules;
}
//手位置
- (void)onHandDetectUi:(NSArray<HandDetectionOutput *> *)results
{
    NSLog(@"handUI:%@",results);
    self.handView.detectResult = results;
}

//超时
- (void)onDetectionFail:(id)body
{
    NSLog(@"DetectionFail--%@",body);
    dispatch_async(dispatch_get_main_queue(), ^{
        self.operateResult.text = body;
    });
}
//检测成功
- (void)onDetectionSuccess:(SuccessModel*)body
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *zhangjie = body.checkResult.phaseId;
        NSString *jiancexiang = body.checkResult.detectionId;//=检测类型
        NSString *neirong = @"";
        switch (body.checkResult.Type) {
            case face_track:
                break;
            case face_recognize:
                break;
            case liveness_track:
                break;
            case speech_word_detect:
                neirong = body.speech_word_Result;
                self.operateResult.text = neirong;
                break;
            case id_card_recognize:{
                if (body.ocrOutput.num.length > 0) {
                    neirong = body.ocrOutput.num;
                }else {
                    neirong = body.ocrOutput.startDate;
                }
                self.imageView.hidden = true;
                self.operateResult.text = neirong;
            }
                break;
            case sign_action_recognize:
                neirong = body.sign_action_Result;
                self.operateResult.text = neirong;
                break;
            case static_hand_recognize:
                neirong = [NSString stringWithFormat:@"%@",body.static_hand_Result];
                self.operateResult.text = neirong;
                break;
            case sign_classify_recognize:
                neirong = body.sign_classify_Result==0?@"手写":@"非手写";
                self.operateResult.text = neirong;
                self->_greenpick.hidden = true;
                break;
            case other:
                neirong = body.other;
                self.operateResult.text = neirong;
                break;
            default:
                break;
        }
        NSLog(@"onDetectionSuccess 章节:%@ 检测项:%@ 内容:%@",zhangjie,jiancexiang,neirong);
    });
}
//报错信息
- (void)onError:(NSDictionary *)errorDic withParam:(IDRSUploadManagerParam *)param
{
    NSLog(@"报错信息:%@",errorDic);
    if (param) {
        //上传失败后、返回来的可用于重试/以后上传的参数信息
        __unused IDRSUploadManagerParam * sasda = param;
    }
    NSString *domain = errorDic[@"domain"];
    int code = [errorDic[@"code"] intValue];
    NSString *position = errorDic[@"position"];
    NSString *errorString = [NSString stringWithFormat:@"%@\ncode: -%d\n位置: %@",domain,code,position];
    [self showToastWith:errorString duration:2];
}

//全部流程完成
- (void)onFlowCompleted
{
    self.operateResult.text = @"章节，全部完成";
    NSLog(@"章节，全部完成");
}
//章节开始
- (void)onPhaseStarted:(CheckResult *)phase
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"------xxxxx----:%u",phase.Type);
        switch (phase.Type) {
            case   id_card_recognize:
                NSLog(@"------xxxxx----:身份证框出现");
                self.imageView.hidden = false;
                break;
            case sign_classify_recognize:
                NSLog(@"------xxxxx----:签名框出现");
                self->_greenpick.hidden = false;
                break;
            case other:
            {
                //判断是自定义章节
                if ([phase.detectionId isEqual:@"custom"]) {
                    NSLog(@"需要自己去检测、并在有检测结果后、把结果给会给SDK。例：[_processSdk AddCurChapterCustomResult:@‘我是印度人’];");
                }
            }
            default:
                break;
        }
        
        self.operateResult.text = [NSString stringWithFormat:@"%@\n%@\n%@",phase.phaseId,phase.detectionId,phase.content];
        if (![phase.phaseId isEqual:self->_curPhaseId]) {
            self->_curPhaseId = phase.phaseId;
            [[MProScollLabelView shareManager] setTextViewWithString:phase.content];
            [[MProScollLabelView shareManager] setTextViewLocation:0];
        }
    });
    NSLog(@"%@",phase.content);
}
//章节完成
- (void)onPhaseComleted:(CheckResult *)phase
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"------xxxxx----:%u",phase.Type);
        switch (phase.Type) {
            case  id_card_recognize:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"------xxxxx----:身份证框隐藏");
                    self.imageView.hidden = true;
                });
            }
                break;
            case sign_classify_recognize:{
                dispatch_async(dispatch_get_main_queue(), ^{
                    NSLog(@"------xxxxx----:签名框隐藏");
                    self->_greenpick.hidden = true;
                });
            }
                break;
            default:
                break;
        }
    });
    NSLog(@"%@",phase.content);
}
- (void)ossUploadWithStarted:(BOOL)isRun msg:(id)msg
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *message = @"";
        if ([msg isKindOfClass:[NSString class]]) {
            message = msg;
        }else if ([msg isKindOfClass:[NSDictionary class]]) {
            message = [msg[@"Code"] isEqual:@"OK"]? @"上传成功":@"上传失败";
        }
        self.maskView.label.text = message;
        self.maskView.label.numberOfLines = 0;
        [self.maskView.label sizeToFit];
        if (isRun) {
            self->_maskView.hidden = false;
            //蒙层旋转等待
            //可标注当前上传的文件信息 msg
            [self.maskView loadingViewShow];
        }else {
            //蒙层按钮状态
            [self.maskView loadingViewHidden];
        }
    });
}

//tts合成数据返回
- (void)onTTSCallBackwithText:(NSString *)info word_idx:(int)info_len buffer:(char *)buffer len:(int)len taskid:(NSString *)taskid
{
    NSLog(@"TTSCallBack:%@----%lu",info,(unsigned long)info.length);
    [[MProScollLabelView shareManager] setTextViewLocation:(int)info.length];
}

- (void)downloadAudio:(float)per percent:(NSString *)percent isAll:(BOOL)isAll error:(NSError *)error{
    if (error) {
        return;
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        
        self.operateResult.text = [NSString stringWithFormat:@"当前文件进度：%.2f %% \n 总文件下载进度：%@\n是否全部下载完成：%@",per,percent,isAll?@"下载完成":@"未完成"];
    });
}

- (void)clickButton:(UIButton *)sender{
    [self.navigationController popViewControllerAnimated:true];
}

#pragma mark - ui
- (void)makeSubViews
{
    [self.view addSubview:self.faceView];
    [self.view addSubview:self.handView];
    [self uploadDemoButton:(int)self.dataArr.count];
    [[MProScollLabelView shareManager] showTextView];
    [self.view addSubview:self.imageView];
    [self.view addSubview:self.operateResult];
    [self.view addSubview:self.maskView];
    [self.view addSubview:self.greenpick];
}

- (void)makeLayout
{
    self.faceView.frame = CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width);
    self.handView.frame = CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width);
    self.operateResult.frame = CGRectMake(130, 44, self.view.frame.size.height - 150, 200);
    // 身份证引导框
    CGRect rect = self.view.bounds;
    CGRect scanFrame = CGRectMake(rect.size.height*0.2,rect.size.width*0.2, rect.size.height*0.6, rect.size.width*0.6);
    self.imageView.frame = scanFrame;
    
}

- (void)makeControl
{
    FlowCreateConfig * config = [[FlowCreateConfig alloc] init];
    config.ak = Ak;
    config.sk = Sk;
    config.appId = AppId;
    config.userId = [DemoSetting sharedInstance].userId;
    config.packageName = PackageName;//包名、暂时手动传输
    config.processId = ProcessId;//控制台生成的流程Json的Id
    config.ocrroi = @[@0.2,@0.2,@0.6,@0.6];//身份证ROI设置
    config.ocrRotate = 0;//身份证检测角度
    config.isOcrFront = true;//检测身份证哪一面
    config.presetSize = FlowRecorderPresetSize360P;
//    config.outerBusinessId = [DemoSetting sharedInstance].outBusinessId;
    config.isHorizontal = true;
    
    self.processSdk = [[IDRSFlow alloc] initIDRSWithDelegate:self Config:config success:^(NSString *string, JsonBlock jsonBlock) {
        //接收流程Json
        //替换人脸照片----如果多于两个人
        NSMutableDictionary *dataDic = [NSMutableDictionary dictionaryWithDictionary:[self getDictionaryWithJSONString:string]];
        NSMutableArray *rolesArr = [[NSMutableArray alloc] init];
        NSArray*photos = [DemoSetting sharedInstance].photos;
        NSArray*roleNames = [DemoSetting sharedInstance].names;
        NSUInteger num = photos.count >= roleNames.count ? roleNames.count:photos.count;
        for (int i = 0; i < num; i++) {
            NSMutableDictionary *role = [[NSMutableDictionary alloc] init];
            UIImage *image = [UIImage imageWithData: photos[i]];
            [role setObject:[self imageToString:image] forKey:@"photo"];
            [role setObject:roleNames[i] forKey:@"id"];
            [rolesArr addObject:role];
        }
        [dataDic setObject:rolesArr forKey:@"roles"];
        //改人名
        NSString *newString = [self getJSONStringWithDictionary:dataDic];
        if (roleNames.count > 0) {
            newString = [newString stringByReplacingOccurrencesOfString:@"#oneName#" withString:roleNames[0]];
        }
        //修改流程Json---添加检测人的照片base64---修改播报字段最终的姓名内容
        NSString * jsonxx = newString;
        //返回给SDK
        jsonBlock(jsonxx);
    }];
    
}
- (void)startCamera{
    //Orientation确定了视频流角度、而检测需要这个角度、如果此处角度为你页面角度、则检测角度为0即可
    [self.processSdk startCameraWithOrientation:AVCaptureVideoOrientationLandscapeRight back:^(UIView *cameraView) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.view addSubview:cameraView];
            [self.view sendSubviewToBack:cameraView];
            cameraView.frame = self.view.frame;
        });
    }];
}
#pragma mark -- setter
- (MProXLMaskView *)maskView
{
    if (!_maskView) {
        _maskView = [[MProXLMaskView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width)];
        _maskView.delegate = self;
        _maskView.hidden = true;
    }
    return _maskView;
}

- (MProFaceDetectView *)faceView
{
    if (!_faceView) {
        _faceView = [[MProFaceDetectView alloc] init];
        _faceView.isMirror = true;
        _faceView.presetSize = CGSizeMake(1280, 720);
    }
    return _faceView;
}

- (MProHandDetectView *)handView
{
    if (!_handView) {
        _handView = [[MProHandDetectView alloc] init];
        _handView.isMirror = true;
        _handView.presetSize = CGSizeMake(1280, 720);
    }
    return _handView;
}

- (UILabel *)operateResult
{
    if (!_operateResult) {
        _operateResult = [[UILabel alloc] init];
        _operateResult.numberOfLines = 0;
    }
    return _operateResult;
}

- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.hidden = YES;
        NSString *bundlePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"MPIDRSSDK.bundle"];
        NSString * scanImagePath = [bundlePath stringByAppendingPathComponent:@"scan"];
        UIImage *scanImage = [UIImage imageNamed:scanImagePath];
        _imageView.image = scanImage;
        _imageView.backgroundColor = [UIColor clearColor];
    }
    return _imageView;
}

- (UIView *)greenpick
{
    if (!_greenpick) {
        CGRect rect1 = self.view.bounds;
        CGRect scanFrame1 = CGRectMake(rect1.size.height*0.2,rect1.size.width*0.3, rect1.size.height*0.6, rect1.size.width*0.6);
        _greenpick = [[UIView alloc] initWithFrame:scanFrame1];
        UIView *zuoshang1 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 40, 3)];
        zuoshang1.backgroundColor = [UIColor redColor];
        zuoshang1.backgroundColor = [UIColor redColor];
        [_greenpick addSubview:zuoshang1];
        UIView *zuoshang2 = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 3, CGRectGetMaxY(_greenpick.bounds))];
        zuoshang2.backgroundColor = [UIColor redColor];
        [_greenpick addSubview:zuoshang2];

        UIView *zuoxia1 = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(_greenpick.bounds)-3, 40, 3)];
        zuoxia1.backgroundColor = [UIColor redColor];
        [_greenpick addSubview:zuoxia1];
        UIView *youshang1 = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_greenpick.bounds)-40, 0, 40, 3)];
        youshang1.backgroundColor = [UIColor redColor];
        [_greenpick addSubview:youshang1];
        UIView *youshang2 = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_greenpick.bounds)-3, 0, 3, CGRectGetMaxY(_greenpick.bounds))];
        youshang2.backgroundColor = [UIColor redColor];
        [_greenpick addSubview:youshang2];

        UIView *youxia1 = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_greenpick.bounds)-40, CGRectGetMaxY(_greenpick.bounds)-3, 40, 3)];
        youxia1.backgroundColor = [UIColor redColor];
        [_greenpick addSubview:youxia1];
        _greenpick.hidden = YES;
    }
    return _greenpick;
}

- (NSArray *)dataArr
{
    if (!_dataArr) {
        _dataArr = [NSArray arrayWithObjects:@"切换摄像头",@"开始流程",@"下一步",@"上一章",@"重新检测",@"重新播报",@"暂停/恢复", nil];
    }
    return _dataArr;
}

- (void)uploadDemoButton:(int)num{
    for (int i = 0; i < num; i++) {
        UIButton * btn = [[DemoButton alloc] initWithNormalTitle:self.dataArr[i] selectedTitle:nil];
        btn.backgroundColor = [self colorWithHexString:@"#009688"];
        btn.frame = CGRectMake(20, 44 + 40 * i, 100, 32);
        btn.tag = i;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
    }
}

#pragma mark --   UIButton Action
- (void)btnClick:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    switch (sender.tag) {
        case DemoBtnTag_SwichCamera:{
            [_processSdk switchCamera:^(BOOL result) {
                NSLog(@"Demo :: 切换摄像头 %@",result?@"成功":@"失败");
            }];
        }
            break;
        case DemoBtnTag_StartFlow:{
            NSLog(@"Demo :: 开始流程");
            [_processSdk startFlow];
        }
            break;
        case DemoBtnTag_NextDetection:{
            NSLog(@"Demo :: 开始下一项");
            [_processSdk startNextDetection];
        }
            break;
        case DemoBtnTag_LastDetection:{
            NSLog(@"Demo :: 开始上一章");
            [_processSdk reLastPage];
        }
            break;
        case DemoBtnTag_RepeatCurDet:{
            NSLog(@"Demo :: 重新检测当前项");
            [_processSdk repeatCurrentDetection];
        }
            break;
        case DemoBtnTag_RePlayCurCha:{
            NSLog(@"Demo :: 重新播放");
//            //添加自定义章节结果
//            [_processSdk AddCurChapterCustomResult:@"我是印度人"];
            [_processSdk replayCurChapter];
        }
            break;
        case DemoBtnTag_TtsPauRes:{
            if (sender.isSelected) {
                NSLog(@"Demo :: 暂停播放");
                [_processSdk flowPause];
            }else{
                NSLog(@"Demo :: 恢复播放");
                [_processSdk flowResume];
            }
        }
            break;
        default:
            break;
    }
}

#pragma merk -- private
- (NSString *)imageToString:(UIImage *)image {
    NSData *imagedata;
    /*判断图片是不是png格式的文件*/
    if(UIImageJPEGRepresentation(image,1.0))
        imagedata = UIImageJPEGRepresentation(image,1.0);
    /*判断图片是不是jpeg格式的文件*/
    else {
        imagedata = UIImagePNGRepresentation(image);
    }
    
    NSString *image64 = [imagedata base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength];
    NSString*image64NoR = [image64 stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    return image64NoR;
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
-(NSString *)getJSONStringWithDictionary:(NSDictionary *)dict
{
    NSString *jsonString;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict options:NSJSONWritingPrettyPrinted error:nil];
    if (!jsonData) {
        NSLog(@"报错");
        return nil;
    }
    jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return jsonString;
}


- (UIColor *) colorWithHexString: (NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    // String should be 6 or 8 characters
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [UIColor clearColor];
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}
#pragma mark -- 手势
-(void)popGestureChange:(UIViewController *)vc enable:(BOOL)enable{
    if ([vc.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        for (UIGestureRecognizer *popGesture in vc.navigationController.interactivePopGestureRecognizer.view.gestureRecognizers) {
            popGesture.enabled = enable;
        }
    }
}
-(void)showToastWith:(NSString*)text duration:(NSTimeInterval)duration{
    __weak MPProDemoViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong MPProDemoViewController *strongSelf = weakSelf;
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示" message:text preferredStyle:UIAlertControllerStyleAlert];
         [self presentViewController:alert animated:YES completion:nil];
        //控制提示框显示的时间为2秒
         [self performSelector:@selector(dismiss:) withObject:alert afterDelay:duration];
        NSLog(@"toast:: %@",text);
    });
}
- (void)dismiss:(UIAlertController *)alert{
    [alert dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark - 强制转屏
- (void)setNewOrientation:(BOOL)fullscreen {

    if (fullscreen) {

        NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];

        [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];

        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationLandscapeRight];

        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];

    }else{

        NSNumber *resetOrientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationUnknown];

        [[UIDevice currentDevice] setValue:resetOrientationTarget forKey:@"orientation"];

        NSNumber *orientationTarget = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];

        [[UIDevice currentDevice] setValue:orientationTarget forKey:@"orientation"];

    }

}
@end

@implementation DemoButton

- (instancetype)initWithNormalTitle:(NSString *)str1
                       selectedTitle:(NSString *__nullable)str2{
    if (self = [super init]) {
        [self setTitle:str1 forState:UIControlStateNormal];
        if (str2) {
            [self setTitle:str2 forState:UIControlStateSelected];
        }
        [self layoutIfNeeded];
        self.layer.cornerRadius = 12;
        self.layer.masksToBounds = YES;
    }
    return self;
}

@end
#endif
