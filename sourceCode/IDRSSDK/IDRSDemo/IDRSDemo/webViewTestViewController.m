//
//  webViewTestViewController.m
//  IDRSDemo
//
//  Created by 崔海斌 on 2021/5/19.
//  Copyright © 2021 cuixling. All rights reserved.
//

#import "webViewTestViewController.h"
#import <WebKit/WebKit.h>
#import <IDRSSDK/IDRSSDK.h>

#define KSCRW    [UIScreen mainScreen].bounds.size.width
#define KSCRH   [UIScreen mainScreen].bounds.size.height

#define KTABH 49.f

#define NavH    (KSCRH>=812 ? 88.:64.)

@interface webViewTestViewController ()<
	WKNavigationDelegate
	>
@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) IDRSSDK *idrsSDK;
@end

@implementation webViewTestViewController

- (void)viewDidLoad {
	[super viewDidLoad];
	// Do any additional setup after loading the view.
	_idrsSDK = [IDRSSDK init];
	if (_idrsSDK == nil) {
		NSLog(@"过期了");
	}
	[self setWebView];
	[self viewInit];

}
-(void)viewInit {
	UILabel* ttsLabel = [[UILabel alloc]initWithFrame:CGRectMake(10, 100, 50, 40)];
	ttsLabel.textColor = [UIColor redColor];
	ttsLabel.text = @"TTS";
	[self.view addSubview:ttsLabel];
	UISwitch *ttsSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(CGRectGetMaxX(ttsLabel.frame), 100, 100, 40)];
	[self.view addSubview:ttsSwitch];
	[ttsSwitch addTarget:self action:@selector(onTTSSwitch:) forControlEvents:UIControlEventValueChanged];
}
- (void)onTTSSwitch:(UISwitch*)switcher {
	if (switcher.isOn) {
		[_idrsSDK stopTTS];
		[self playTTS:@""];
	} else {
		[_idrsSDK stopTTS];
		[self playTTS:@""];
	}
}
- (void)playTTS:(NSString*)content {
	__weak __typeof(self) weakSelf = self;
	_idrsSDK.onNuiTTSEventCallback = ^(enum ISDRTtsEvent event) {
		NSLog(@"tts callback in app: %u", event);
		if (event == ISDR_TTS_EVENT_START) {

		} else if (event == ISDR_TTS_EVENT_END) {

		}
	};
	_idrsSDK.onNuiTTSDataCallback = ^(char *text, int word_idx, char *buffer, int len, char *taskid) {
		NSLog(@"tts onNuiTTSDataCallback word_idx in app: %d", word_idx);
	};
	self.idrsSDK.onIDRSTTSPlayerEventCallback = ^(enum IDRSTTSPlayerEvent event) {
		NSLog(@"onIDRSTTSPlayerEventCallback ---- %d",event);
		switch (event) {
		case IDRS_TTSPlayer_EVENT_DRAINING:

			break;
		default:
			break;
		}
	};
	NSString *text = @"10.出示产品说明书、保险条款，并请投保人阅读  \n这分别是保险产品说明书（限人身保险新型产品使用）、保险条款，为保障您的权益，请您认真阅读";
	[_idrsSDK setTTSParam:"speed_level" value:"1.5"];
	[_idrsSDK startTTS:"1" taskId:"" text:[text UTF8String]];
}
- (WKWebView *)webView {
	if (nil == _webView) {

		WKWebViewConfiguration *config = [WKWebViewConfiguration new];
		//初始化偏好设置属性：preferences
		config.preferences = [WKPreferences new];
		//The minimum font size in points default is 0;
		config.preferences.minimumFontSize = 10;
		//是否支持JavaScript
		config.preferences.javaScriptEnabled = YES;
		//不通过用户交互，是否可以打开窗口
		config.preferences.javaScriptCanOpenWindowsAutomatically = NO;

		_webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, NavH, KSCRW, KSCRH-NavH) configuration:config];
		_webView.backgroundColor = [UIColor lightGrayColor];
		[self.view addSubview:_webView];
		_webView.navigationDelegate = self;
	}
	return _webView;
}
-(void)setWebView {
	NSURL *url = [NSURL URLWithString:@"https://www.baidu.com"];
	NSURLRequest *request = [NSURLRequest requestWithURL:url];
	[self.webView loadRequest:request];
}
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
	NSLog(@"Did Start Load");
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
	NSLog(@"Did Finish Load");
}
- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
	NSLog(@"Did Fail Load With Error:\n%@",error);
}

@end
