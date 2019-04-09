//
//  LJNavigationBar.m
//  Lianjia_Beike_Home
//
//  Created by CJ on 2019/3/28.
//

#import "LJNavigationBar.h"
#import "LJNavigationBarImageTextControl.h"
#import "LJNavigationBarSwitchControl.h"
#import "LJNavigationBarItemControl.h"

@interface LJNavigationBar ()

/** nav bar type */
@property (nonatomic, assign) LJNavigationBarType navBarType;
/** input type */
@property (nonatomic, assign) LJNavigationBarInputType inputType;
/** search container */
@property (nonatomic, strong) UIControl *searchContainerControl;
/** search icon */
@property (nonatomic, strong) UIImageView *searchIconImageView;
/** default text */
@property (nonatomic, strong) UILabel *defaultTextLabel;
/** image text control */
@property (nonatomic, strong) LJNavigationBarImageTextControl *imageTextControl;
/** right function button */
@property (nonatomic, strong) UIButton *rightFunctionButton;
/** switch control */
@property (nonatomic, strong) LJNavigationBarSwitchControl *switchControl;
/** left first item control */
@property (nonatomic, strong) LJNavigationBarItemControl *leftFirstItemControl;
/** right first item control */
@property (nonatomic, strong) LJNavigationBarItemControl *rightFirstItemControl;
/** right second item control */
@property (nonatomic, strong) LJNavigationBarItemControl *rightSecondItemControl;

@end

// main height
static NSInteger const kMainHeight = 66;
// left/right spacing
static NSInteger const kLRSpacing = 24;
// bottom spacing
static NSInteger const kBottomSpacing = 8;
// input height
static NSInteger const kInputHeight = 50;
// left/right item spacing
static NSInteger const kItemLRSpacing = 8;
// item width/height
static NSInteger const kItemWH = 40;
// default text
static NSString const *kDefaultText = @"你想住在哪？";

@implementation LJNavigationBar

- (instancetype)initWithNavBarType:(LJNavigationBarType)navBarType inputType:(LJNavigationBarInputType)inputType {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        _navBarType = navBarType;
        _inputType = inputType;
        // set up self attributes
        [self setupSelfAttributes];
        // set up content views
        [self setupContentViews];
    }
    return self;
}

// set up self attributes
- (void)setupSelfAttributes {
    self.backgroundColor = [UIColor whiteColor];
}

// set up content views
- (void)setupContentViews {

    // 1:搜索框-城市
    if (_navBarType == LJNavigationBarType01) {
        [self setupNavBarType01];
    }
    
    // 2:搜索框
    else if (_navBarType == LJNavigationBarType02) {
        [self setupNavBarType02];
    }
    
    // 3:搜索框-自定义功能
    else if (_navBarType == LJNavigationBarType03) {
        [self setupNavBarType03];
    }
    
    // 4:切换区-搜索框-自定义功能
    else if (_navBarType == LJNavigationBarType04) {
        [self setupNavBarType04];
    }
    
    // 5:item-搜索框
    else if (_navBarType == LJNavigationBarType05) {
        [self setupNavBarType05];
    }
    
    // 6:item-搜索框-自定义功能
    else if (_navBarType == LJNavigationBarType06) {
        [self setupNavBarType06];
    }
    
    // 7:item-搜索框-红点item
    else if (_navBarType == LJNavigationBarType07) {
        [self setupNavBarType07];
    }
    
    // 8:item-切换区-搜索框-item
    else if (_navBarType == LJNavigationBarType08) {
        [self setupNavBarType08];
    }
    
    // 9:item-搜索框-item-item
    else if (_navBarType == LJNavigationBarType09) {
        [self setupNavBarType09];
    }
    
    // search icon
    self.searchIconImageView.image = [UIImage lj_imageNamed:@"home_nav_search_icon" inPodResourceBundleNamed:[LJHomeResource bundleName]];
    
    // input type
    if (_inputType == LJNavigationBarInputTypeClick) {
        [self.searchContainerControl addTarget:self action:@selector(clickSearchControl) forControlEvents:UIControlEventTouchUpInside];
        self.defaultTextLabel.text = kDefaultText;
    } else {
        self.inputTextField.placeholder = kDefaultText;
    }
}

