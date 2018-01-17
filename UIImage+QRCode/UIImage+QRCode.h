//
//  UIImage+QRCode.h
//  VBlockChain
//
//  Created by CJ on 2018/1/17.
//  Copyright © 2018年 CJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (QRCode)

/**
 二维码
 
 @param urlStr 二维码链接
 @param qrCodeSize 二维码尺寸
 @return 返回二维码
 */
+ (UIImage *)qrCodeForURLStr:(NSString *)urlStr qrCodeSize:(CGFloat)qrCodeSize;

/**
 二维码

 @param urlStr 二维码链接
 @param qrCodeSize 二维码尺寸
 @param logoImage logo 图片
 @param logoSize logo 大小
 @return 返回二维码
 */
+ (UIImage *)qrCodeForURLStr:(NSString *)urlStr qrCodeSize:(CGFloat)qrCodeSize logoImage:(UIImage *)logoImage logoSize:(CGFloat)logoSize;

@end




