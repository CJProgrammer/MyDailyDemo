//
//  UIImage+QRCode.m
//  VBlockChain
//
//  Created by CJ on 2018/1/17.
//  Copyright © 2018年 CJ. All rights reserved.
//

#import "UIImage+QRCode.h"

@implementation UIImage (QRCode)

+ (UIImage *)qrCodeForURLStr:(NSString *)urlStr qrCodeSize:(CGFloat)qrCodeSize {
    return [UIImage qrCodeForURLStr:urlStr qrCodeSize:qrCodeSize logoImage:nil logoSize:0];
}

+ (UIImage *)qrCodeForURLStr:(NSString *)urlStr qrCodeSize:(CGFloat)qrCodeSize logoImage:(UIImage *)logoImage logoSize:(CGFloat)logoSize {
    
    // 二维码过滤器
    CIFilter * filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    // 设置过滤器默认属性
    [filter setDefaults];
    
    // 将字符串转换成 NSdata (虽然二维码本质上是字符串,但是这里需要转换,不转换就崩溃)
    NSData * data = [urlStr dataUsingEncoding:NSUTF8StringEncoding];
    // 设置过滤器的 输入值  ,KVC赋值
    [filter setValue:data forKey:@"inputMessage"];
    // 设置二维码的纠错水平，越高纠错水平越高，可以污损的范围越大
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];
    // 拿到二维码图片
    CIImage * outPutImage = [filter outputImage];
    
    return [[self alloc] createQRUIImageWithQRCIImage:outPutImage qrCodeSize:qrCodeSize logoImage:logoImage logoSize:logoSize];
}

- (UIImage *)createQRUIImageWithQRCIImage:(CIImage *)qrCIImage qrCodeSize:(CGFloat)qrCodeSize logoImage:(UIImage *)logoImage logoSize:(CGFloat)logoSize {
    
    CGRect extent = CGRectIntegral(qrCIImage.extent);
    CGFloat scale = MIN(qrCodeSize/CGRectGetWidth(extent), qrCodeSize/CGRectGetHeight(extent));
    
    // 1.创建bitmap;
    size_t width = CGRectGetWidth(extent) * scale;
    size_t height = CGRectGetHeight(extent) * scale;
    
    // 创建一个DeviceGray颜色空间
    CGColorSpaceRef cs = CGColorSpaceCreateDeviceGray();
    
    //CGBitmapContextCreate(void * _Nullable data, size_t width, size_t height, size_t bitsPerComponent, size_t bytesPerRow, CGColorSpaceRef  _Nullable space, uint32_t bitmapInfo)
    //width：图片宽度像素
    //height：图片高度像素
    //bitsPerComponent：每个颜色的比特值，例如在rgba-32模式下为8
    //bitmapInfo：指定的位图应该包含一个alpha通道。
    CGContextRef bitmapRef = CGBitmapContextCreate(nil, width, height, 8, 0, cs, (CGBitmapInfo)kCGImageAlphaNone);
    CIContext * context = [CIContext contextWithOptions:nil];
    
    // 创建CoreGraphics image
    CGImageRef bitmapImage = [context createCGImage:qrCIImage fromRect:extent];
    CGContextSetInterpolationQuality(bitmapRef, kCGInterpolationNone);
    CGContextScaleCTM(bitmapRef, scale, scale);
    CGContextDrawImage(bitmapRef, extent, bitmapImage);
    // 2.保存bitmap到图片
    CGImageRef scaledImage = CGBitmapContextCreateImage(bitmapRef);

    CGContextRelease(bitmapRef);
    CGImageRelease(bitmapImage);
    
    // 3.转换成 UIImage
    UIImage * qrImage = [UIImage imageWithCGImage:scaledImage];
    
    if (logoImage) {
        // 4.给二维码加 logo 图，开启图形上下文
        UIGraphicsBeginImageContextWithOptions(qrImage.size, NO, 0);
        // 把二维码图片画上去.
        [qrImage drawInRect:CGRectMake(0, 0, qrCodeSize, qrCodeSize)];
        // 把logo图画到生成的二维码图片上，注意尺寸不要太大（最大不超过二维码图片的%30），太大会造成扫不出来
        [logoImage drawInRect:CGRectMake((qrCodeSize - logoSize) / 2.0, (qrCodeSize - logoSize) / 2.0, logoSize, logoSize)];
        // 获取当前画得的这张图片
        UIImage * qrLogoImage = UIGraphicsGetImageFromCurrentImageContext();
        // 关闭图形上下文
        UIGraphicsEndImageContext();
        
        return qrLogoImage;
    }
    
    return qrImage;
}


@end