// 1:搜索框-城市
- (void)setupNavBarType01 {
    
    // image text
    [self.imageTextControl addTarget:self action:@selector(clickImageTextControl) forControlEvents:UIControlEventTouchUpInside];
    
    // search container
    [self.searchContainerControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kLRSpacing);
        make.right.mas_equalTo(self.imageTextControl.mas_left);
        make.height.mas_equalTo(kInputHeight);
        make.bottom.mas_equalTo(-kBottomSpacing);
    }];
}

// 2:搜索框
- (void)setupNavBarType02 {
    
    // search container
    [self.searchContainerControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kLRSpacing);
        make.right.mas_equalTo(-kLRSpacing);
        make.height.mas_equalTo(kInputHeight);
        make.bottom.mas_equalTo(-kBottomSpacing);
    }];
}

// 3:搜索框-自定义功能
- (void)setupNavBarType03 {
    
    // right function button
    [self.rightFunctionButton addTarget:self action:@selector(clickRightFunctionButton) forControlEvents:UIControlEventTouchUpInside];
    
    // search container
    [self.searchContainerControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kLRSpacing);
        make.right.mas_equalTo(self.rightFunctionButton.mas_left);
        make.height.mas_equalTo(kInputHeight);
        make.bottom.mas_equalTo(-kBottomSpacing);
    }];
}

// 4:切换区-搜索框-自定义功能
- (void)setupNavBarType04 {
    
    // right function button
    [self.rightFunctionButton addTarget:self action:@selector(clickRightFunctionButton) forControlEvents:UIControlEventTouchUpInside];
    
    // search container
    [self.searchContainerControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kLRSpacing);
        make.right.mas_equalTo(self.rightFunctionButton.mas_left);
        make.height.mas_equalTo(kInputHeight);
        make.bottom.mas_equalTo(-kBottomSpacing);
    }];
    
    // switch control
    [self.switchControl addTarget:self action:@selector(clickSwitchControl) forControlEvents:UIControlEventTouchUpInside];
    
    // search icon
    [self.searchIconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.switchControl.mas_right).offset(12);
        make.centerY.mas_equalTo(self.searchContainerControl);
        make.width.height.mas_equalTo(18);
    }];
}

// 5:item-搜索框
- (void)setupNavBarType05 {
    
    // left first item
    [self.leftFirstItemControl addTarget:self action:@selector(clickLeftFirstItemControl) forControlEvents:UIControlEventTouchUpInside];
    
    // search container
    [self.searchContainerControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftFirstItemControl.mas_right).offset(kItemLRSpacing);
        make.right.mas_equalTo(-kLRSpacing);
        make.height.mas_equalTo(kInputHeight);
        make.bottom.mas_equalTo(-kBottomSpacing);
    }];
}

// 6:item-搜索框-自定义功能
- (void)setupNavBarType06 {
    
    // left first item
    [self.leftFirstItemControl addTarget:self action:@selector(clickLeftFirstItemControl) forControlEvents:UIControlEventTouchUpInside];
    
    // right function button
    [self.rightFunctionButton addTarget:self action:@selector(clickRightFunctionButton) forControlEvents:UIControlEventTouchUpInside];
    
    // search container
    [self.searchContainerControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftFirstItemControl.mas_right).offset(kItemLRSpacing);
        make.right.mas_equalTo(self.rightFunctionButton.mas_left);
        make.height.mas_equalTo(kInputHeight);
        make.bottom.mas_equalTo(-kBottomSpacing);
    }];
}

// 7:item-搜索框-红点item
- (void)setupNavBarType07 {
    
    // left first item
    [self.leftFirstItemControl addTarget:self action:@selector(clickLeftFirstItemControl) forControlEvents:UIControlEventTouchUpInside];
    
    // right first item
    [self.rightFirstItemControl addTarget:self action:@selector(clickRightFirstItemControl) forControlEvents:UIControlEventTouchUpInside];
    
    // search container
    [self.searchContainerControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftFirstItemControl.mas_right).offset(kItemLRSpacing);
        make.right.mas_equalTo(self.rightFirstItemControl.mas_left).offset(-kItemLRSpacing);
        make.height.mas_equalTo(kInputHeight);
        make.bottom.mas_equalTo(-kBottomSpacing);
    }];

}

