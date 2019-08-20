//
//  CJForeOpenDoorViewController.m
//  CJTranstionAnimation
//
//  Created by CJ on 2019/8/8.
//  Copyright © 2019 CJ. All rights reserved.
//

#import "CJForeOpenDoorViewController.h"
#import "CJOpenDoorViewController.h"

@interface CJForeOpenDoorViewController ()

@property (nonatomic, strong) UIImageView *backImageView;

@end

@implementation CJForeOpenDoorViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _backImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _backImageView.image = [UIImage imageNamed:@"cj3"];
    _backImageView.userInteractionEnabled = YES;
    [self.view addSubview:_backImageView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openDoor:)];
    [_backImageView addGestureRecognizer:tap];
}

- (void)openDoor:(UITapGestureRecognizer *)tap {
    CGPoint point = [tap locationInView:self.view];
    CJOpenDoorViewController *openDoorVC = [[CJOpenDoorViewController alloc] init];
    openDoorVC.centerPoint = point;
    [self presentViewController:openDoorVC animated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
