//
//  FaceSDKDemoViewController.m
//  IDRSSDKDemo
//
//  Created by cuixling on 2020/3/14.
//  Copyright © 2020年 cuixling. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FaceSDKDemoViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMotion/CoreMotion.h>
#import "FaceDetectView.h"
#import "HandDetectView.h"
#import "scollLabelView.h"
#import "DemoSetting.h"
#import "UIView+ARTVCToast.h"
#import <MPIDRSSDK/MPIDRSSDK.h>
//#import <IDRSSDK/TTSPlayer.h>
#import <MPIDRSSDK/IDRSUtils.h>

#import "AppDelegate.h"
#import "IDRSLogManager+DemoLogInterface.h"


#define ScreenWidth                         [[UIScreen mainScreen] bounds].size.width
#define ScreenHeight                        [[UIScreen mainScreen] bounds].size.height

#define segmentedWordsNumber 10

#define AppId [DemoSetting sharedInstance].appId
#define PackageName [DemoSetting sharedInstance].packageName
#define Ak [DemoSetting sharedInstance].ak
#define Sk [DemoSetting sharedInstance].sk
#define WatermarkId [DemoSetting sharedInstance].watermarkId

static FaceSDKDemoViewController *myself = nil;

@interface FaceSDKDemoViewController ()<IDRSNUITTSDelegate>

//@property (strong, nonatomic) UILabel *lbRealFaceRecognition;// 实时人脸检测
//@property (strong, nonatomic) UISwitch *realFaceRecognition;
//@property (strong, nonatomic) UILabel *lbRecordFaceRecognition;// 录屏检测
//@property (strong, nonatomic) UISwitch *recordFaceRecognition;
@property (strong, nonatomic) UILabel *lbFaceRecognition;// 人脸验证
@property (strong, nonatomic) UISwitch *faceRecognition;
@property (strong, nonatomic) UILabel *lbFaceLiveness;// 活体检测
@property (strong, nonatomic) UISwitch *faceLiveness;
@property (strong, nonatomic) UILabel *lbRecord;
@property (strong, nonatomic) UISwitch *record;
@property (strong, nonatomic) UILabel *lbNui;
@property (strong, nonatomic) UISwitch *nuiSwitch;
@property (strong, nonatomic) UILabel *pickFace1;
@property (strong, nonatomic) UISwitch *pickFace1Switch;
@property (strong, nonatomic) UILabel *pickFace2;
@property (strong, nonatomic) UISwitch *pickFace2Switch;
@property (strong, nonatomic) UILabel *idCardOCR;
@property (strong, nonatomic) UISwitch *idCardOCRSwitch;
@property (strong, nonatomic) UILabel *idCardBackOCR;
@property (strong, nonatomic) UISwitch *idCardBackOCRSwitch;
@property (strong, nonatomic) UILabel *addSegment;
@property (strong, nonatomic) UISwitch *addSegmentSwitch;
@property (strong, nonatomic) UILabel *handDet;
@property (strong, nonatomic) UISwitch *handDetSwitch;
@property (strong, nonatomic) UILabel *staticHandDet;
@property (strong, nonatomic) UISwitch *staticHandDetSwitch;
@property (strong, nonatomic) UILabel *ttsLabel;
@property (strong, nonatomic) UISwitch *ttsSwitch;
@property (strong, nonatomic) UILabel *signLabel;
@property (strong, nonatomic) UISwitch *signSwitch;
@property (nonatomic,strong) UIImageView *imageView1;

@property (strong, nonatomic) UILabel *ttsPauseLabel;
@property (strong, nonatomic) UISwitch *ttsPauseSwitch;

@property(nonatomic,strong) MPIDRSSDK* idrsSDK;

@property (nonatomic, assign) BOOL isPickFace1; // 是否正在采集脸1
@property (nonatomic, assign) BOOL isPickFace2; // 是否正在采集脸2

@property (nonatomic, strong) UIView *greenpick;
@property (assign, nonatomic) CGRect greenFrame;
@property (assign, nonatomic) CGRect greenBounds;

@property (nonatomic, assign) int currentSegment; // meta文件segment辅助测试

@property (nonatomic, strong) NSArray<NSNumber*> *face1Feature; // 人脸1的feature
@property (nonatomic, strong) NSArray<NSNumber*> *face2Feature; // 人脸2的feature

@property (nonatomic, strong) UIImageView *imageView; // 身份证引导框
@property (nonatomic, assign) BOOL isIDCardOCR;//是否开启身份证识别
@property (nonatomic, assign) BOOL isIDCardBackOCR; //是否开启身份证背面检测
@property (nonatomic, assign) BOOL isSign;//是否开启签名检测

@property (nonatomic, assign) BOOL isHandDet;//是否开启动态手势识别
@property (nonatomic, assign) BOOL isStaticHandDet;//是否开启静态手势识别

@property (nonatomic, assign) BOOL isTTS;//是否开启TTS语音合成

//@property (nonatomic, assign) BOOL isRealFaceRecogition; // 是否开启实时人脸检测
//@property (nonatomic, assign) BOOL isRecordFaceRecogition; // 是否开启录屏人脸检测

// 展示录像/nui/oss结果
@property (strong, nonatomic) UILabel *operateResult;
// 展示录像/nui/oss结果
@property (strong, nonatomic) UILabel *operateResult1;
// 手势识别
@property (nonatomic, weak) UIImageView *handsView;


@property (nonatomic, assign) BOOL isResetScreenSize; // 是否已经重置过屏幕大小

// TTS播放器
//@property(nonatomic,strong) TTSPlayer *voicePlayer;

@property (nonatomic, strong) NSMutableArray<NSData*> *ttsData; // action数组

@property (nonatomic, strong) NSArray *arrTTSString;
@property (nonatomic, strong) __block NSMutableArray *ttsArray;
@property (nonatomic, assign) __block NSInteger arrayIndex;
@property (nonatomic, assign) __block NSInteger titleIndex;
@property (nonatomic, strong) NSString *rolePhoto;
@property (nonatomic, assign) BOOL isPaused;
@end

@implementation FaceSDKDemoViewController

#pragma mark - life cycle
int zhangjie = 0;

