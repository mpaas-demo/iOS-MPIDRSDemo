//
//  DemoSettingVC.m
//  DemoSettingVC
//
//  Created by shaochangying.scy on 2021/11/23.
//  Copyright © 2021 Alipay. All rights reserved.
//

#define DemoLeftPadding 8

#import "DemoSettingVC.h"
#import "DemoSetting.h"

@interface DemoSettingVC ()<UITextViewDelegate,UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, strong) UITextField *processIdField;

@property (nonatomic, strong) UITextField *userIdField;

@property (nonatomic, strong) UITextField *watermarkIdField;

@property (nonatomic, strong) UITextField *appIdField;

@property (nonatomic, strong) UITextField *packageNameField;

@property (nonatomic, strong) UITextField *akField;

@property (nonatomic, strong) UITextField *skField;

@property (nonatomic, strong) NSMutableArray *photosArr;

@property (nonatomic, strong) NSMutableArray *namesArr;

@property (nonatomic, strong) UILabel *numLabel;

@property (nonatomic, strong) UILabel *nameNumLabel;

@property (nonatomic, strong) UITextField *nameField;

@property (nonatomic, strong) UITextField *rtcUrlField;

@property (nonatomic, strong) UITextField *serverUrlField;

@end

@implementation DemoSettingVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.processIdField];
    [self.scrollView addSubview:self.userIdField];
    [self.scrollView addSubview:self.watermarkIdField];
    [self.scrollView addSubview:self.appIdField];
    [self.scrollView addSubview:self.packageNameField];
    [self.scrollView addSubview:self.akField];
    [self.scrollView addSubview:self.skField];
    [self.scrollView addSubview:self.numLabel];
    [self.scrollView addSubview:self.nameNumLabel];
    [self.scrollView addSubview:self.nameField];
    [self.scrollView addSubview:self.rtcUrlField];
    [self.scrollView addSubview:self.serverUrlField];
//    [self.scrollView addSubview:self.photosArr];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [DemoSetting sharedInstance].processId = self.processIdField.text;
    [DemoSetting sharedInstance].userId = self.userIdField.text;
    [DemoSetting sharedInstance].watermarkId = self.watermarkIdField.text;
    [DemoSetting sharedInstance].appId = self.appIdField.text;
    [DemoSetting sharedInstance].packageName = self.packageNameField.text;
    [DemoSetting sharedInstance].ak = self.akField.text;
    [DemoSetting sharedInstance].sk = self.skField.text;
    [DemoSetting sharedInstance].photos = self.photosArr;
    [DemoSetting sharedInstance].names = self.namesArr;
//    [DemoSetting sharedInstance].rtcUrl = self.rtcUrlField.text;
//    [DemoSetting sharedInstance].serverUrl = self.serverUrlField.text;
    [[DemoSetting sharedInstance] saveData];
}

//MARK: UITextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}


//MARK: UITextView Delegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (UITextField *)processIdField
{
    if (!_processIdField) {
        CGFloat left = DemoLeftPadding;
        CGFloat top = left;
        UILabel *processIdLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, top, 88, 44)];
        processIdLabel.text = @"processId:";
        [self.scrollView addSubview:processIdLabel];
        CGFloat width = CGRectGetMaxX(processIdLabel.frame);
        _processIdField = [[UITextField alloc] initWithFrame:CGRectMake(width+8, top, self.scrollView.frame.size.width - width - left * 2, 44)];
        _processIdField.layer.cornerRadius = 10;
        _processIdField.layer.borderColor = [UIColor grayColor].CGColor;
        _processIdField.layer.borderWidth = 0.5;
        _processIdField.returnKeyType = UIReturnKeyDone;
        _processIdField.adjustsFontSizeToFitWidth = YES;
        _processIdField.delegate = self;
        _processIdField.text = [DemoSetting sharedInstance].processId;
    }
    return _processIdField;
}

- (UITextField *)userIdField
{
    if (!_userIdField) {
        CGFloat left = DemoLeftPadding;
        CGFloat top = CGRectGetMaxY(self.processIdField.frame) + left;
        UILabel *userIdLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, top, 88, 44)];
        userIdLabel.text = @"userId:";
        [self.scrollView addSubview:userIdLabel];
        CGFloat width = CGRectGetMaxX(userIdLabel.frame);
        _userIdField = [[UITextField alloc] initWithFrame:CGRectMake(width+8, top, self.scrollView.frame.size.width - width - left * 2, 44)];
        _userIdField.layer.cornerRadius = 10;
        _userIdField.layer.borderColor = [UIColor grayColor].CGColor;
        _userIdField.layer.borderWidth = 0.5;
        _userIdField.returnKeyType = UIReturnKeyDone;
        _userIdField.adjustsFontSizeToFitWidth = YES;
        _userIdField.delegate = self;
        _userIdField.text = [DemoSetting sharedInstance].userId;
    }
    return _userIdField;
}

