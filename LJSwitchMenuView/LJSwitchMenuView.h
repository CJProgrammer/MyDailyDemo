//
//  LJSwitchMenuView.h
//  Lianjia_Beike_Home
//
//  Created by CJ on 2019/4/3.
//

#import <UIKit/UIKit.h>

@protocol LJSwitchMenuViewDelegate <NSObject>

/**
 选中菜单

 @param index 选中的index
 @param title 选中的内容
 */
- (void)switchMenuDidSelectAtIndex:(NSInteger)index title:(NSString *)title;

@end

@interface LJSwitchMenuView : UIView

@property (nonatomic, weak) id <LJSwitchMenuViewDelegate>delegate;

/**
 初始化

 @param titles 标题数组
 @param originPoint 切换菜单控件的origin
 @param mySuperView superView
 @return self
 */
- (instancetype)initWithTitles:(NSArray *)titles originPoint:(CGPoint)originPoint inSuperView:(UIView *)mySuperView;

// show
- (void)show;

// hide
- (void)hide;

@end