- (void)viewDidLoad {
//    IDRS_Info(@"%@", NSStringFromSelector(_cmd));
    _rolePhoto= @"";
	[super viewDidLoad];//测试、需要、我是、根据、我已、自签、国寿、国寿
	self.arrTTSString = [NSArray arrayWithObjects:@"测试先生，您好。为规范保险销售从业人员的销售行为。也为了更好地保护您的合法权益。根据银保监会有关规定。我们将以录音录像方式对我的销售过程关键环节予以记录。请问您是否同意？请客户清晰回答。",@"被保险人以驾驶员身份于本合同生效之日起一百八十日内（含第一百八十日）驾驶私家车或公务车期间遭受意外伤害并导致被保险人身故或身体高度残疾，本公司不承担给付意外伤害身故或身体高度残疾保险金。国寿附加百万如意行意外伤害住院定额给付医疗保险（盛典版）责任免除,因下列任何情形之一导致被保险人住院治疗的，本公司不承担给付意外伤害住院定额给付医疗保险金、特定意外伤害重症监护病房住院定额给付医疗保险金的责任："
	                     ,nil];
    
	NSError * error = nil;
	NSString *imagePath = [[NSBundle mainBundle] pathForResource:@"闪退" ofType:@"txt"];
	NSString *string = [[NSString alloc] initWithContentsOfFile:imagePath encoding:NSUTF8StringEncoding error:&error];
	if (error != nil) {

	}
    NSString*string1 = [NSString stringWithCString:[string UTF8String] encoding:NSUTF8StringEncoding];
    self.arrTTSString = [NSArray arrayWithObject:string];

	[self initUI];
	// init sdk
	myself = self;//
    [MPIDRSSDK initWithRecordType:IDRSRecordLocal userId:@"shaochangying" appId:AppId packageName:PackageName AK:Ak SK:Sk success:^(id responseObject) {
        self->_idrsSDK = responseObject;
        self->_idrsSDK.nui_tts_delegate = self;
        // 配置手势检测参数
        IDRSHandDetectionConfig *handDetectConfig = [[IDRSHandDetectionConfig alloc] init];
        handDetectConfig.imgSize = 480;
        handDetectConfig.isFaceDetect = true;
        handDetectConfig.classifyThreshold = 0.5;
        handDetectConfig.phoneActionIOU = 0.0;
        handDetectConfig.phoneActionTime = 0.0;
        handDetectConfig.phoneActionSign = 0.03;//签字阈值，越小识别的越快
        handDetectConfig.phoneActionScroll = 0.10;
        handDetectConfig.interlacingBody = 5;
        [self->_idrsSDK setHandDetectConfig:handDetectConfig];
        
        [self duqutupian];
        
    } failure:^(NSError *error) {
        NSLog(@"初始化失败");
    }];
	
	_currentSegment = 0;
}
-(void)duqutupian {
	NSData *decodeData = [[NSData alloc] initWithBase64EncodedString:_rolePhoto options:(NSDataBase64DecodingIgnoreUnknownCharacters)];
	// 将NSData转为UIImage
	UIImage *decodedImage = [UIImage imageWithData: decodeData];
	//NSLog(@"人脸对比===图片==  %@",decodedImage);
	IDRSFaceDetectParam *dete = [[IDRSFaceDetectParam alloc]init];
	dete.dataType = IDRSFaceDetectInputTypeImage;
	dete.image = decodedImage;
	dete.inputAngle = 0;
	dete.outputAngle = 90;
	dete.supportFaceLiveness = true;
	dete.supportFaceRecognition = true;
	//                dete.faceNetType=0;
	NSArray<FaceDetectionOutput *> *imageface = [self.idrsSDK detectFace:dete];
	NSLog(@"角色遍历====feature %@",imageface);
    
}
-(void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [[scollLabelView shareManager] dismissTextView];
	if(_idrsSDK) {
		[_idrsSDK releaseResources];
		_idrsSDK = nil;
	}
}

-(void)dealloc {
	if(_idrsSDK) {
		[_idrsSDK releaseResources];
		_idrsSDK = nil;
	}

}

