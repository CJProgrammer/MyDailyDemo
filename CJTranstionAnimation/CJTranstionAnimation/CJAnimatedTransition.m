//
//  CJAnimatedTransition.m
//  CJTranstionAnimation
//
//  Created by CJ on 2019/8/8.
//  Copyright © 2019 CJ. All rights reserved.
//

#import "CJAnimatedTransition.h"

@interface CJAnimatedTransition ()<CAAnimationDelegate>

//保存layer在动画结束的时候 可以根据这个来获取添加的动画
@property (nonatomic,strong) CAShapeLayer *maskShapeLayer;
//保存转场动画开始时的路径 当退出动画取消的时候 保存原理的样子
@property (nonatomic, strong) UIBezierPath *startPath;

@end

@implementation CJAnimatedTransition

//返回动画事件
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 2;
}

//所有的过渡动画事务都在这个方法里面完成
- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    
    switch (_transitionType) {
        case CJTransitionTypePresent:
            // 开门进入
//            [self openDoorDismissAnimation:transitionContext];
            // 翻书进入
//            [self turnPagePresentAnimation:transitionContext];
            // 扩散进入
            [self spreadDotPresentAnimation:transitionContext];
            break;
        case CJTransitionTypeDismiss:
            // 开门返回
//            [self openDoorDismissAnimation:transitionContext];
            // 翻书返回
//            [self turnPageDismissAnimation:transitionContext];
            // 扩散返回
            [self spreadDotDismissAnimation:transitionContext];
            break;
        case CJTransitionTypePush:
            [self pushAnimation:transitionContext];
            break;
        case CJTransitionTypePop:
            [self popAnimation:transitionContext];
            break;
    }
}

#pragma mark - 扩散

- (void)spreadDotPresentAnimation:(id <UIViewControllerContextTransitioning>)transitionContext {
    //获取目标动画的VC
    UIViewController *toVc = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toVc.view];
    
    //创建UIBezierPath路径 作为后面动画的起始路径
    UIBezierPath *startPath = [UIBezierPath bezierPathWithArcCenter:self.centerPoint radius:1 startAngle:0 endAngle:2*M_PI clockwise:YES];
    
    //创建结束UIBezierPath
    //首先我们需要得到后面路径的半径  半径应该是距四个角最远的距离
    CGFloat x = self.centerPoint.x;
    CGFloat y = self.centerPoint.y;
    //取出其中距屏幕最远的距离 来求围城矩形的对角线 即我们所需要的半径
    CGFloat radius_x = MAX(x, containerView.frame.size.width - x);
    CGFloat radius_y = MAX(y, containerView.frame.size.height - y);
    //补充下 sqrtf求平方根   double pow(double x, double y); 求 x 的 y 次幂（次方）
    //通过勾股定理算出半径
    CGFloat endRadius = sqrtf(pow(radius_x, 2) + pow(radius_y, 2));
    
    UIBezierPath *endPath = [UIBezierPath bezierPathWithArcCenter:self.centerPoint radius:endRadius startAngle:0 endAngle:2*M_PI clockwise:YES];
    
    //    self.endPath = endPath;
    
    //创建CAShapeLayer 用以后面的动画
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    shapeLayer.path = endPath.CGPath;
    toVc.view.layer.mask = shapeLayer;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.fromValue = (__bridge id _Nullable)(startPath.CGPath);
    animation.duration = [self transitionDuration:transitionContext];
    animation.delegate = (id)self;
    //保存contextTransition  后面动画结束的时候调用
    [animation setValue:transitionContext forKey:@"pathContextTransition"];
    [shapeLayer addAnimation:animation forKey:nil];
    
    self.maskShapeLayer = shapeLayer;
}

- (void)spreadDotDismissAnimation:(id <UIViewControllerContextTransitioning>)transitionContext {
    //将tovc的view放到最下面一层
    UIViewController *toVc = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    UIViewController *fromVc = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    [containerView insertSubview:toVc.view atIndex:0];
    
    //push前的 startPath 作为endPath
    UIBezierPath *endPath = [UIBezierPath bezierPathWithArcCenter:self.centerPoint radius:1 startAngle:0 endAngle:2*M_PI clockwise:YES];
    
    CAShapeLayer *shapeLayer = (CAShapeLayer *)fromVc.view.layer.mask;
    self.maskShapeLayer = shapeLayer;
    //将pop后的 path作为startPath
    UIBezierPath *startPath = [UIBezierPath bezierPathWithCGPath:shapeLayer.path];
    self.startPath = startPath;
    shapeLayer.path = endPath.CGPath;
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    animation.fromValue = (__bridge id _Nullable)(startPath.CGPath);
    animation.toValue = (__bridge id _Nullable)(endPath.CGPath);
    animation.duration = [self transitionDuration:transitionContext];
    animation.delegate = (id)self;
    //保存transitionContext  后面动画结束的时候调用
    [animation setValue:transitionContext forKey:@"pathContextTransition"];
    [shapeLayer addAnimation:animation forKey:nil];
}

