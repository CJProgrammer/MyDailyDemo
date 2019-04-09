//
//  LJNavigationBarDelegate.h
//  Pods
//
//  Created by 赵文成 on 2019/4/2.
//

#ifndef LJNavigationBarDelegate_h
#define LJNavigationBarDelegate_h

@protocol LJNavigationBarDelegate <NSObject>

@optional

/** 点击搜索 */
- (void)navBarDidClickSearch;

/** 1:点击城市 */
- (void)navBarDidClickImageText;

/** 3、4、6:点击右边按钮 */
- (void)navBarDidClickRightFunction;

/** 4、8:点击切换区 */
- (void)navBarDidClickSwitch;

/** 5-9:点击左边第一个item */
- (void)navBarDidClickLeftFirstItem;

/** 7、8、9:点击右边第一个item */
- (void)navBarDidClickRightFirstItem;

/** 9:点击右边第二个item */
- (void)navBarDidClickRightSecondItem;

@end

#endif /* LJNavigationBarDelegate_h */