- (UITextField *)watermarkIdField
{
    if (!_watermarkIdField) {
        CGFloat left = DemoLeftPadding;
        CGFloat top = CGRectGetMaxY(self.userIdField.frame) + left;
        UILabel *watermarkIdLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, top, 100, 44)];
        watermarkIdLabel.text = @"watermarkId:";
        [self.scrollView addSubview:watermarkIdLabel];
        CGFloat width = CGRectGetMaxX(watermarkIdLabel.frame);
        _watermarkIdField = [[UITextField alloc] initWithFrame:CGRectMake(width+8, top, self.scrollView.frame.size.width - width - left * 2, 44)];
        _watermarkIdField.layer.cornerRadius = 10;
        _watermarkIdField.layer.borderColor = [UIColor grayColor].CGColor;
        _watermarkIdField.layer.borderWidth = 0.5;
        _watermarkIdField.returnKeyType = UIReturnKeyDone;
        _watermarkIdField.adjustsFontSizeToFitWidth = YES;
        _watermarkIdField.delegate = self;
        _watermarkIdField.text = [DemoSetting sharedInstance].watermarkId;
    }
    return _watermarkIdField;
}

- (UITextField *)appIdField
{
    if (!_appIdField) {
        CGFloat left = DemoLeftPadding;
        CGFloat top = CGRectGetMaxY(self.watermarkIdField.frame) + left;
        UILabel *appIdLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, top, 48, 44)];
        appIdLabel.text = @"appId:";
        [self.scrollView addSubview:appIdLabel];
        CGFloat width = CGRectGetMaxX(appIdLabel.frame);
        _appIdField = [[UITextField alloc] initWithFrame:CGRectMake(width+8, top, self.scrollView.frame.size.width - width - left * 2, 44)];
        _appIdField.layer.cornerRadius = 10;
        _appIdField.layer.borderColor = [UIColor grayColor].CGColor;
        _appIdField.layer.borderWidth = 0.5;
        _appIdField.adjustsFontSizeToFitWidth = YES;
        _appIdField.returnKeyType = UIReturnKeyDone;
        _appIdField.delegate = self;
        _appIdField.text = [DemoSetting sharedInstance].appId;
    }
    return _appIdField;
}

- (UITextField *)packageNameField
{
    if (!_packageNameField) {
        CGFloat left = DemoLeftPadding;
        CGFloat top = CGRectGetMaxY(self.appIdField.frame) + left;
        UILabel *packageNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, top, 120, 44)];
        packageNameLabel.text = @"packageName:";
        [self.scrollView addSubview:packageNameLabel];
        CGFloat width = CGRectGetMaxX(packageNameLabel.frame);
        _packageNameField = [[UITextField alloc] initWithFrame:CGRectMake(width+8, top, self.scrollView.frame.size.width - width - left * 2, 44)];
        _packageNameField.layer.cornerRadius = 10;
        _packageNameField.layer.borderColor = [UIColor grayColor].CGColor;
        _packageNameField.layer.borderWidth = 0.5;
        _packageNameField.adjustsFontSizeToFitWidth = YES;
        _packageNameField.returnKeyType = UIReturnKeyDone;
        _packageNameField.delegate = self;
        _packageNameField.text = [DemoSetting sharedInstance].packageName;
    }
    return _packageNameField;
}

- (UITextField *)akField
{
    if (!_akField) {
        CGFloat left = DemoLeftPadding;
        CGFloat top = CGRectGetMaxY(self.packageNameField.frame) + left;
        UILabel *akLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, top, 32, 44)];
        akLabel.text = @"ak:";
        [self.scrollView addSubview:akLabel];
        CGFloat width = CGRectGetMaxX(akLabel.frame);
        _akField = [[UITextField alloc] initWithFrame:CGRectMake(width+8, top, self.scrollView.frame.size.width - width - left * 2, 44)];
        _akField.layer.cornerRadius = 10;
        _akField.layer.borderColor = [UIColor grayColor].CGColor;
        _akField.layer.borderWidth = 0.5;
        _akField.adjustsFontSizeToFitWidth = YES;
        _akField.returnKeyType = UIReturnKeyDone;
        _akField.delegate = self;
        _akField.text = [DemoSetting sharedInstance].ak;
    }
    return _akField;
}