#pragma mark - CAAnimationDelegate

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    id<UIViewControllerContextTransitioning> transitionContext = [anim valueForKey:@"pathContextTransition"];
    
    //取消的时候 将动画还原到之前的路径
    if (transitionContext.transitionWasCancelled) {
        self.maskShapeLayer.path = self.startPath.CGPath;
    }
    // 声明过渡结束
    [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
}

#pragma mark - 翻书

//- (void)turnPagePresentAnimation:(id <UIViewControllerContextTransitioning>)transitionContext {
//    //获取目标动画的VC
//    UIViewController *toVc = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
//    UIViewController *fromVc = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
//    UIView *containerView = [transitionContext containerView];
//
//    //m34 这个参数有点不好理解  为透视效果 我在http://www.jianshu.com/p/e8d1985dccec这里有讲
//    //当Z轴上有变化的时候 我们所看到的透视效果 可以对比看看 当你改成-0.1的时候 就懂了
//    CATransform3D transform = CATransform3DIdentity;
//    transform.m34 = -0.002;
//    [containerView.layer setSublayerTransform:transform];
//
//    UIView *fromView = fromVc.view;
//    UIView *toView = toVc.view;
//
//    //截图
//    //当前页面
//    CGRect from_rect = CGRectMake( 0, 0, fromView.frame.size.width, fromView.frame.size.height);
//    //目标页面
//    CGRect to_rect = CGRectMake( 0, 0, toView.frame.size.width, toView.frame.size.height);
//
//    //截三张图 当前页面 目标页面
//    UIView *fromSnapView = [fromView resizableSnapshotViewFromRect:from_rect afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
//    UIView *toSnapView = [toView resizableSnapshotViewFromRect:to_rect afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
//
//    fromSnapView.frame = from_rect;
//    toSnapView.frame = to_rect;
//
//    //添加阴影效果
//
//    UIView *fromShadowView = [self addShadowView:fromSnapView startPoint:CGPointMake(0, 1) endPoint:CGPointMake(1, 1)];
//    UIView *toShaDowView = [self addShadowView:toSnapView startPoint:CGPointMake(1, 1) endPoint:CGPointMake(0, 1)];
//
//    //添加视图  注意顺序
//    [containerView insertSubview:toView atIndex:0];
//    [containerView addSubview:toSnapView];
//    [containerView addSubview:fromSnapView];
//
//    fromView.hidden = YES;
//    toView.hidden = YES;
//    toSnapView.hidden = YES;
//
//    //先旋转到最中间的位置
//    toSnapView.layer.transform = CATransform3DMakeRotation(M_PI_2, 0, 1, 0);
//    //StartTime 和 relativeDuration 均为百分百
//    [UIView animateKeyframesWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
//        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5 animations:^{
//            fromSnapView.layer.transform = CATransform3DMakeRotation(-M_PI_2, 0, 1, 0);
//            fromShadowView.alpha = 1.0;
//        }];
//
//        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
//            toSnapView.hidden = NO;
//            toSnapView.layer.transform = CATransform3DIdentity;
//            toShaDowView.alpha = 0.0;
//        }];
//    } completion:^(BOOL finished) {
//        [toSnapView removeFromSuperview];
//        [fromSnapView removeFromSuperview];
//        [fromView removeFromSuperview];
//        fromView.hidden = NO;
//        toView.hidden = NO;
//        if ([transitionContext transitionWasCancelled]) {
//            [containerView addSubview:fromView];
//        }
//
//        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
//    }];
//}

