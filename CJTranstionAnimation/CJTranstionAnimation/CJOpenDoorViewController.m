//
//  CJOpenDoorViewController.m
//  CJTranstionAnimation
//
//  Created by CJ on 2019/8/8.
//  Copyright © 2019 CJ. All rights reserved.
//

#import "CJOpenDoorViewController.h"
#import "CJAnimatedTransition.h"

@interface CJOpenDoorViewController () <UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) CJAnimatedTransition *animatedTransition;
@property (nonatomic, strong) UIImageView *backImageView;

@end

@implementation CJOpenDoorViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.transitioningDelegate = self;
    
    _animatedTransition = [[CJAnimatedTransition alloc] init];
    _animatedTransition.centerPoint = _centerPoint;
    
    // 背景图片
    _backImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _backImageView.image = [UIImage imageNamed:@"cj2"];
    _backImageView.userInteractionEnabled = YES;
    [self.view addSubview:_backImageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [_backImageView addGestureRecognizer:tap];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    _animatedTransition.transitionType = CJTransitionTypePresent;
    return _animatedTransition;
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    _animatedTransition.transitionType = CJTransitionTypeDismiss;
    return _animatedTransition;
}

@end