- (UITextField *)skField
{
    if (!_skField) {
        CGFloat left = DemoLeftPadding;
        CGFloat top = CGRectGetMaxY(self.akField.frame) + left;
        UILabel *skLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, top, 32, 44)];
        skLabel.text = @"sk:";
        [self.scrollView addSubview:skLabel];
        CGFloat width = CGRectGetMaxX(skLabel.frame);
        _skField = [[UITextField alloc] initWithFrame:CGRectMake(width+8, top, self.scrollView.frame.size.width - width - left * 2, 44)];
        _skField.layer.cornerRadius = 10;
        _skField.layer.borderColor = [UIColor grayColor].CGColor;
        _skField.layer.borderWidth = 0.5;
        _skField.adjustsFontSizeToFitWidth = YES;
        _skField.returnKeyType = UIReturnKeyDone;
        _skField.delegate = self;
        _skField.text = [DemoSetting sharedInstance].sk;
    }
    return _skField;
}

- (UITextField *)rtcUrlField
{
    if (!_rtcUrlField) {
        CGFloat left = DemoLeftPadding;
        CGFloat top = CGRectGetMaxY(self.skField.frame) + left;
        UILabel *skLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, top, 50, 44)];
        skLabel.adjustsFontSizeToFitWidth = YES;
        skLabel.text = @"rtcUrl:";
        [self.scrollView addSubview:skLabel];
        CGFloat width = CGRectGetMaxX(skLabel.frame);
        _rtcUrlField = [[UITextField alloc] initWithFrame:CGRectMake(width+8, top, self.scrollView.frame.size.width - width - left * 2, 44)];
        _rtcUrlField.layer.cornerRadius = 10;
        _rtcUrlField.layer.borderColor = [UIColor grayColor].CGColor;
        _rtcUrlField.layer.borderWidth = 0.5;
        _rtcUrlField.adjustsFontSizeToFitWidth = YES;
        _rtcUrlField.returnKeyType = UIReturnKeyDone;
        _rtcUrlField.delegate = self;
//        _rtcUrlField.text = [DemoSetting sharedInstance].rtcUrl;
    }
    return _rtcUrlField;
}
- (UITextField *)serverUrlField
{
    if (!_serverUrlField) {
        CGFloat left = DemoLeftPadding;
        CGFloat top = CGRectGetMaxY(self.rtcUrlField.frame) + left;
        UILabel *skLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, top, 50, 44)];
        skLabel.adjustsFontSizeToFitWidth = YES;
        skLabel.text = @"serverUrl:";
        [self.scrollView addSubview:skLabel];
        CGFloat width = CGRectGetMaxX(skLabel.frame);
        _serverUrlField = [[UITextField alloc] initWithFrame:CGRectMake(width+8, top, self.scrollView.frame.size.width - width - left * 2, 44)];
        _serverUrlField.layer.cornerRadius = 10;
        _serverUrlField.layer.borderColor = [UIColor grayColor].CGColor;
        _serverUrlField.layer.borderWidth = 0.5;
        _serverUrlField.adjustsFontSizeToFitWidth = YES;
        _serverUrlField.returnKeyType = UIReturnKeyDone;
        _serverUrlField.delegate = self;
//        _serverUrlField.text = [DemoSetting sharedInstance].serverUrl;
    }
    return _serverUrlField;
}

- (UILabel *)numLabel
{
    if (!_numLabel) {
        CGFloat left = DemoLeftPadding;
        CGFloat top = CGRectGetMaxY(self.serverUrlField.frame) + left;
        _numLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, top, 200, 44)];
        _numLabel.text = [NSString stringWithFormat:@"当前有%lu张图片",(unsigned long)self.photosArr.count];
        CGFloat width = CGRectGetMaxX(_numLabel.frame);
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(width+8, top, self.scrollView.frame.size.width - width - left * 2, 44)];
        [button setTitle:@"点击添加人脸" forState:UIControlStateNormal];
        button.backgroundColor = [UIColor grayColor];
        button.layer.cornerRadius = 10;
        button.layer.borderColor = [UIColor grayColor].CGColor;
        button.layer.borderWidth = 0.5;
        [button addTarget:self action:@selector(choseImage) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:button];
        top = CGRectGetMaxY(button.frame) + left;
        UIButton *xxd = [[UIButton alloc] initWithFrame:CGRectMake(width+8, top, self.scrollView.frame.size.width - width - left * 2, 44)];
        [xxd setTitle:@"重置人脸照片" forState:UIControlStateNormal];
        xxd.backgroundColor = [UIColor grayColor];
        xxd.layer.cornerRadius = 10;
        xxd.layer.borderColor = [UIColor grayColor].CGColor;
        xxd.layer.borderWidth = 0.5;
        [xxd addTarget:self action:@selector(clearArr) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:xxd];
    }
    return _numLabel;
}
- (UILabel *)nameNumLabel
{
    if (!_nameNumLabel) {
        CGFloat left = DemoLeftPadding;
        CGFloat top = CGRectGetMaxY(self.numLabel.frame) + left * 2 + 44;
        _nameNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(left, top, 200, 44)];
        _nameNumLabel.text = [NSString stringWithFormat:@"当前有%lu个人名",(unsigned long)self.namesArr.count];
        CGFloat width = CGRectGetMaxX(_nameNumLabel.frame);
        UIButton *xxd = [[UIButton alloc] initWithFrame:CGRectMake(width+8, top, self.scrollView.frame.size.width - width - left * 2, 44)];
        [xxd setTitle:@"重置人名" forState:UIControlStateNormal];
        xxd.backgroundColor = [UIColor grayColor];
        xxd.layer.cornerRadius = 10;
        xxd.layer.borderColor = [UIColor grayColor].CGColor;
        xxd.layer.borderWidth = 0.5;
        [xxd addTarget:self action:@selector(clearName) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:xxd];
    }
    return _nameNumLabel;
}

