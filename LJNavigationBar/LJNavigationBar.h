//
//  LJNavigationBar.h
//  Lianjia_Beike_Home
//
//  Created by CJ on 2019/3/28.
//

#import <UIKit/UIKit.h>
#import "LJNavigationBarDelegate.h"

typedef NS_ENUM(NSInteger, LJNavigationBarType) {
    LJNavigationBarType01,                // 1:搜索框-图文区
    LJNavigationBarType02,                // 2:搜索框
    LJNavigationBarType03,                // 3:搜索框-自定义功能
    LJNavigationBarType04,                // 4:切换区-搜索框-自定义功能
    LJNavigationBarType05,                // 5:item-搜索框
    LJNavigationBarType06,                // 6:item-搜索框-自定义功能
    LJNavigationBarType07,                // 7:item-搜索框-红点item
    LJNavigationBarType08,                // 8:item-切换区-搜索框-item
    LJNavigationBarType09                 // 9:item-搜索框-item-item
};

typedef NS_ENUM(NSInteger, LJNavigationBarInputType) {
    LJNavigationBarInputTypeClick,        // 点击跳转，不可输入
    LJNavigationBarInputTypeInput,        // 可输入框
};

@interface LJNavigationBar : UIView

/** input textField */
@property (nonatomic, strong) UITextField *inputTextField;
/** 代理 */
@property (nonatomic, weak) id <LJNavigationBarDelegate>delegate;
/** 默认展示文案或输入框占位文案 默认：你想住在哪？ */
@property (nonatomic, copy) NSString *defaultText;
/** 图文区图片 */
@property (nonatomic, strong) UIImage *imageTextImage;
/** 图文区标题 */
@property (nonatomic, copy) NSString *imageTextTitle;
/** 右边功能按钮文案 */
@property (nonatomic, copy) NSString *rightFunctionText;
/** 切换区文案 */
@property (nonatomic, copy) NSString *switchTitleText;
/** 左边第一个item图片 */
@property (nonatomic, strong) UIImage *leftFirstItemImage;
/** 右边第一个item图片 */
@property (nonatomic, strong) UIImage *rightFirstItemImage;
/** 右边第二个item图片 */
@property (nonatomic, strong) UIImage *rightSecondItemImage;

/**
 初始化

 @param navBarType 导航栏类型
 @param inputType  输入框类型
 @return self
 */
- (instancetype)initWithNavBarType:(LJNavigationBarType)navBarType inputType:(LJNavigationBarInputType)inputType;

/**
 更新右边第一个item红点显隐状态

 @param hidden 是否隐藏
 */
- (void)updateRightFirstItemRedDotStatus:(BOOL)hidden;

/**
 更新右边第二个item红点显隐状态
 
 @param hidden 是否隐藏
 */
- (void)updateRightSecondItemRedDotStatus:(BOOL)hidden;

@end