- (void)turnPagePresentAnimation:(id <UIViewControllerContextTransitioning>)transitionContext {
    //获取目标动画的VC
    UIViewController *toVc = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVc = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *containerView = [transitionContext containerView];

    //m34 这个参数有点不好理解  为透视效果 我在http://www.jianshu.com/p/e8d1985dccec这里有讲
    //当Z轴上有变化的时候 我们所看到的透视效果 可以对比看看 当你改成-0.1的时候 就懂了
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -0.002;
    [containerView.layer setSublayerTransform:transform];

    UIView *fromView = fromVc.view;
    UIView *toView = toVc.view;

    //截图
    //当前页面的右侧
    CGRect from_half_right_rect = CGRectMake(fromView.frame.size.width/2.0, 0, fromView.frame.size.width/2.0, fromView.frame.size.height);
    //目标页面的左侧
    CGRect to_half_left_rect = CGRectMake(0, 0, toView.frame.size.width/2.0, toView.frame.size.height);
    //目标页面的右侧
    CGRect to_half_right_rect = CGRectMake(toView.frame.size.width/2.0, 0, toView.frame.size.width/2.0, toView.frame.size.height);

    //截三张图 当前页面的右侧 目标页面的左和右
    UIView *fromRightSnapView = [fromView resizableSnapshotViewFromRect:from_half_right_rect afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
    UIView *toLeftSnapView = [toView resizableSnapshotViewFromRect:to_half_left_rect afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
    UIView *toRightSnapView = [toView resizableSnapshotViewFromRect:to_half_right_rect afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];


    fromRightSnapView.frame = from_half_right_rect;
    toLeftSnapView.frame = to_half_left_rect;
    toRightSnapView.frame = to_half_right_rect;

    //重新设置anchorPoint  分别绕自己的最左和最右旋转
    fromRightSnapView.layer.position = CGPointMake(CGRectGetMinX(fromRightSnapView.frame), CGRectGetMinY(fromRightSnapView.frame) + CGRectGetHeight(fromRightSnapView.frame) * 0.5);
    fromRightSnapView.layer.anchorPoint = CGPointMake(0, 0.5);

    toLeftSnapView.layer.position = CGPointMake(CGRectGetMinX(toLeftSnapView.frame) + CGRectGetWidth(toLeftSnapView.frame), CGRectGetMinY(toLeftSnapView.frame) + CGRectGetHeight(toLeftSnapView.frame) * 0.5);
    toLeftSnapView.layer.anchorPoint = CGPointMake(1, 0.5);

    //添加阴影效果
    UIView *fromRightShadowView = [self addShadowView:fromRightSnapView startPoint:CGPointMake(0, 1) endPoint:CGPointMake(1, 1)];
    UIView *toLeftShaDowView = [self addShadowView:toLeftSnapView startPoint:CGPointMake(1, 1) endPoint:CGPointMake(0, 1)];

    //添加视图  注意顺序
    [containerView insertSubview:toView atIndex:0];
    [containerView addSubview:toLeftSnapView];
    [containerView addSubview:toRightSnapView];
    [containerView addSubview:fromRightSnapView];

    toLeftSnapView.hidden = YES;

    //先旋转到最中间的位置
    toLeftSnapView.layer.transform = CATransform3DMakeRotation(M_PI_2, 0, 1, 0);
    //StartTime 和 relativeDuration 均为百分百
    [UIView animateKeyframesWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5 animations:^{

            fromRightSnapView.layer.transform = CATransform3DMakeRotation(-M_PI_2, 0, 1, 0);
            fromRightShadowView.alpha = 1.0;
        }];

        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
            toLeftSnapView.hidden = NO;
            toLeftSnapView.layer.transform = CATransform3DIdentity;
            toLeftShaDowView.alpha = 0.0;
        }];
    } completion:^(BOOL finished) {
        [toLeftSnapView removeFromSuperview];
        [toRightSnapView removeFromSuperview];
        [fromRightSnapView removeFromSuperview];
        [fromView removeFromSuperview];

        if ([transitionContext transitionWasCancelled]) {
            [containerView addSubview:fromView];
        }

        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

- (void)turnPageDismissAnimation:(id <UIViewControllerContextTransitioning>)transitionContext {
    //获取目标动画的VC
    UIViewController *toVc = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVc = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    //m34 这个参数有点不好理解  为透视效果 我在http://www.jianshu.com/p/e8d1985dccec这里有讲
    //当Z轴上有变化的时候 我们所看到的透视效果 可以对比看看 当你改成-0.1的时候 就懂了
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = -0.002;
    [containerView.layer setSublayerTransform:transform];
    
    UIView *fromView = fromVc.view;
    UIView *toView = toVc.view;
    
    //截图
    //当前页面的右侧
    CGRect from_half_left_rect = CGRectMake(0, 0, fromView.frame.size.width/2.0, fromView.frame.size.height);
    //目标页面的左侧
    CGRect to_half_left_rect = CGRectMake(0, 0, toView.frame.size.width/2.0, toView.frame.size.height);
    //目标页面的右侧
    CGRect to_half_right_rect = CGRectMake(toView.frame.size.width/2.0, 0, toView.frame.size.width/2.0, toView.frame.size.height);
    
    //截三张图 当前页面的右侧 目标页面的左和右
    UIView *fromLeftSnapView = [fromView resizableSnapshotViewFromRect:from_half_left_rect afterScreenUpdates:NO withCapInsets:UIEdgeInsetsZero];
    UIView *toLeftSnapView = [toView resizableSnapshotViewFromRect:to_half_left_rect afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
    UIView *toRightSnapView = [toView resizableSnapshotViewFromRect:to_half_right_rect afterScreenUpdates:YES withCapInsets:UIEdgeInsetsZero];
    
    
    fromLeftSnapView.frame = from_half_left_rect;
    toLeftSnapView.frame = to_half_left_rect;
    toRightSnapView.frame = to_half_right_rect;
    
    //重新设置anchorPoint  分别绕自己的最左和最右旋转
    fromLeftSnapView.layer.position = CGPointMake(CGRectGetMinX(fromLeftSnapView.frame) + CGRectGetWidth(fromLeftSnapView.frame), CGRectGetMinY(fromLeftSnapView.frame) + CGRectGetHeight(fromLeftSnapView.frame) * 0.5);
    fromLeftSnapView.layer.anchorPoint = CGPointMake(1, 0.5);
    
    toRightSnapView.layer.position = CGPointMake(CGRectGetMinX(toRightSnapView.frame), CGRectGetMinY(toRightSnapView.frame) + CGRectGetHeight(toRightSnapView.frame) * 0.5);
    toRightSnapView.layer.anchorPoint = CGPointMake(0, 0.5);
    
    //添加阴影效果
    
    UIView *fromLeftShadowView = [self addShadowView:fromLeftSnapView startPoint:CGPointMake(1, 1) endPoint:CGPointMake(0, 1)];
    UIView *toRightShaDowView = [self addShadowView:toRightSnapView startPoint:CGPointMake(0, 1) endPoint:CGPointMake(1, 1)];
    
    //添加视图  注意顺序
    [containerView insertSubview:toView atIndex:0];
    [containerView addSubview:toLeftSnapView];
    [containerView addSubview:toRightSnapView];
    [containerView addSubview:fromLeftSnapView];
    
    toRightSnapView.hidden = YES;
    
    
    //先旋转到最中间的位置
    toRightSnapView.layer.transform = CATransform3DMakeRotation(-M_PI_2, 0, 1, 0);
    //StartTime 和 relativeDuration 均为百分百
    [UIView animateKeyframesWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        [UIView addKeyframeWithRelativeStartTime:0 relativeDuration:0.5 animations:^{
            
            fromLeftSnapView.layer.transform = CATransform3DMakeRotation(M_PI_2, 0, 1, 0);
            fromLeftShadowView.alpha = 1.0;
        }];
        
        [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
            toRightSnapView.hidden = NO;
            toRightSnapView.layer.transform = CATransform3DIdentity;
            toRightShaDowView.alpha = 0.0;
        }];
    } completion:^(BOOL finished) {
        [toLeftSnapView removeFromSuperview];
        [toRightSnapView removeFromSuperview];
        [fromLeftSnapView removeFromSuperview];
        [fromView removeFromSuperview];
        
        if ([transitionContext transitionWasCancelled]) {
            [containerView addSubview:fromView];
        }
        
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

- (UIView *)addShadowView:(UIView *)view startPoint:(CGPoint)startPoint endPoint:(CGPoint)endPoint{
    UIView *shadowView = [[UIView alloc] initWithFrame:view.bounds];
    [view addSubview:shadowView];
    //颜色可以渐变
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = shadowView.bounds;
    [shadowView.layer addSublayer:gradientLayer];
    gradientLayer.colors = @[(id)[UIColor colorWithWhite:0 alpha:0.1].CGColor,(id)[UIColor colorWithWhite:0 alpha:0].CGColor];
    gradientLayer.startPoint = startPoint;
    gradientLayer.endPoint = endPoint;
    
    return shadowView;
}

#pragma mark - 开门

- (void)openDoorPresentAnimation:(id <UIViewControllerContextTransitioning>)transitionContext {
    //获取目标动画的VC
    UIViewController *toVc = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVc = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    UIView *fromView = fromVc.view;
    UIView *toView = toVc.view;
    
    //截图
    UIView *toView_snapView = [toView snapshotViewAfterScreenUpdates:YES];
    
    CGRect left_frame = CGRectMake(0, 0, CGRectGetWidth(fromView.frame) / 2.0, CGRectGetHeight(fromView.frame));
    CGRect right_frame = CGRectMake(CGRectGetWidth(fromView.frame) / 2.0, 0, CGRectGetWidth(fromView.frame) / 2.0, CGRectGetHeight(fromView.frame));
    UIView *from_left_snapView = [fromView resizableSnapshotViewFromRect:left_frame
                                                      afterScreenUpdates:NO
                                                           withCapInsets:UIEdgeInsetsZero];
    
    UIView *from_right_snapView = [fromView resizableSnapshotViewFromRect:right_frame
                                                       afterScreenUpdates:NO
                                                            withCapInsets:UIEdgeInsetsZero];
    
    toView_snapView.layer.transform = CATransform3DMakeScale(0.7, 0.7, 1);
    from_left_snapView.frame = left_frame;
    from_right_snapView.frame = right_frame;
    
    //将截图添加到 containerView 上
    [containerView addSubview:toView_snapView];
    [containerView addSubview:from_left_snapView];
    [containerView addSubview:from_right_snapView];
    
    fromView.hidden = YES;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        //左移
        from_left_snapView.frame = CGRectOffset(from_left_snapView.frame, -from_left_snapView.frame.size.width, 0);
        //右移
        from_right_snapView.frame = CGRectOffset(from_right_snapView.frame, from_right_snapView.frame.size.width, 0);
        
        toView_snapView.layer.transform = CATransform3DIdentity;
        
    } completion:^(BOOL finished) {
        fromView.hidden = NO;
        
        [from_left_snapView removeFromSuperview];
        [from_right_snapView removeFromSuperview];
        [toView_snapView removeFromSuperview];
        
        if ([transitionContext transitionWasCancelled]) {
            [containerView addSubview:fromView];
        } else {
            [containerView addSubview:toView];
        }
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

- (void)openDoorDismissAnimation:(id <UIViewControllerContextTransitioning>)transitionContext {
    //获取目标动画的VC
    UIViewController *toVc = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController *fromVc = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIView *containerView = [transitionContext containerView];
    
    UIView *fromView = fromVc.view;
    UIView *toView = toVc.view;
    
    //截图
    UIView *fromView_snapView = [fromView snapshotViewAfterScreenUpdates:YES];
    
    
    CGRect left_frame = CGRectMake(0, 0, CGRectGetWidth(toView.frame) / 2.0, CGRectGetHeight(toView.frame));
    CGRect right_frame = CGRectMake(CGRectGetWidth(toView.frame) / 2.0, 0, CGRectGetWidth(toView.frame) / 2.0, CGRectGetHeight(toView.frame));
    UIView *to_left_snapView = [toView resizableSnapshotViewFromRect:left_frame
                                                  afterScreenUpdates:YES
                                                       withCapInsets:UIEdgeInsetsZero];
    
    UIView *to_right_snapView = [toView resizableSnapshotViewFromRect:right_frame
                                                   afterScreenUpdates:YES
                                                        withCapInsets:UIEdgeInsetsZero];
    
    fromView_snapView.layer.transform = CATransform3DIdentity;
    to_left_snapView.frame = CGRectOffset(left_frame, -left_frame.size.width, 0);
    to_right_snapView.frame = CGRectOffset(right_frame, right_frame.size.width, 0);
    
    //将截图添加到 containerView 上
    [containerView addSubview:fromView_snapView];
    [containerView addSubview:to_left_snapView];
    [containerView addSubview:to_right_snapView];
    
    fromView.hidden = YES;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        //右移
        to_left_snapView.frame = CGRectOffset(to_left_snapView.frame, to_left_snapView.frame.size.width, 0);
        //左移
        to_right_snapView.frame = CGRectOffset(to_right_snapView.frame, -to_right_snapView.frame.size.width, 0);
        
        fromView_snapView.layer.transform = CATransform3DMakeScale(0.7, 0.7, 1);
        
    } completion:^(BOOL finished) {
        fromView.hidden = NO;
        [fromView removeFromSuperview];
        [to_left_snapView removeFromSuperview];
        [to_right_snapView removeFromSuperview];
        [fromView_snapView removeFromSuperview];
        
        if ([transitionContext transitionWasCancelled]) {
            [containerView addSubview:fromView];
        } else {
            [containerView addSubview:toView];
        }
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];
    }];
}

- (void)pushAnimation:(id <UIViewControllerContextTransitioning>)transitionContext {
    
}

- (void)popAnimation:(id <UIViewControllerContextTransitioning>)transitionContext {
    
}

@end
