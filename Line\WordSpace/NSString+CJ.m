//
//  NSString+CJ.m
//  VBlockChain
//
//  Created by CJ on 2018/2/3.
//  Copyright © 2018年 CJ. All rights reserved.
//

#import "NSString+CJ.h"

@implementation NSString (CJ)

- (CGSize)sizeWithConstraint:(CGSize)size font:(UIFont *)font {
    return [self sizeWithConstraint:size font:font lineSpacing:0 wordSpacing:0];
}

- (CGSize)sizeWithConstraint:(CGSize)size font:(UIFont *)font lineSpacing:(CGFloat)lineSpacing {
    return [self sizeWithConstraint:size font:font lineSpacing:lineSpacing wordSpacing:0];
}

- (CGSize)sizeWithConstraint:(CGSize)size font:(UIFont *)font wordSpacing:(CGFloat)wordSpacing {
    return [self sizeWithConstraint:size font:font lineSpacing:0 wordSpacing:wordSpacing];
}

- (CGSize)sizeWithConstraint:(CGSize)size font:(UIFont *)font lineSpacing:(CGFloat)lineSpacing wordSpacing:(CGFloat)wordSpacing {
    NSMutableParagraphStyle * paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:lineSpacing];
    
    NSDictionary * attribute = @{NSFontAttributeName:font, NSParagraphStyleAttributeName:paragraphStyle,NSKernAttributeName:@(wordSpacing)};
    
    CGRect rect = [self boundingRectWithSize:size options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil];
    
    return rect.size;
}

@end