- (void)initUI {
	// 开启录像
	_lbRecord = [[UILabel alloc]initWithFrame:CGRectMake(10, self.navigationbarHeight+4, 50, 40)];
	_lbRecord.textColor = [UIColor redColor];
	_lbRecord.text = @"录像";
	[self.view addSubview:_lbRecord];
	_record = [[UISwitch alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_lbRecord.frame), self.navigationbarHeight+8, 100, 40)];
	[self.view addSubview:_record];
	[_record addTarget:self action:@selector(onRecord:) forControlEvents:UIControlEventValueChanged];

	// 激活词控制
	_lbNui = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(_lbRecord.frame), 50, 40)];
	_lbNui.textColor = [UIColor redColor];
	_lbNui.text = @"激活";
	[self.view addSubview:_lbNui];
	_nuiSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_lbNui.frame), CGRectGetMaxY(_lbRecord.frame), 100, 40)];
	[self.view addSubview:_nuiSwitch];
	[_nuiSwitch addTarget:self action:@selector(onNuiSwitch:) forControlEvents:UIControlEventValueChanged];

	// 采集第一个人脸
	_pickFace1 = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(_lbNui.frame), 50, 40)];
	_pickFace1.textColor = [UIColor redColor];
	_pickFace1.text = @"脸一";
	[self.view addSubview:_pickFace1];
	_pickFace1Switch = [[UISwitch alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_pickFace1.frame), CGRectGetMaxY(_lbNui.frame), 100, 40)];
	[self.view addSubview:_pickFace1Switch];
	[_pickFace1Switch addTarget:self action:@selector(onPickFace1Switch:) forControlEvents:UIControlEventValueChanged];

	// 采集第二个人脸
	_pickFace2 = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(_pickFace1.frame), 50, 40)];
	_pickFace2.textColor = [UIColor redColor];
	_pickFace2.text = @"脸二";
	[self.view addSubview:_pickFace2];
	_pickFace2Switch = [[UISwitch alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_pickFace2.frame), CGRectGetMaxY(_pickFace1.frame), 100, 40)];
	[self.view addSubview:_pickFace2Switch];
	[_pickFace2Switch addTarget:self action:@selector(onPickFace2Switch:) forControlEvents:UIControlEventValueChanged];

	// meta文件辅助测试
	_addSegment = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(_pickFace2.frame), 50, 40)];
	_addSegment.textColor = [UIColor redColor];
	_addSegment.text = @"meta";
	[self.view addSubview:_addSegment];
	_addSegmentSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_addSegment.frame), CGRectGetMaxY(_pickFace2.frame), 100, 40)];
	[self.view addSubview:_addSegmentSwitch];
	[_addSegmentSwitch addTarget:self action:@selector(onAddSegmentSwitch:) forControlEvents:UIControlEventValueChanged];

	// 开启身份证OCR
	_idCardOCR = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(_addSegment.frame), 50, 40)];
	_idCardOCR.textColor = [UIColor redColor];
	_idCardOCR.text = @"证件";
	[self.view addSubview:_idCardOCR];
	_idCardOCRSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_idCardOCR.frame), CGRectGetMaxY(_addSegment.frame), 100, 40)];
	[self.view addSubview:_idCardOCRSwitch];
	[_idCardOCRSwitch addTarget:self action:@selector(onIDCardOCRSwitch:) forControlEvents:UIControlEventValueChanged];

	// 转换身份证OCR正面/背面识别
	_idCardBackOCR = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(_idCardOCR.frame), 50, 40)];
	_idCardBackOCR.textColor = [UIColor redColor];
	_idCardBackOCR.text = @"背面";
	[self.view addSubview:_idCardBackOCR];
	_idCardBackOCRSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_idCardBackOCR.frame), CGRectGetMaxY(_idCardOCR.frame), 100, 40)];
	[self.view addSubview:_idCardBackOCRSwitch];
	[_idCardBackOCRSwitch addTarget:self action:@selector(onIDCardBackOCRSwitch:) forControlEvents:UIControlEventValueChanged];

	// 开启手势识别
	_handDet = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(_idCardBackOCR.frame), 50, 40)];
	_handDet.textColor = [UIColor redColor];
	_handDet.text = @"手势";
	[self.view addSubview:_handDet];
	_handDetSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_handDet.frame), CGRectGetMaxY(_idCardBackOCR.frame), 100, 40)];
	[self.view addSubview:_handDetSwitch];
	[_handDetSwitch addTarget:self action:@selector(onHandDetSwitch:) forControlEvents:UIControlEventValueChanged];

	// 开启静态手势识别
	_staticHandDet = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(_handDet.frame), 50, 40)];
	_staticHandDet.textColor = [UIColor redColor];
	_staticHandDet.text = @"静态手势";
	[self.view addSubview:_staticHandDet];
	_staticHandDetSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_handDet.frame), CGRectGetMaxY(_handDet.frame), 100, 40)];
	[self.view addSubview:_staticHandDetSwitch];
	[_staticHandDetSwitch addTarget:self action:@selector(onStaticHandDetSwitch:) forControlEvents:UIControlEventValueChanged];

	// 开启TTS语音合成
	_ttsLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(_staticHandDet.frame), 50, 40)];
	_ttsLabel.textColor = [UIColor redColor];
	_ttsLabel.text = @"TTS";
	[self.view addSubview:_ttsLabel];
	_ttsSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_ttsLabel.frame), CGRectGetMaxY(_staticHandDet.frame), 100, 40)];
	[self.view addSubview:_ttsSwitch];
	[_ttsSwitch addTarget:self action:@selector(onTTSSwitch:) forControlEvents:UIControlEventValueChanged];

	_signLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_record.frame), CGRectGetMidY(_record.frame), 50, 40)];
//	_signLabel.textColor = [UIColor redColor];
//	_signLabel.text = @"签名";
//	[self.view addSubview:_signLabel];
	_signSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_signLabel.frame), CGRectGetMidY(_record.frame), 100, 40)];
//	[self.view addSubview:_signSwitch];
//	[_signSwitch addTarget:self action:@selector(onSignSwitch:) forControlEvents:UIControlEventValueChanged];

	// 暂停TTS语音合成
	_ttsPauseLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(_ttsLabel.frame), 50, 40)];
//	_ttsPauseLabel.textColor = [UIColor redColor];
//	_ttsPauseLabel.text = @"Pause";
//	[self.view addSubview:_ttsPauseLabel];
	_ttsPauseSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_ttsPauseLabel.frame), CGRectGetMaxY(_ttsLabel.frame), 100, 40)];
//	[self.view addSubview:_ttsPauseSwitch];
//	[_ttsPauseSwitch addTarget:self action:@selector(onTTSPauseSwitch:) forControlEvents:UIControlEventValueChanged];

	// nui/oss/录像结果
	_operateResult = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(_handDet.frame), self.view.frame.size.width - 20, 40)];
	_operateResult.textColor = [UIColor greenColor];
	_operateResult.numberOfLines = 0;
	[self.view addSubview:_operateResult];
	_operateResult1 = [[UILabel alloc]initWithFrame:CGRectMake(10, CGRectGetMaxY(_operateResult.frame), self.view.frame.size.width - 20, 40)];
	_operateResult1.textColor = [UIColor greenColor];
	_operateResult1.numberOfLines = 0;
	[self.view addSubview:_operateResult1];
	// 身份证引导框
	CGRect rect = self.view.bounds;
	CGRect scanFrame = CGRectMake(rect.size.width*0.2, rect.size.height*0.2, rect.size.width*0.6, rect.size.height*0.6);
	NSString *bundlePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"MPIDRSSDK.bundle"];
	NSString * scanImagePath = [bundlePath stringByAppendingPathComponent:@"scan"];
	UIImage *scanImage = [UIImage imageNamed:scanImagePath];
	_imageView = [[UIImageView alloc] initWithFrame:scanFrame];
	[self.view addSubview:_imageView];
	_imageView.image = scanImage;
	_imageView.backgroundColor = [UIColor clearColor];
	_imageView.hidden = true;

	self.isResetScreenSize = NO;
	self.isIDCardBackOCR = NO;

	//绿色采集框。
	CGRect rect1 = self.view.bounds;
	CGRect scanFrame1 = CGRectMake(rect1.size.width*0.2,rect1.size.height*0.3, rect1.size.width*0.6, rect1.size.width*0.6);
	NSLog(@"xxxx-- %f--%f",scanFrame1.size.width,scanFrame1.size.height);
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
	//    UIView *zuoxia2 = [[UIView alloc]initWithFrame:CGRectMake(0, 120, 3, 120)];
	//    zuoxia2.backgroundColor = [UIColor redColor];
	//    [_greenpick addSubview:zuoxia2];

	UIView *youshang1 = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_greenpick.bounds)-40, 0, 40, 3)];
	youshang1.backgroundColor = [UIColor redColor];
	[_greenpick addSubview:youshang1];
	UIView *youshang2 = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_greenpick.bounds)-3, 0, 3, CGRectGetMaxY(_greenpick.bounds))];
	youshang2.backgroundColor = [UIColor redColor];
	[_greenpick addSubview:youshang2];

	UIView *youxia1 = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(_greenpick.bounds)-40, CGRectGetMaxY(_greenpick.bounds)-3, 40, 3)];
	youxia1.backgroundColor = [UIColor redColor];
	[_greenpick addSubview:youxia1];
	//    UIView *youxia2 = [[UIView alloc]initWithFrame:CGRectMake(300, 120, 3, 120)];
	//    youxia2.backgroundColor = [UIColor redColor];
	//    [_greenpick addSubview:youxia2];
	_greenpick.hidden = YES;
	[self.view addSubview:_greenpick];
	self.greenFrame =_greenpick.frame;
	self.greenBounds = _greenpick.bounds;
    [[scollLabelView shareManager] showTextView];
	//    [self _registerForBackgroundNotifications];
}