- (UITextField *)nameField
{
    if (!_nameField) {
        CGFloat left = DemoLeftPadding;
        CGFloat top = CGRectGetMaxY(self.nameNumLabel.frame) + left;
        _nameField = [[UITextField alloc] initWithFrame:CGRectMake(left, top, 200, 44)];
        _nameField.layer.cornerRadius = 10;
        _nameField.layer.borderColor = [UIColor grayColor].CGColor;
        _nameField.layer.borderWidth = 0.5;
        _nameField.adjustsFontSizeToFitWidth = YES;
        _nameField.returnKeyType = UIReturnKeyDone;
        _nameField.delegate = self;
        _nameField.placeholder = @"填写人名后点击右侧按钮";
        CGFloat width = CGRectGetMaxX(_nameField.frame);
        UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(width+8, top, self.scrollView.frame.size.width - width - left * 2, 44)];
        [button setTitle:@"点击添加人名" forState:UIControlStateNormal];
        button.backgroundColor = [UIColor grayColor];
        button.layer.cornerRadius = 10;
        button.layer.borderColor = [UIColor grayColor].CGColor;
        button.layer.borderWidth = 0.5;
        [button addTarget:self action:@selector(addName) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:button];
    }
    return _nameField;
}

- (NSMutableArray *)photosArr
{
    if (!_photosArr) {
        NSArray *arr = [DemoSetting sharedInstance].photos;
        if (arr && arr.count > 0) {
            _photosArr = [NSMutableArray arrayWithArray:arr];
        }else{
            _photosArr = [NSMutableArray array];
        }
    }
    return _photosArr;
}

- (NSMutableArray *)namesArr
{
    if (!_namesArr) {
        NSArray *arr = [DemoSetting sharedInstance].names;
        if (arr && arr.count > 0) {
            _namesArr = [NSMutableArray arrayWithArray:arr];
        }else{
            _namesArr = [NSMutableArray array];
        }
    }
    return _namesArr;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, self.view.bounds.size.height*2);
        _scrollView.backgroundColor = [UIColor whiteColor];
        _scrollView.scrollEnabled = YES;
        _scrollView.alwaysBounceVertical = YES;
    }
    return _scrollView;
}

- (void)clearArr
{
    self.photosArr = [[NSMutableArray alloc] init];
    self.numLabel.text = [NSString stringWithFormat:@"当前有%lu张图片",(unsigned long)self.photosArr.count];
}
- (void)clearName
{
    self.namesArr = [[NSMutableArray alloc] init];
    self.nameNumLabel.text = [NSString stringWithFormat:@"当前有%lu个人名",(unsigned long)self.namesArr.count];
}

- (void)addName
{
    [self.namesArr addObject:self.nameField.text];
    self.nameNumLabel.text = [NSString stringWithFormat:@"当前有%lu个人名",(unsigned long)self.namesArr.count];
}

- (void)choseImage
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    imagePicker.delegate = self;
    [self presentViewController:imagePicker animated:true completion:nil];
}

#pragma mark -- UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info{
    
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    UIImageOrientation imageOrientation=image.imageOrientation;
    if(imageOrientation!=UIImageOrientationUp)
    {
        // 原始图片可以根据照相时的角度来显示，但UIImage无法判定，于是出现获取的图片会向左转９０度的现象。
        // 以下为调整图片角度的部分
        UIGraphicsBeginImageContext(image.size);
        [image drawInRect:CGRectMake(0, 0, image.size.width, image.size.height)];
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        // 调整图片角度完毕
    }
    
    NSData *imageData = UIImagePNGRepresentation(image);
    [self.photosArr addObject:imageData];
    self.numLabel.text = [NSString stringWithFormat:@"当前有%lu张图片",(unsigned long)self.photosArr.count];
    [picker dismissViewControllerAnimated:true completion:nil];
}

@end

