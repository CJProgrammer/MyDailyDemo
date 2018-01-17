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
    
    CIFilter * filter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
    [filter setDefaults];
    
    NSData * data = [urlStr dataUsingEncoding:NSUTF8StringEncoding];
    //通过kvo方式给一个字符串，生成二维码
    [filter setValue:data forKey:@"inputMessage"];
    //设置二维码的纠错水平，越高纠错水平越高，可以污损的范围越大
    [filter setValue:@"H" forKey:@"inputCorrectionLevel"];
    //拿到二维码图片
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
        // 4.给二维码加 logo 图
        UIGraphicsBeginImageContextWithOptions(qrImage.size, NO, 0);
        [qrImage drawInRect:CGRectMake(0, 0, qrCodeSize, qrCodeSize)];
        // 把logo图画到生成的二维码图片上，注意尺寸不要太大（最大不超过二维码图片的%30），太大会造成扫不出来
        [logoImage drawInRect:CGRectMake((qrCodeSize - logoSize) / 2.0, (qrCodeSize - logoSize) / 2.0, logoSize, logoSize)];
        UIImage * qrLogoImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return qrLogoImage;
    }
    
    return qrImage;
}


@end