// 8:item-切换区-搜索框-item
- (void)setupNavBarType08 {
    
    // left first item
    [self.leftFirstItemControl addTarget:self action:@selector(clickLeftFirstItemControl) forControlEvents:UIControlEventTouchUpInside];
    
    // right first item
    [self.rightFirstItemControl addTarget:self action:@selector(clickRightFirstItemControl) forControlEvents:UIControlEventTouchUpInside];
    
    // search container
    [self.searchContainerControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftFirstItemControl.mas_right).offset(kItemLRSpacing);
        make.right.mas_equalTo(self.rightFirstItemControl.mas_left).offset(-kItemLRSpacing);
        make.height.mas_equalTo(kInputHeight);
        make.bottom.mas_equalTo(-kBottomSpacing);
    }];
    
    // switch control
    [self.switchControl addTarget:self action:@selector(clickSwitchControl) forControlEvents:UIControlEventTouchUpInside];
    
    // search icon
    [self.searchIconImageView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.switchControl.mas_right).offset(12);
        make.centerY.mas_equalTo(self.searchContainerControl);
        make.width.height.mas_equalTo(18);
    }];
}

// 9:item-搜索框-item-item
- (void)setupNavBarType09 {
    
    // left first item
    [self.leftFirstItemControl addTarget:self action:@selector(clickLeftFirstItemControl) forControlEvents:UIControlEventTouchUpInside];
    
    // right first item
    [self.rightFirstItemControl addTarget:self action:@selector(clickRightFirstItemControl) forControlEvents:UIControlEventTouchUpInside];
    
    // right second item
    [self.rightSecondItemControl addTarget:self action:@selector(clickRightSecondItemControl) forControlEvents:UIControlEventTouchUpInside];
    
    // search container
    [self.searchContainerControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.leftFirstItemControl.mas_right).offset(kItemLRSpacing);
        make.right.mas_equalTo(self.rightSecondItemControl.mas_left).offset(-kItemLRSpacing);
        make.height.mas_equalTo(kInputHeight);
        make.bottom.mas_equalTo(-kBottomSpacing);
    }];
}

#pragma mark - Action

// click search control
- (void)clickSearchControl {
    if ([_delegate respondsToSelector:@selector(navBarDidClickSearch)]) {
        [_delegate navBarDidClickSearch];
    }
}

// click city control
- (void)clickImageTextControl {
    if ([_delegate respondsToSelector:@selector(navBarDidClickImageText)]) {
        [_delegate navBarDidClickImageText];
    }
}

// click right function button
- (void)clickRightFunctionButton {
    if ([_delegate respondsToSelector:@selector(navBarDidClickRightFunction)]) {
        [_delegate navBarDidClickRightFunction];
    }
}

// click switch control
- (void)clickSwitchControl {
    if ([_delegate respondsToSelector:@selector(navBarDidClickSwitch)]) {
        [_delegate navBarDidClickSwitch];
    }
}

// click left first item control
- (void)clickLeftFirstItemControl {
    if ([_delegate respondsToSelector:@selector(navBarDidClickLeftFirstItem)]) {
        [_delegate navBarDidClickLeftFirstItem];
    }
}

// click right first item control
- (void)clickRightFirstItemControl {
    if ([_delegate respondsToSelector:@selector(navBarDidClickRightFirstItem)]) {
        [_delegate navBarDidClickRightFirstItem];
    }
}

// click right second item control
- (void)clickRightSecondItemControl {
    if ([_delegate respondsToSelector:@selector(navBarDidClickRightSecondItem)]) {
        [_delegate navBarDidClickRightSecondItem];
    }
}

// update right first item red dot show or hidden
- (void)updateRightFirstItemRedDotStatus:(BOOL)hidden {
    [_rightFirstItemControl updateRedDotStatus:hidden];
}