-(UIImage*)screenshotFace:(UIImage*)image {

	//    UIImage *image = [self getImageFromCameraVideo:sampleBuffer];
	float x = _greenFrame.origin.x;
	float y = _greenFrame.origin.y;
	float w = _greenFrame.size.width;
	float h = _greenFrame.size.height;
	//剪切图片
	CGRect rect =  CGRectMake(x,y, w, h);//这里可以设置想要截图的区域
	CGImageRef imageRefRect =CGImageCreateWithImageInRect([image CGImage], rect);
	UIImage *sendImage =[[UIImage alloc] initWithCGImage:imageRefRect];
	UIImage *newimage = [UIImage imageWithCGImage:sendImage.CGImage scale:1.0 orientation:UIImageOrientationUpMirrored];

	//自我检测图片状态
	//    UIImageWriteToSavedPhotosAlbum(newimage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
	return newimage;
}
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo {
	NSString *msg = nil;
	if(error != NULL) {
		msg = @"保存图片失败";
	}else{
		msg = @"保存图片成功";
	}
	NSLog(@"%@", msg);
}
#pragma mark - idrsDelegate

- (void)onPlayerDidFinish
{
    NSLog(@"Local :: onPlayerDidFinish");
//    [_idrsSDK startDialog];
}
- (void)onNuiKwsResultCallback:(NSString *)result
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.operateResult.text = result;
    });
    NSLog(@"Local :: onNuiKwsResultCallback: %@",result);
}
-(void)onNuiTtsEventCallback:(ISDRTtsEvent)event taskId:(NSString *)taskid code:(int)code
{
    NSLog(@"Local :: onNuiTtsEventCallback:%lu",(unsigned long)event);
}
- (void)onNuiTtsUserdataCallback:(NSString *)info infoLen:(int)info_len buffer:(char *)buffer len:(int)len taskId:(NSString *)task_id
{
    [[scollLabelView shareManager] setTextViewLocation:info_len];
    NSLog(@"Local :: onNuiTtsUserdataCallback:%lu - %@",(unsigned long)info.length,info);
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate
NSArray<FaceDetectionOutput*> *currentFaces; // 当前页面上的人脸
int woca = 0;
float heheda = 12;
float dadahe = 0;
- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(nonnull CMSampleBufferRef)sampleBuffer fromConnection:(nonnull AVCaptureConnection *)connection {

	BufferType dataType;
	if (self.videoConnection == connection) {
		dataType = CAMERA_VIDEO;
	} else {
		dataType = CAMERA_AUDIO;
	}

	@synchronized (self) {
		NSDictionary *angleDic = [self calculateInAndOutAngle];
		float inAngle = 0;
		float outAngle = 0;
		if (angleDic != nil) {
			inAngle = [angleDic[@"inAngle"] floatValue];
			outAngle = [angleDic[@"outAngle"] floatValue];
		}
		if (_isSign) {
			//            UIImage *image = [UIImage imageNamed:@"print3.bmp"];

			dispatch_async(dispatch_get_main_queue(), ^{
				//                float w = self.view.frame.size.width * 0.6 / self.view.frame.size.height;
				//array内为ROI设置:(x,y,w,h);
				//其中x，y，w，h为当前占比，例：屏幕宽100，框距离左边20，则x = 20/100 = 0.2
				woca++;
				if (woca < 3) {

					return;
				} woca = 0;

				UIImage * image = [self getImageFromCameraVideo:sampleBuffer];
				//                UIImage * newimage = [self screenshotFace:image];
				//                UIImage * image = [UIImage imageNamed:@"IMG_0390.JPG"];
				float x = self->_greenFrame.origin.x/self.view.frame.size.width;
				float y = self->_greenFrame.origin.y/self.view.frame.size.height;
				float w = self->_greenFrame.size.width/self.view.frame.size.width;
				float h = self->_greenFrame.size.height/self.view.frame.size.height;
				NSArray<NSNumber*> *kXMediaOptionsROIKey = @[@(x),@(y),@(w),@(h)];


				NSArray<IDRSSignConfidenceCheck *>*sings = [self->_idrsSDK checkSignClassifyWithImage:image AndROI:kXMediaOptionsROIKey];

				NSString*string = @"";
				float max = 0.0;
				for (IDRSSignConfidenceCheck* Confidence in sings) {
					NSLog(@"lable:%@---confidence:%f",Confidence.label,Confidence.confidence);
					if (Confidence.confidence > max) {
						string = Confidence.label;
						max = Confidence.confidence;
					}
				}
				NSLog(@"签名xx--%@--%f",string,max);
				if ([string isEqualToString:@"hand"]&&max>0.7) {
					//                    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
				}
				self.operateResult.text = [NSString stringWithFormat:@"%@--%f",string,max];
			});

		}

		if (dataType == CAMERA_VIDEO) {
			CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
			IDRSFaceDetectParam *detectParam = [[IDRSFaceDetectParam alloc]init];
			detectParam.dataType = IDRSFaceDetectInputTypePixelBuffer;
			detectParam.buffer = pixelBuffer;
			detectParam.inputAngle = inAngle;
			detectParam.outputAngle = outAngle;
			// 采集人脸1：
			if (self.isPickFace1 == true || self.isPickFace2 == true) {
                detectParam.supportFaceRecognition = YES;
//                detectParam.supportFaceLiveness = YES;
				NSArray<FaceDetectionOutput *> *detectedFace = [_idrsSDK detectFace:detectParam];
				if (detectedFace!=nil && detectedFace.count > 0) {
					// 采集到了人脸
					if (self.isPickFace1 == true) {
						// 采集人脸1的feature
						_face1Feature = detectedFace[0].feature;
						dispatch_async(dispatch_get_main_queue(), ^{
							self.operateResult.text = @"取到人脸1";
						});
					} else if (self.isPickFace2 == true) {
						// 采集人脸2的feature
						_face2Feature = detectedFace[0].feature;
						dispatch_async(dispatch_get_main_queue(), ^{
							self.operateResult.text = @"取到人脸2";
						});
					}
				}
			}
		}

		// 人脸识别结果返回
		__weak __typeof(self) weakSelf = self;
		// 给录像数据
		[_idrsSDK getAudioVideoForRecord:sampleBuffer dataType:dataType];

		// 人脸追踪
		if(dataType == CAMERA_VIDEO) {
			CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);

			IDRSFaceDetectParam *detectParam = [[IDRSFaceDetectParam alloc]init];
			detectParam.dataType = IDRSFaceDetectInputTypePixelBuffer;
			detectParam.buffer = pixelBuffer;
			detectParam.inputAngle = inAngle;
			detectParam.outputAngle = outAngle;
			detectParam.supportFaceLiveness = YES;
            detectParam.supportFaceRecognition = YES;
            

			[_idrsSDK faceTrackFromVideo:detectParam faceDetectionCallback:^(NSError *error, NSArray<FaceDetectionOutput*> *faces) {
			         dispatch_async(dispatch_get_main_queue(), ^{
							if (error) {
								NSLog(@"%@", error.localizedDescription);
								return;
							}
							currentFaces = faces;
							if(faces.count > 0) {
								__unused FaceDetectionOutput *firstResult = [faces firstObject];
                                
//                                NSLog(@"--xx--xx--:%f",firstResult.pitch);
								//                        NSLog(@"faceid: %ld", (long)firstResult.faceId);
								//                        NSLog(@"face type: %d, %f", firstResult.livenessType, firstResult.livenessScore);
							}
                         
							if ([weakSelf.detectView isKindOfClass:NSClassFromString(@"FaceDetectView")]) {
								if (faces!=nil && faces.count>0 && weakSelf.face1Feature!=nil && weakSelf.face2Feature!=nil && weakSelf.isPickFace1 == false && weakSelf.isPickFace2 == false) {
									// 已经采集完照片
									for (FaceDetectionOutput *face in faces) {
										float score1 = [weakSelf.idrsSDK faceRecognitionSimilarity:face.feature feature2:weakSelf.face1Feature];
										float score2 =[weakSelf.idrsSDK faceRecognitionSimilarity:face.feature feature2:weakSelf.face2Feature];
										if (score1 > score2) {
											face.label = @"AAAAA";
										} else {
											face.label = @"BBBBB";
										}
									}
								}
								FaceDetectView *faceDetectView = (FaceDetectView*)weakSelf.detectView;
								faceDetectView.detectResult = faces;
							}
						});
			 }];
		}

		if(self.isIDCardOCR && dataType == CAMERA_VIDEO) {
			CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);

			IDRSIDCardDetectParam *detectParam = [[IDRSIDCardDetectParam alloc]init];
			detectParam.buffer = pixelBuffer;
			detectParam.dataType = IDRSIDCardInputTypePixelBuffer;

			NSArray<NSNumber*> *kXMediaOptionsROIKey = @[@(0.2),@(0.2),@(0.6),@(0.6)];

			BOOL isDetectFront = self.isIDCardBackOCR == NO ? YES : NO;
			NSLog(@"----%s----FrontIDCard:%s",self.isFrontCamera ? "Yes":"No",isDetectFront?"Yes":"No");
			IDCardDetectionOutput *ocrOutPut = [_idrsSDK detectIDCard:detectParam roiKey:kXMediaOptionsROIKey rotate:angleDic[@"outAngle"] isFrontCamera:self.isFrontCamera isDetectFrontIDCard:isDetectFront];
			if (ocrOutPut!=nil) {
				// 采集到了身份证信息
				dispatch_async(dispatch_get_main_queue(), ^{
					if(isDetectFront) {
						NSLog(@"身份证是：%@",ocrOutPut.num);
						self.operateResult.text = ocrOutPut.num;
					} else {
						self.operateResult.text = ocrOutPut.issue;
					}

				});
			}
			CFDictionaryRef metadataDict = CMCopyDictionaryOfAttachments(NULL,sampleBuffer, kCMAttachmentMode_ShouldPropagate);
			NSDictionary *metadata = [[NSMutableDictionary alloc] initWithDictionary:(__bridge NSDictionary*)metadataDict];
			CFRelease(metadataDict);
			NSDictionary *exifMetadata = [[metadata objectForKey:(NSString *)kCGImagePropertyExifDictionary] mutableCopy];
			float brightnessValue = [[exifMetadata objectForKey:(NSString *)kCGImagePropertyExifBrightnessValue] floatValue];
			if (brightnessValue != 0) {
				if (brightnessValue>dadahe) {
					dadahe = brightnessValue;
				}
				if (brightnessValue < heheda) {
					heheda = brightnessValue;
				}
				dispatch_async(dispatch_get_main_queue(), ^{
					self.operateResult1.text = [NSString stringWithFormat:@"最大:%f----最小:%f",dadahe,heheda];
				});
			}
		}

		if(self.isHandDet && dataType == CAMERA_VIDEO) {
			CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
			IDRSHandDetectParam *handParam = [[IDRSHandDetectParam alloc]init];
			handParam.dataType = IDRSHandInputTypeBGRA;
			handParam.buffer = pixelBuffer;
			handParam.outAngle = outAngle;

			NSArray<HandDetectionOutput *> *handResults = [_idrsSDK detectHandGesture:handParam];
			dispatch_async(dispatch_get_main_queue(), ^{
				if (handResults.count > 0) {
					// 判断签字主体
					for (HandDetectionOutput *handResult in handResults) {
						if(handResult.hand_phone_action == 1 || handResult.hand_phone_action == 2) {
							// 是签字
							CGRect handFace = handResult.face_rect;
							if(!CGRectIsNull(handFace)) {
								// 有脸框
								NSLog(@"face rect: %f %f", handFace.size.width, handFace.size.height);
								float overlapScore = 0;
								NSInteger faceId = 0;
								for (FaceDetectionOutput *face in currentFaces) {
									float score1 = [IDRSUtils computeHandOwner:handFace targetFace:face.rect];
									if(score1 > overlapScore) {
										overlapScore = score1;
										faceId = face.faceId;
									}
								}

								weakSelf.handDetectView.face_hand_score = overlapScore;
								if(overlapScore > 0.3) {
									// 匹配上了，展示当前脸部id
									NSLog(@"sign face id: %ld score：%f", faceId,overlapScore);
									dispatch_async(dispatch_get_main_queue(), ^{
										NSString *targetId = [NSString stringWithFormat:@"签字人%ld", (long)faceId];
										self.operateResult.text = targetId;
									});

								}
							}
						}

					}
					HandDetectView *handDetectView = (HandDetectView*)weakSelf.handDetectView;
					handDetectView.detectResult = handResults;
				}
			});
		}

		if(self.isStaticHandDet && dataType == CAMERA_VIDEO) {
			CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
			IDRSHandDetectParam *handParam = [[IDRSHandDetectParam alloc]init];
			handParam.dataType = IDRSHandInputTypeBGRA;
			handParam.buffer = pixelBuffer;
			handParam.outAngle = outAngle;

			NSArray<HandDetectionOutput *> *handResults = [_idrsSDK detectHandStaticGesture:handParam];
			dispatch_async(dispatch_get_main_queue(), ^{
				if (handResults.count > 0) {
					HandDetectView *handDetectView = (HandDetectView*)weakSelf.handDetectView;
					handDetectView.detectResult = handResults;
				}
			});
		}
	}
}

