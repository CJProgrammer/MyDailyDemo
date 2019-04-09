//
//  LJSwitchMenuViewCell.m
//  Lianjia_Beike_Home
//
//  Created by CJ on 2019/4/3.
//

#import "LJSwitchMenuViewCell.h"

@interface LJSwitchMenuViewCell ()

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation LJSwitchMenuViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self setupContentView];
    }
    return self;
}

- (void)setupContentView {
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.textColor = [UIColor F1Color];
    _titleLabel.font = [UIFont systemFontOfSize:16];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_titleLabel];
    [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(0);
        make.centerY.mas_equalTo(self.contentView);
    }];
}

- (void)setTitleModel:(LJSwitchMenuViewCellTitleModel *)titleModel {
    _titleModel = titleModel;
    
    _titleLabel.text = titleModel.title;
    
    if (titleModel.isSelected) {
        _titleLabel.textColor = [UIColor B0Color];
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
    } else {
        _titleLabel.textColor = [UIColor F1Color];
        _titleLabel.font = [UIFont systemFontOfSize:16];
    }
}

@end


@implementation LJSwitchMenuViewCellTitleModel

@end
