//
//  LJNavigationBarTestViewController.m
//  Lianjia_Beike_Home
//
//  Created by 赵文成 on 2019/4/2.
//

#define kNavBarHeight ([[UIApplication sharedApplication] statusBarFrame].size.height + 69.0)

#import "LJNavigationBarTestViewController.h"
#import "LJNavigationBar.h"
#import "LJSwitchMenuView.h"

@interface LJNavigationBarTestViewController ()<LJNavigationBarDelegate, LJSwitchMenuViewDelegate, UITextFieldDelegate>

@property (nonatomic, strong) LJNavigationBar *navBar;
@property (nonatomic, strong) LJSwitchMenuView *switchMenuView;
@property (nonatomic, assign) NSInteger type;
@property (nonatomic, strong) UITextField *cityTextField;
@property (nonatomic, strong) UITextField *switchTextField;
@property (nonatomic, strong) UITextField *defaultTextField;
@property (nonatomic, strong) UITextField *functionTextField;

@end

@implementation LJNavigationBarTestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];

    _type = 0;
    
    [self setupNavBar:_type inputType:0];
    
    UIButton *changeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    changeButton.frame = CGRectMake(250, 100, 100, 50);
    changeButton.backgroundColor = [UIColor redColor];
    [changeButton setTitle:@"切换模式" forState:UIControlStateNormal];
    [changeButton addTarget:self action:@selector(clickChangeButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:changeButton];
    
    UIButton *redDotButton = [UIButton buttonWithType:UIButtonTypeCustom];
    redDotButton.frame = CGRectMake(250, 200, 100, 50);
    redDotButton.backgroundColor = [UIColor redColor];
    [redDotButton setTitle:@"控制红点" forState:UIControlStateNormal];
    [redDotButton addTarget:self action:@selector(clickRedDotButton:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:redDotButton];
    
    _cityTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 300, 200, 50)];
    _cityTextField.font = [UIFont systemFontOfSize:16];
    _cityTextField.textColor = [UIColor F1Color];
    _cityTextField.borderStyle = UITextBorderStyleRoundedRect;
    _cityTextField.backgroundColor = [UIColor clearColor];
    _cityTextField.returnKeyType = UIReturnKeyDone;
    _cityTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _cityTextField.delegate = self;
    [self.view addSubview:_cityTextField];
    
    UIButton *cityButton = [UIButton buttonWithType:UIButtonTypeCustom];
    cityButton.frame = CGRectMake(250, 300, 100, 50);
    cityButton.backgroundColor = [UIColor redColor];
    [cityButton setTitle:@"城市区" forState:UIControlStateNormal];
    [cityButton addTarget:self action:@selector(cityButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:cityButton];
    
    _switchTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 400, 200, 50)];
    _switchTextField.font = [UIFont systemFontOfSize:16];
    _switchTextField.textColor = [UIColor F1Color];
    _switchTextField.borderStyle = UITextBorderStyleRoundedRect;
    _switchTextField.backgroundColor = [UIColor clearColor];
    _switchTextField.returnKeyType = UIReturnKeyDone;
    _switchTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _switchTextField.delegate = self;
    [self.view addSubview:_switchTextField];
    
    UIButton *switchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    switchButton.frame = CGRectMake(250, 400, 100, 50);
    switchButton.backgroundColor = [UIColor redColor];
    [switchButton setTitle:@"切换区" forState:UIControlStateNormal];
    [switchButton addTarget:self action:@selector(switchButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:switchButton];
    
    _defaultTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 500, 200, 50)];
    _defaultTextField.font = [UIFont systemFontOfSize:16];
    _defaultTextField.textColor = [UIColor F1Color];
    _defaultTextField.borderStyle = UITextBorderStyleRoundedRect;
    _defaultTextField.backgroundColor = [UIColor clearColor];
    _defaultTextField.returnKeyType = UIReturnKeyDone;
    _defaultTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _defaultTextField.delegate = self;
    [self.view addSubview:_defaultTextField];
    
    UIButton *defaultButton = [UIButton buttonWithType:UIButtonTypeCustom];
    defaultButton.frame = CGRectMake(250, 500, 100, 50);
    defaultButton.backgroundColor = [UIColor redColor];
    [defaultButton setTitle:@"默认文案" forState:UIControlStateNormal];
    [defaultButton addTarget:self action:@selector(defaultButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:defaultButton];
    
    _functionTextField = [[UITextField alloc] initWithFrame:CGRectMake(20, 600, 200, 50)];
    _functionTextField.font = [UIFont systemFontOfSize:16];
    _functionTextField.textColor = [UIColor F1Color];
    _functionTextField.borderStyle = UITextBorderStyleRoundedRect;
    _functionTextField.backgroundColor = [UIColor clearColor];
    _functionTextField.returnKeyType = UIReturnKeyDone;
    _functionTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _functionTextField.delegate = self;
    [self.view addSubview:_functionTextField];
    
    UIButton *functionButton = [UIButton buttonWithType:UIButtonTypeCustom];
    functionButton.frame = CGRectMake(250, 600, 100, 50);
    functionButton.backgroundColor = [UIColor redColor];
    [functionButton setTitle:@"功能区" forState:UIControlStateNormal];
    [functionButton addTarget:self action:@selector(functionButton) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:functionButton];
}

