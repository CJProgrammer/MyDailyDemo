//
//  LJNavigationBarItemControl.h
//  LJNavigationBar
//
//  Created by CJ on 2019/4/2.
//

#import <UIKit/UIKit.h>

@interface LJNavigationBarItemControl : UIControl

/** 图片 */
@property (nonatomic, strong) UIImage *itemImage;

/**
 更新红点显隐状态
 
 @param hidden 是否隐藏
 */
- (void)updateRedDotStatus:(BOOL)hidden;

@end