// update right second item red dot show or hidden
- (void)updateRightSecondItemRedDotStatus:(BOOL)hidden {
    [_rightSecondItemControl updateRedDotStatus:hidden];
}

#pragma mark - Setter

// default text
- (void)setDefaultText:(NSString *)defaultText {
    _defaultText = defaultText;
    if (_inputType == LJNavigationBarInputTypeClick) {
        _defaultTextLabel.text = defaultText;
    } else if (_inputType == LJNavigationBarInputTypeInput) {
        _inputTextField.placeholder = defaultText;
    }
}

// image text image
- (void)setImageTextImage:(UIImage *)imageTextImage {
    _imageTextImage = imageTextImage;
    _imageTextControl.imageTextImage = imageTextImage;
}

// image text title
- (void)setImageTextTitle:(NSString *)imageTextTitle {
    _imageTextTitle = imageTextTitle;
    _imageTextControl.imageTextTitle = imageTextTitle;
}

// right function text
- (void)setRightFunctionText:(NSString *)rightFunctionText {
    _rightFunctionText = rightFunctionText;
    [_rightFunctionButton setTitle:rightFunctionText forState:UIControlStateNormal];
}

// switch title text
- (void)setSwitchTitleText:(NSString *)switchTitleText {
    _switchTitleText = switchTitleText;
    _switchControl.switchTitle = switchTitleText;
}

// left first item image
- (void)setLeftFirstItemImage:(UIImage *)leftFirstItemImage {
    _leftFirstItemImage = leftFirstItemImage;
    _leftFirstItemControl.itemImage = leftFirstItemImage;
}

// right first item image
- (void)setRightFirstItemImage:(UIImage *)rightFirstItemImage {
    _rightFirstItemImage = rightFirstItemImage;
    _rightFirstItemControl.itemImage = rightFirstItemImage;
}

// right second item image
- (void)setRightSecondItemImage:(UIImage *)rightSecondItemImage {
    _rightSecondItemImage = rightSecondItemImage;
    _rightSecondItemControl.itemImage = rightSecondItemImage;
}

#pragma mark - Getter

// search container
- (UIControl *)searchContainerControl {
    if (!_searchContainerControl) {
        _searchContainerControl = [[UIControl alloc] initWithFrame:CGRectZero];
        _searchContainerControl.backgroundColor = [UIColor L2Color];
        _searchContainerControl.layer.cornerRadius = 5;
        _searchContainerControl.bordColor = [UIColor F3Color];
        _searchContainerControl.bordWidth = 0.5;
        _searchContainerControl.layer.shadowOffset = CGSizeMake(0, 2);
        _searchContainerControl.layer.shadowColor = [UIColor F0Color].CGColor;
        _searchContainerControl.layer.shadowOpacity = 0.05;
        _searchContainerControl.layer.shadowRadius = 5;
        [self addSubview:_searchContainerControl];
    }
    return _searchContainerControl;
}

// search icon
- (UIImageView *)searchIconImageView {
    if (!_searchIconImageView) {
        _searchIconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        
        [self.searchContainerControl addSubview:_searchIconImageView];
        [_searchIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(16);
            make.centerY.mas_equalTo(self.searchContainerControl);
            make.width.height.mas_equalTo(18);
        }];
    }
    return _searchIconImageView;
}

// default text
- (UILabel *)defaultTextLabel {
    if (!_defaultTextLabel) {
        _defaultTextLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _defaultTextLabel.textColor = [UIColor F2Color];
        _defaultTextLabel.font = [UIFont boldSystemFontOfSize:16];
        _defaultTextLabel.textAlignment = NSTextAlignmentLeft;
        [_defaultTextLabel setContentHuggingPriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
        
        [self.searchContainerControl addSubview:_defaultTextLabel];
        [_defaultTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.searchIconImageView.mas_right).offset(4);
            make.centerY.mas_equalTo(self.searchContainerControl);
            make.right.mas_equalTo(-16);
        }];
    }
    return _defaultTextLabel;
}

