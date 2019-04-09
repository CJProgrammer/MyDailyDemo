//
//  LJNavigationBarSwitchControl.m
//  LJNavigationBar
//
//  Created by CJ on 2019/4/2.
//

#import "LJNavigationBarSwitchControl.h"

@interface LJNavigationBarSwitchControl ()

@property (nonatomic, strong) UIView *verticalLineView;
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) UILabel *switchTitleLabel;

@end

@implementation LJNavigationBarSwitchControl

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupContentViews];
    }
    return self;
}

// set up content views
- (void)setupContentViews {
    
    // vertical line
    _verticalLineView = [[UIView alloc] initWithFrame:CGRectZero];
    _verticalLineView.backgroundColor = [UIColor F3Color];
    _verticalLineView.cornerRadius = 0.5;
    [self addSubview:_verticalLineView];
    
    [_verticalLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self);
        make.centerY.mas_equalTo(self);
        make.height.mas_equalTo(16);
        make.width.mas_equalTo(1);
    }];
    
    // arrow
    _arrowImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _arrowImageView.image = [UIImage lj_imageNamed:@"home_nav_arrow_icon" inPodResourceBundleNamed:[LJHomeResource bundleName]];
    [self addSubview:_arrowImageView];
    
    [_arrowImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-16);
        make.centerY.mas_equalTo(self);
        make.width.height.mas_equalTo(8);
    }];
    
    // title
    _switchTitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _switchTitleLabel.textColor = [UIColor F1Color];
    _switchTitleLabel.font = [UIFont boldSystemFontOfSize:16];
    _switchTitleLabel.textAlignment = NSTextAlignmentLeft;
    [_switchTitleLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self addSubview:_switchTitleLabel];
    
    [_switchTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.centerY.mas_equalTo(self);
        make.right.mas_equalTo(-28);
    }];
}

- (void)setSwitchTitle:(NSString *)switchTitle {
    _switchTitle = switchTitle;
    _switchTitleLabel.text = switchTitle;
}

@end
