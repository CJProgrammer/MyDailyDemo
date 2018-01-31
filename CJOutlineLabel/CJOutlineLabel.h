//
//  CJOutlineLabel.h
//  VBlockChain
//
//  Created by CJ on 2018/1/31.
//  Copyright © 2018年 CJ. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CJOutlineLabel : UILabel

/** 描多粗的边*/
@property (nonatomic, assign) CGFloat outLineWidth;

/** 外轮颜色*/
@property (nonatomic, strong) UIColor * outLineColor;

/** 里面字体默认颜色*/
@property (nonatomic, strong) UIColor * labelTextColor;


@end