#pragma mark - ui
- (VideoBaseDetectView *)createDetectView {
	FaceDetectView *detectView = [[FaceDetectView alloc]init];
	detectView.isRTC = false;
	detectView.isRemoteWindow = false;
	return detectView;
}

- (VideoBaseDetectView *)createHandDetectView {
	HandDetectView *handDetectView = [[HandDetectView alloc]init];
	return handDetectView;
}

- (NSString *)getVideoName {
	NSTimeInterval now = [[NSDate date] timeIntervalSince1970];
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateStyle:NSDateFormatterMediumStyle];
	[formatter setTimeStyle:NSDateFormatterShortStyle];
	[formatter setDateFormat:@"MM_dd_HH_mm_ss"];
	[formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];

	NSDate *NowDate = [NSDate dateWithTimeIntervalSince1970:now];
	NSString *timeStr = [formatter stringFromDate:NowDate];
	NSString *fileName = [NSString stringWithFormat:@"video_%@.mp4", timeStr];
	return fileName;
}
- (NSString *)getVideoPathWithVideoName:(NSString*)videoName {
	NSString *videoCache = [NSTemporaryDirectory() stringByAppendingPathComponent:@"videos"];
	BOOL isDir = NO;
	NSFileManager *fileManager = [NSFileManager defaultManager];
	BOOL existed = [fileManager fileExistsAtPath:videoCache isDirectory:&isDir];
	if (!(isDir == YES && existed == YES)) {
		[fileManager createDirectoryAtPath:videoCache withIntermediateDirectories:YES attributes:nil error:nil];
	};
	NSString*path = [NSString stringWithFormat:@"%@/%@",videoCache,videoName];
	//    [videoCache stringByAppendingPathComponent:videoName];
	return path;
}
- (UIImage *) getImageFromCameraVideo: (CMSampleBufferRef)sampleBuffer {

	//制作 CVImageBufferRef
	CVImageBufferRef buffer;
	buffer = CMSampleBufferGetImageBuffer(sampleBuffer);

	CVPixelBufferLockBaseAddress(buffer, 0);

	//从 CVImageBufferRef 取得影像的细部信息
	uint8_t *base;
	size_t width, height, bytesPerRow;
	base = (unsigned char *)CVPixelBufferGetBaseAddress(buffer);
	width = CVPixelBufferGetWidth(buffer);
	height = CVPixelBufferGetHeight(buffer);
	bytesPerRow = CVPixelBufferGetBytesPerRow(buffer);

	//利用取得影像细部信息格式化 CGContextRef
	CGColorSpaceRef colorSpace;
	CGContextRef cgContext;
	colorSpace = CGColorSpaceCreateDeviceRGB();
	cgContext = CGBitmapContextCreate(base, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
	CGColorSpaceRelease(colorSpace);

	//透过 CGImageRef 将 CGContextRef 转换成 UIImage
	CGImageRef cgImage;
	UIImage *image;
	cgImage = CGBitmapContextCreateImage(cgContext);
	image = [UIImage imageWithCGImage:cgImage];
	CGImageRelease(cgImage);
	CGContextRelease(cgContext);

	CVPixelBufferUnlockBaseAddress(buffer, 0);

	UIImage *newimage = [UIImage imageWithCGImage:image.CGImage scale:1.0 orientation:UIImageOrientationUpMirrored];

	return newimage;
}

// 录像相关
- (void)onRecord:(UISwitch*)switcher {
	if (switcher.isOn) {
        [self showToastWith:@"demo录像需设置为横屏" duration:3];
		// 开始录像
		// 清空当前提示内容
		dispatch_async(dispatch_get_main_queue(), ^{
			self.operateResult.text = @"";
		});

		__weak __typeof(self) weakSelf = self;
		_idrsSDK.onRecordCallback = ^(NSString *result) {
		        dispatch_async(dispatch_get_main_queue(), ^{
				weakSelf.operateResult.text = result;
			});
		};


		NSString*filename = [self getVideoName];
		NSString*filepath = [self getVideoPathWithVideoName:filename];
		NSLog(@"文件地址：%@",filepath);
		[_idrsSDK startRecordWithFileName:filename andFilePath:filepath];
        NSString* metaFileName = [NSString stringWithFormat:@"%@.meta",filename];
        NSString* metaFilePath = [NSString stringWithFormat:@"%@.meta",filepath];
        
        [_idrsSDK startAddWord:@"同意"];
        [_idrsSDK endAddWord:@"同意"];
        [_idrsSDK startSegment:@"1"];
        [_idrsSDK startActionInSegment:@"1" actionName:@"id_card_recognize"];
        [_idrsSDK addSegment:@"1" andIDCard:@"12345432345432"];
        [_idrsSDK endActionInSegment:@"1" actionName:@"id_card_recognize"];
        [_idrsSDK endSegment:@"1"];
        [_idrsSDK startSegment:@"2"];
        [_idrsSDK startAddWord:@"清楚"];
        [_idrsSDK endAddWord:@"清楚"];
        [_idrsSDK endSegment:@"2"];
        [_idrsSDK startSegment:@"3"];
        [_idrsSDK startActionInSegment:@"3" actionName:@"action_recognize"];
        [_idrsSDK endActionInSegment:@"3" actionName:@"action_recognize"];
        [_idrsSDK endSegment:@"3"];
        [_idrsSDK saveMetaWithfileName:metaFileName andfilePath:metaFilePath];
        
	} else {
		// 停止录像
		[_idrsSDK stopRecord];
        
	}
}

#pragma mark - Toast error
-(void)showToastWith:(NSString*)text duration:(NSTimeInterval)duration{
    __weak FaceSDKDemoViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong FaceSDKDemoViewController *strongSelf = weakSelf;
        [strongSelf.navigationController.view makeToast:text duration:duration position:ARTVCToastPositionCenter];
    });
}