- (void)setupNavBar:(LJNavigationBarType)type inputType:(LJNavigationBarInputType)inputType{
    
    [_navBar removeFromSuperview];
    _navBar = nil;
    
    _navBar = [[LJNavigationBar alloc] initWithNavBarType:type inputType:inputType];
    _navBar.delegate = self;
    _navBar.defaultText = inputType == LJNavigationBarInputTypeClick ? @"可点击" : @"可输入";
    _navBar.imageTextImage = [UIImage lj_imageNamed:@"home_nav_location_icon" inPodResourceBundleNamed:[LJHomeResource bundleName]];
    _navBar.imageTextTitle = LJ_APP_CONFIG.setting.cityName;
    _navBar.rightFunctionText = @"取消";
    _navBar.switchTitleText = @"二手房";
    _navBar.leftFirstItemImage = [UIImage lj_imageNamed:@"sh_icon_simple_login_close" inPodResourceBundleNamed:[LJHomeResource bundleName]];
    _navBar.rightFirstItemImage = [UIImage lj_imageNamed:@"sh_icon_simple_login_close" inPodResourceBundleNamed:[LJHomeResource bundleName]];
    _navBar.rightSecondItemImage = [UIImage lj_imageNamed:@"sh_icon_simple_login_close" inPodResourceBundleNamed:[LJHomeResource bundleName]];
    [self.view addSubview:_navBar];
    [_navBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.mas_equalTo(0);
        make.height.mas_equalTo(66);
    }];
}

- (void)clickChangeButton {
    if (_type == 8) {
        _type = 0;
    } else {
        _type ++;
    }
    
    [self setupNavBar:_type inputType:1];
}

// 控制红点
- (void)clickRedDotButton:(UIButton *)sender {
    [_navBar updateRightFirstItemRedDotStatus:sender.selected];
    sender.selected = !sender.selected;
}

- (void)cityButton {
    _navBar.imageTextTitle = _cityTextField.text;
}

- (void)switchButton {
    _navBar.switchTitleText = _switchTextField.text;
}

- (void)defaultButton {
    _navBar.defaultText = _defaultTextField.text;
}

- (void)functionButton {
    _navBar.rightFunctionText = _functionTextField.text;
}

#pragma mark - LJNavigationBarDelegate

- (void)navBarDidClickSwitch {
    [self.switchMenuView show];
}

#pragma mark - LJSwitchMenuViewDelegate

- (void)switchMenuDidSelectAtIndex:(NSInteger)index title:(NSString *)title {
    _navBar.switchTitleText = title;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.view endEditing:YES];
    return YES;
}

#pragma mark - Lazy

- (LJSwitchMenuView *)switchMenuView {
    if (!_switchMenuView) {
        _switchMenuView = [[LJSwitchMenuView alloc] initWithTitles:@[@"哈哈哈哈",@"aaa",@"哈哈哈",@"哈哈哈",@"1"] originPoint:CGPointMake(21, 61) inSuperView:self.view];
        _switchMenuView.delegate = self;
    }
    return _switchMenuView;
}

@end
