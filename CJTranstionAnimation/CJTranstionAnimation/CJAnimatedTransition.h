//
//  CJAnimatedTransition.h
//  CJTranstionAnimation
//
//  Created by CJ on 2019/8/8.
//  Copyright © 2019 CJ. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CJTransitionType) {
    /// present
    CJTransitionTypePresent = 0,
    /// dismiss
    CJTransitionTypeDismiss,
    /// push
    CJTransitionTypePush,
    /// pop
    CJTransitionTypePop
};

NS_ASSUME_NONNULL_BEGIN

@interface CJAnimatedTransition : NSObject <UIViewControllerAnimatedTransitioning>

@property (nonatomic, assign) CJTransitionType transitionType;
// 动画的中心坐标
@property (nonatomic, assign) CGPoint centerPoint;

@end

NS_ASSUME_NONNULL_END