// nui相关
- (void)onNuiSwitch:(UISwitch*)switcher {
	if (switcher.isOn) {
		// 开始激活词
		[_idrsSDK startDialog];

	} else {
		// 停止激活词
		NSLog(@"停止激活词");
		[_idrsSDK stopDialog];
		dispatch_async(dispatch_get_main_queue(), ^{
			self->_operateResult.text = @"已停止";
		});

	}
}

// 采集脸一
- (void)onPickFace1Switch:(UISwitch*)switcher {
	//    NSString *bundlePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Resources.bundle"];
	//    for(int i = 1; i < 10; i++) {
	//        NSString *fileName = [NSString stringWithFormat:@"%d.JPG", i];
	//        NSString * scanImagePath = [bundlePath stringByAppendingPathComponent:fileName];
	//        UIImage *scanImage = [UIImage imageNamed:scanImagePath];
	//
	//        NSDictionary *angleDic = [self calculateInAndOutAngle];
	//        NSArray<FaceDetectionOutput *> *faces = [_faceSDK detectFaceFromImage:scanImage inAndOutAngle:angleDic];
	//        NSLog(@"type: %d, score: %f", faces[0].livenessType, faces[0].livenessScore);
	//    }


	if (switcher.isOn) {
		self.isPickFace1 = true;
	} else {
		self.isPickFace1 = false;
		dispatch_async(dispatch_get_main_queue(), ^{
			self.operateResult.text = @"";
		});
	}
}

