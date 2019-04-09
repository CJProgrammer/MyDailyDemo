//
//  LJNavigationBarImageTextControl.m
//  FLAnimatedImage
//
//  Created by CJ on 2019/4/8.
//

#import "LJNavigationBarImageTextControl.h"

@interface LJNavigationBarImageTextControl ()

@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *textLabel;

@end

@implementation LJNavigationBarImageTextControl

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupContentViews];
    }
    return self;
}

// set up content views
- (void)setupContentViews {
    
    _iconImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [self addSubview:_iconImageView];
    [_iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(18);
        make.centerY.mas_equalTo(self);
        make.width.height.mas_equalTo(24);
    }];
    
    _textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _textLabel.textColor = [UIColor F1Color];
    _textLabel.font = [UIFont boldSystemFontOfSize:16];
    _textLabel.textAlignment = NSTextAlignmentLeft;
    [_textLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self addSubview:_textLabel];
    [_textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.iconImageView.mas_right);
        make.centerY.mas_equalTo(self);
        make.right.mas_equalTo(-24);
    }];
}

- (void)setImageTextImage:(UIImage *)imageTextImage {
    _imageTextImage = imageTextImage;
    _iconImageView.image = imageTextImage;
}

- (void)setImageTextTitle:(NSString *)imageTextTitle {
    _imageTextTitle = imageTextTitle;
    _textLabel.text = imageTextTitle;
}

@end