// input textField
- (UITextField *)inputTextField {
    if (!_inputTextField) {
        _inputTextField = [[UITextField alloc] initWithFrame:CGRectZero];
        _inputTextField.font = [UIFont boldSystemFontOfSize:16];
        _inputTextField.textColor = [UIColor F1Color];
//        _inputTextField.placeholderColor = [UIColor F1Color];
        [_inputTextField setValue:[UIColor F2Color] forKeyPath:@"_placeholderLabel.textColor"];
        _inputTextField.backgroundColor = [UIColor clearColor];
        _inputTextField.returnKeyType = UIReturnKeySearch;
        _inputTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        [self.searchContainerControl addSubview:_inputTextField];
        [_inputTextField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.searchIconImageView.mas_right).offset(4);
            make.top.mas_equalTo(2);
            make.bottom.mas_equalTo(0);
            make.right.mas_equalTo(-14);
        }];
    }
    return _inputTextField;
}

// image text control
- (LJNavigationBarImageTextControl *)imageTextControl {
    if (!_imageTextControl) {
        _imageTextControl = [[LJNavigationBarImageTextControl alloc] initWithFrame:CGRectZero];
        [self addSubview:_imageTextControl];
        [_imageTextControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(-3);
            make.width.mas_lessThanOrEqualTo(132);
            make.height.mas_equalTo(kMainHeight - 3);
        }];
    }
    return _imageTextControl;
}

// right function button
- (UIButton *)rightFunctionButton {
    if (!_rightFunctionButton) {
        _rightFunctionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_rightFunctionButton setTitleColor:[UIColor F1Color] forState:UIControlStateNormal];
        _rightFunctionButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _rightFunctionButton.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _rightFunctionButton.contentEdgeInsets = UIEdgeInsetsMake(0, 24, 0, 24);
        [_rightFunctionButton setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self addSubview:_rightFunctionButton];
        
        [_rightFunctionButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(0);
            make.bottom.mas_equalTo(-3);
            make.width.mas_lessThanOrEqualTo(114);
            make.height.mas_equalTo(kMainHeight - 3);
        }];
    }
    return _rightFunctionButton;
}

// switch control
- (LJNavigationBarSwitchControl *)switchControl {
    if (!_switchControl) {
        _switchControl = [[LJNavigationBarSwitchControl alloc] initWithFrame:CGRectZero];
        [self.searchContainerControl addSubview:_switchControl];
        [_switchControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.mas_equalTo(0);
            make.width.mas_lessThanOrEqualTo(110);
        }];
    }
    return _switchControl;
}

// left first item control
- (LJNavigationBarItemControl *)leftFirstItemControl {
    if (!_leftFirstItemControl) {
        _leftFirstItemControl = [[LJNavigationBarItemControl alloc] initWithFrame:CGRectZero];
        [self addSubview:_leftFirstItemControl];
        [_leftFirstItemControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(kItemLRSpacing);
            make.bottom.mas_equalTo(-(kBottomSpacing + 5));
            make.width.height.mas_equalTo(kItemWH);
        }];
    }
    return _leftFirstItemControl;
}

// right first item control
- (LJNavigationBarItemControl *)rightFirstItemControl {
    if (!_rightFirstItemControl) {
        _rightFirstItemControl = [[LJNavigationBarItemControl alloc] initWithFrame:CGRectZero];
        [self addSubview:_rightFirstItemControl];
        [_rightFirstItemControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-kItemLRSpacing);
            make.bottom.mas_equalTo(-(kBottomSpacing + 5));
            make.width.height.mas_equalTo(kItemWH);
        }];
    }
    return _rightFirstItemControl;
}

// right second item control
- (LJNavigationBarItemControl *)rightSecondItemControl {
    if (!_rightSecondItemControl) {
        _rightSecondItemControl = [[LJNavigationBarItemControl alloc] initWithFrame:CGRectZero];
        [self addSubview:_rightSecondItemControl];
        [_rightSecondItemControl mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-(kItemLRSpacing + kItemWH));
            make.bottom.mas_equalTo(-(kBottomSpacing + 5));
            make.width.height.mas_equalTo(kItemWH);
        }];
    }
    return _rightSecondItemControl;
}

@end
