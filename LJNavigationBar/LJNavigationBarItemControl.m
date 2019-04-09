//
//  LJNavigationBarItemControl.m
//  LJNavigationBar
//
//  Created by CJ on 2019/4/2.
//

#import "LJNavigationBarItemControl.h"

@interface LJNavigationBarItemControl ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UIView *redDotView;

@end

@implementation LJNavigationBarItemControl

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupContentViews];
    }
    return self;
}

// set up content views
- (void)setupContentViews {
    
    // icon
    _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    _iconImageView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_iconImageView];
    
    [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(self);
        make.width.height.mas_equalTo(24);
    }];
    
    // red dot
    _redDotView = [[UIView alloc] initWithFrame:CGRectZero];
    _redDotView.backgroundColor = [UIColor A0Color];
    _redDotView.cornerRadius = 4;
    _redDotView.hidden = YES;
    [self addSubview:_redDotView];
    
    [_redDotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-4);
        make.top.mas_equalTo(4);
        make.width.height.mas_equalTo(8);
    }];
}

- (void)setItemImage:(UIImage *)itemImage {
    _itemImage = itemImage;
    _iconImageView.image = itemImage;
}

// update red dot hide or show
- (void)updateRedDotStatus:(BOOL)hidden {
    _redDotView.hidden = hidden;
}

@end
