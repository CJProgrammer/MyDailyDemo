//
//  UILabel+CJ.m
//  VBlockChain
//
//  Created by CJ on 2018/2/3.
//  Copyright © 2018年 CJ. All rights reserved.
//

#import "UILabel+CJ.h"

@implementation UILabel (CJ)

- (void)setLineSpacing:(CGFloat)lineSpacing {
    if (self.text.length > 0) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        [paragraphStyle setLineSpacing:lineSpacing];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.text.length)];
        self.attributedText = attributedString;
    }
}

- (void)setWordSpacing:(CGFloat)wordSpacing {
    if (self.text.length > 0) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
        [attributedString addAttribute:NSKernAttributeName value:@(wordSpacing) range:NSMakeRange(0, self.text.length)];
        self.attributedText = attributedString;
    }
}

- (void)setLineSpacing:(CGFloat)lineSpacing wordSpacing:(CGFloat)wordSpacing {
    if (self.text.length > 0) {
        
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.text];
        
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        [paragraphStyle setLineSpacing:lineSpacing];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.text.length)];
        
        [attributedString addAttribute:NSKernAttributeName value:@(wordSpacing) range:NSMakeRange(0, self.text.length)];
        
        self.attributedText = attributedString;
    }
}



@end

/*
- (CGSize)sizeWithWidth:(CGFloat)width lineSpacing:(CGFloat)lineSpacing {
    if (self.text.length > 0) {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc]initWithString:self.text];
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        [paragraphStyle setLineSpacing:lineSpacing];
        [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, self.text.length)];
        self.attributedText = attributedString;
        
        CGSize size = CGSizeMake(width, MAXFLOAT);
        return [self sizeThatFits:size];
    }
    return CGSizeZero;
}
 
 */