// 采集脸二
- (void)onPickFace2Switch:(UISwitch*)switcher {
	if (switcher.isOn) {
		self.isPickFace2 = true;
	} else {
		self.isPickFace2 = false;
		dispatch_async(dispatch_get_main_queue(), ^{
			self.operateResult.text = @"";
		});
	}
}

// meta文件辅助测试
- (void)onAddSegmentSwitch:(UISwitch*)switcher {
	if (switcher.isOn) {
		_currentSegment = _currentSegment + 1;
		NSLog(@"current segment: %d", _currentSegment);
		NSString *stringInt = [NSString stringWithFormat:@"%d",_currentSegment];
		[_idrsSDK startSegment:stringInt];
		if (_currentSegment%2 == 0) {
			NSString *actionName = [NSString stringWithFormat:@"action%@",stringInt];
			[_idrsSDK startActionInSegment:stringInt actionName:actionName];
		}
	} else {
		NSString *stringInt = [NSString stringWithFormat:@"%d",_currentSegment];
		if (_currentSegment%2 == 0) {
			NSString *actionName = [NSString stringWithFormat:@"action%@",stringInt];
			[_idrsSDK endActionInSegment:stringInt actionName:actionName];
		}
		[_idrsSDK endSegment:stringInt];
	}
}

// 开启身份证OCR
- (void)onIDCardOCRSwitch:(UISwitch*)switcher {
	if (switcher.isOn) {
		self.isIDCardOCR = YES;
		_imageView.hidden = false;
	} else {
		self.isIDCardOCR = NO;
		_imageView.hidden = true;
	}
}

// 开启身份证背面OCR
- (void)onIDCardBackOCRSwitch:(UISwitch*)switcher {
	if (switcher.isOn) {
		self.isIDCardBackOCR = YES;
	} else {
		self.isIDCardBackOCR = NO;
	}
}

// 动态手势识别
- (void)onHandDetSwitch:(UISwitch*)switcher {
	if (switcher.isOn) {
		self.isHandDet = YES;
	} else {
		self.isHandDet = NO;
	}
}

// 静态手势识别
- (void)onStaticHandDetSwitch:(UISwitch*)switcher {
	if (switcher.isOn) {
		self.isStaticHandDet = YES;
	} else {
		self.isStaticHandDet = NO;
	}
}


