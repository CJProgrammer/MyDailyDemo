//
//  CJTextCycleCell.m
//  CJTextCycleScrollView
//
//  Created by CJ on 2017/4/11.
//  Copyright © 2017年 CJ. All rights reserved.
//

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#import "CJTextCycleCell.h"

@interface CJTextCycleCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation CJTextCycleCell

- (void)awakeFromNib {
    [super awakeFromNib];

    
}

- (void)setType:(Type)type
{
    _type = type;
    
    if (type == FIRST) {
        
        NSString * title = [NSString stringWithFormat:@"尾号%u%u%u%u，成功放款%u000元",arc4random()%10,arc4random()%10,arc4random()%10,arc4random()%10,(arc4random()%29 + 2) * 5];
        
        NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc]initWithString:title attributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0x333333)}];
        
        [attributedString addAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0xff8200)} range:NSMakeRange( 11, title.length - 11)];
        
        self.titleLabel.attributedText = attributedString;
    } else if (type == SECOND) {
        
        NSString * title = [NSString stringWithFormat:@"尾号%u%u%u%u，正常还款，成功提额%u000元",arc4random()%10,arc4random()%10,arc4random()%10,arc4random()%10,arc4random()%10 + 1];
        
        NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc]initWithString:title attributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0x333333)}];
        
        [attributedString addAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0xff8200)} range:NSMakeRange( 16, title.length - 16)];
        
        self.titleLabel.attributedText = attributedString;
    } else if (type == THIRD) {
        
        NSString * title = [NSString stringWithFormat:@"尾号%u%u%u%u，成功放款%u000元，用时%u分钟",arc4random()%10,arc4random()%10,arc4random()%10,arc4random()%10,(arc4random()%29 + 2) * 5,arc4random()%8 + 1];
        
        NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc]initWithString:title attributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0x333333)}];
        
        [attributedString addAttributes:@{NSForegroundColorAttributeName:UIColorFromRGB(0xff8200)} range:NSMakeRange( 11, title.length - 11 - 6)];
        
        self.titleLabel.attributedText = attributedString;
    }
    
}

@end
