//
//  NSString+CJ.h
//  VBlockChain
//
//  Created by CJ on 2018/2/3.
//  Copyright © 2018年 CJ. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CJ)

/**
 获取字符串的size

 @param size 最大的约束条件
 @param font 字体大小
 @return 返回size
 */
- (CGSize)sizeWithConstraint:(CGSize)size font:(UIFont *)font;

/**
 获取字符串的size
 
 @param size 最大的约束条件
 @param font 字体大小
 @param lineSpacing 行间距
 @return 返回size
 */
- (CGSize)sizeWithConstraint:(CGSize)size font:(UIFont *)font lineSpacing:(CGFloat)lineSpacing;

/**
 获取字符串的size
 
 @param size 最大的约束条件
 @param font 字体大小
 @param wordSpacing 字间距
 @return 返回size
 */
- (CGSize)sizeWithConstraint:(CGSize)size font:(UIFont *)font wordSpacing:(CGFloat)wordSpacing;

/**
 获取字符串的size
 
 @param size 最大的约束条件
 @param font 字体大小
 @param lineSpacing 行间距
 @param wordSpacing 字间距
 @return 返回size
 */
- (CGSize)sizeWithConstraint:(CGSize)size font:(UIFont *)font lineSpacing:(CGFloat)lineSpacing wordSpacing:(CGFloat)wordSpacing;

@end