// TTS语音合成
int ceshide = 0;
int xxxx=-1;
- (void)onTTSSwitch:(UISwitch*)switcher {
	if (switcher.isOn) {
//        [self playTTS:_arrTTSString[0]];
		xxxx++;
		if (xxxx>=_arrTTSString.count) {
			xxxx = 0;
		}
		self.isTTS = NO;
		[self playTTS:_arrTTSString[xxxx]];
	} else {
        [_idrsSDK stopTTS];
	}
}
int xxxxx = 0;
- (void)playTTS:(NSString*)content {
    
	NSLog(@"下角标： 原数据字数：%lu",(unsigned long)content.length);
	__unused __weak __typeof(self) weakSelf = self;
//    self.voicePlayer.onTTSPlayerEventCallback = ^(enum TTSPlayerEvent event) {
//        if(event==TTSPlayer_EVENT_DRAINING){
//            if (weakSelf.ttsArray.count>weakSelf.arrayIndex+1&&weakSelf.isTTS) {
//                weakSelf.arrayIndex++;
//                NSLog(@"测试---走了分段方法%ld",(long)weakSelf.arrayIndex);
//                [weakSelf.idrsSDK startTTS:"1" taskId:"" text:[weakSelf.ttsArray[weakSelf.arrayIndex] UTF8String]];
//                NSLog(@"tts分段第%ld次",(long)weakSelf.arrayIndex);
//            }
//        }else if(event==TTSPlayer_EVENT_CLEAN){
//            NSLog(@"注销了TTSPlayer");
//        }else if (event == TTSPlayer_EVENT_ERROR){
//            NSLog(@"错误");
//        }
//        NSLog(@"测试--TTSPlayer操作 %u",event);
//    };

//    content = ;
	NSString* text = @"";
//    if (content.length > 0){
//        self.ttsArray = [[NSMutableArray alloc] init];
//        self.titleIndex = 0;
//        self.arrayIndex = 0;
//        //去特殊符号
//        NSMutableArray *temp = [NSMutableArray arrayWithArray:[content componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"[](){}（）【】「」\t\n\r"]]];
//        //        [temp removeObject:@""];
//        if (temp.count >= 2) {
//            content = @"";
//            for (NSString *string in temp) {
//                content = [content stringByAppendingString:string];
//            }
//        }
//        //分段
//        NSMutableArray *tempArray = [NSMutableArray arrayWithArray:[content componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"?;!，。；？、！"]]];
//        [tempArray removeObject:@""];
//        NSLog(@"wokankna: %@",tempArray);
////        self.ttsArray = [[NSMutableArray alloc] initWithArray:tempArray];
////        text = self.ttsArray[_arrayIndex];
//    }else{
    
    text = content;// @"我是一个个啊哈撒谎.②，张三可以说错话②，驾驶汽车的人不是我②双人床不能一个人睡②对于我来说②个人账户累计 这个可以通过模型侧来解决。预计9月中旬发版就可以解决。2.（2）个问题建议还是微调一下输入过滤的程序。我看了一下以前的聊天记录，目前去掉括号仅仅是为了解决一个case（人寿健康保险型（（A1）款））。那就可以只把“（A）”替换成A就可以了（我这边测试了其他字母，字母+数字是没问题的）。保险期间为  10年。";
    //content;//@"我是  786更改感觉   是谁";//连续空格，超过三个按三个下角标返回
    text = @"您所购买的是爱心人寿的保险产品。\n(双录)爱心人寿守护神2.0终身寿险-经代这份保险缴费方式为年缴，每年缴费一次， 每期保费5000.00元，缴费期1年，保险期间一年。请问我说清楚了吗？\n\n请回答：好的，清楚，明白，是的，同意，ok";
    [[scollLabelView shareManager] setTextViewWithString:text];
    
    self.isTTS = YES;
	self.isPaused = false;
	[_idrsSDK setTTSParam:@"speed_level" value:@"1.2"];
	[_idrsSDK startTTSWithText:text];
    //自动暂停  5.0与4.8
//    [NSTimer scheduledTimerWithTimeInterval:5.0f repeats:true block:^(NSTimer * _Nonnull timer) {
//        [self->_ttsPauseSwitch setOn:true];
//        [self onTTSPauseSwitch:self->_ttsPauseSwitch];
//    }];
//    [NSTimer scheduledTimerWithTimeInterval:6.0f repeats:true block:^(NSTimer * _Nonnull timer) {
//        [self->_ttsPauseSwitch setOn:false];
//        [self onTTSPauseSwitch:self->_ttsPauseSwitch];
//    }];
}
-(void)createFileWithContent:(NSData*)content {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	NSString * path = [NSString stringWithFormat:@"%@/%@",documentsDirectory,@"ceshi.pcm"];
	NSFileManager *fileManager = [NSFileManager defaultManager];

	if (![fileManager fileExistsAtPath:path]) {
		BOOL res=[fileManager createFileAtPath:path contents:nil attributes:nil];
		NSLog(@"ceshi文件创建：%@",res?@"成功":@"失败");
	}else{
		NSLog(@"test文件已存在");
	}
	[self baocun:path content:content];
}
-(void)baocun:(NSString*)path content:(NSData*)cont {
	NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:path];
	[fileHandle seekToEndOfFile];
	[fileHandle writeData:cont];
	[fileHandle closeFile];
}
- (void)onTTSPauseSwitch:(UISwitch*)switcher {
	if (switcher.isOn) {
        [self.idrsSDK pauseTTS];
        self.isPaused = true;
//        [_voicePlayer pause];
        
	} else {
		self.isPaused = false;
		[self.idrsSDK resumeTTS];
//        [_voicePlayer resume];
	}
}

- (void)onSignSwitch:(UISwitch*)switcher {
	if (switcher.isOn) {
		_isSign = true;
		_greenpick.hidden = false;
	} else {
		_isSign = false;
		_greenpick.hidden = true;
	}
}
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
- (void)recordBtnClicked {
//    [RPScreenRecorder sharedRecorder].microphoneEnabled = YES;
//    [[RPScreenRecorder sharedRecorder] startCaptureWithHandler:^(CMSampleBufferRef  _Nonnull sampleBuffer, RPSampleBufferType bufferType, NSError * _Nullable error) {
//
//    } completionHandler:^(NSError * _Nullable error) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            if ([[RPScreenRecorder sharedRecorder] isRecording] == NO) {
////                !handler ?: handler(@"开启录屏失败");
//                return;
//            }
//
//            if (error) {
////                !handler ?: handler(@"开启录屏失败");
//            } else if ([RPScreenRecorder sharedRecorder].isMicrophoneEnabled == NO) {
//                [[RPScreenRecorder sharedRecorder] stopCaptureWithHandler:^(NSError * _Nullable error) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
////                        !handler ?: handler(@"请重新开始，选择”录屏与麦克风“");
//                    });
//                }];
//            } else {
//                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////                    !handler ?: handler(nil);
//
//                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////                        [self initVideoWriter];
////                        self.didStart = YES;
//                    });
//                });
//            }
//        });
//    }];
}
@end

