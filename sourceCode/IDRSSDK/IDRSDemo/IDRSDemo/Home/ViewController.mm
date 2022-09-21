#import "ViewController.h"
#import "DemoTableViewCell.h"
#import "ProRemoteViewController.h"
#import "DemoSettingVC.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSArray *dataList;

@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];
    
    UIImage* settingImage = [UIImage imageNamed:@"tab_settings"];
    UIBarButtonItem *setting = [[UIBarButtonItem alloc] initWithImage:settingImage style:UIBarButtonItemStylePlain target:self action:@selector(presentSettingController)];
    [self.navigationItem setRightBarButtonItem:setting];

	_tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	_tableView.delegate = self;
	_tableView.dataSource = self;
	_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	[self.view addSubview:_tableView];
    
    _dataList = @[@{@"title":@"远程双录SDKDemo", @"page":@"ProRemoteViewController"},@{@"title":@"双录原子能力", @"page":@"FaceSDKDemoViewController"},@{@"title":@"本地流程SDKDemo", @"page":@"MPProDemoViewController"}];

}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
	return 75;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        [self remoteRecordAlert];
    }else {
        NSString *vcName = [_dataList[indexPath.row] valueForKey:@"page"];
        [self.navigationController pushViewController:[NSClassFromString(vcName) new] animated:YES];
    }
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

	return _dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {


	DemoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cellId"];
	if (cell==nil) {
		cell = [[DemoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cellId"];
	}

	cell.dataDic = _dataList[indexPath.row];

	return cell;
}

- (void)remoteRecordAlert {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"创建或者加入房间" message:nil preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(alert) weakAlert = alert;
    UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"加入房间" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ProRemoteViewController *remoteVC = [[ProRemoteViewController alloc] init];
        NSArray *tfArray = weakAlert.textFields;
        remoteVC.roomId =  ((UITextField *)tfArray[0]).text;
        remoteVC.rtoken = ((UITextField *)tfArray[1]).text;
        [self.navigationController pushViewController:remoteVC animated:YES];
    }];
    UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"创建房间" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        ProRemoteViewController *remoteVC = [[ProRemoteViewController alloc] init];
        [self.navigationController pushViewController:remoteVC animated:YES];
    }];
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {}];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {}];
    [self.navigationController presentViewController:alert animated:YES completion:nil];

}

- (void)presentSettingController {
    DemoSettingVC *settingVc = [[DemoSettingVC alloc] init];
    [self.navigationController pushViewController:settingVc animated:YES];
}

@end

