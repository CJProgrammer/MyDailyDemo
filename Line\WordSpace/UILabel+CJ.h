//
//  UILabel+CJ.h
//  VBlockChain
//
//  Created by CJ on 2018/2/3.
//  Copyright © 2018年 CJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (CJ)

/**
 设置行间距

 @param lineSpacing 行间距
 */
- (void)setLineSpacing:(CGFloat)lineSpacing;

/**
 设置字间距

 @param wordSpacing 字间距
 */
- (void)setWordSpacing:(CGFloat)wordSpacing;

/**
 设置行、字间距

 @param lineSpacing 行间距
 @param wordSpacing 字间距
 */
- (void)setLineSpacing:(CGFloat)lineSpacing wordSpacing:(CGFloat)wordSpacing;

@end



