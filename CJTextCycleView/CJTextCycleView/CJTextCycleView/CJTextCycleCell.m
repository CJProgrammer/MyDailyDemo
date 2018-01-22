//
//  CJTextCycleCell.m
//  CJTextCycleScrollView
//
//  Created by CJ on 2017/4/11.
//  Copyright © 2017年 CJ. All rights reserved.
//

#import "CJTextCycleCell.h"

@interface CJTextCycleCell ()

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end

@implementation CJTextCycleCell

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)setType:(Type)type {
    _type = type;
    
    if (type == FIRST) {
        
        NSString * title = [NSString stringWithFormat:@"尾号%u%u%u%u，成功放款%u000元",arc4random()%10,arc4random()%10,arc4random()%10,arc4random()%10,(arc4random()%29 + 2) * 5];
        
        NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc]initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
        
        [attributedString addAttributes:@{NSForegroundColorAttributeName:[UIColor cyanColor]} range:NSMakeRange( 11, title.length - 11)];
        
        self.titleLabel.attributedText = attributedString;
    } else if (type == SECOND) {
        
        NSString * title = [NSString stringWithFormat:@"尾号%u%u%u%u，正常还款，成功提额%u000元",arc4random()%10,arc4random()%10,arc4random()%10,arc4random()%10,arc4random()%10 + 1];
        
        NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc]initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
        
        [attributedString addAttributes:@{NSForegroundColorAttributeName:[UIColor cyanColor]} range:NSMakeRange( 16, title.length - 16)];
        
        self.titleLabel.attributedText = attributedString;
    } else if (type == THIRD) {
        
        NSString * title = [NSString stringWithFormat:@"尾号%u%u%u%u，成功放款%u000元，用时%u分钟",arc4random()%10,arc4random()%10,arc4random()%10,arc4random()%10,(arc4random()%29 + 2) * 5,arc4random()%8 + 1];
        
        NSMutableAttributedString * attributedString = [[NSMutableAttributedString alloc]initWithString:title attributes:@{NSForegroundColorAttributeName:[UIColor lightGrayColor]}];
        
        [attributedString addAttributes:@{NSForegroundColorAttributeName:[UIColor cyanColor]} range:NSMakeRange( 11, title.length - 11 - 6)];
        
        self.titleLabel.attributedText = attributedString;
    }
}

@end
