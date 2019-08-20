//
//  ViewController.m
//  CJTranstionAnimation
//
//  Created by CJ on 2019/8/8.
//  Copyright © 2019 CJ. All rights reserved.
//

#import "ViewController.h"
#import "CJForeOpenDoorViewController.h"
#import "CJDotView.h"

@interface ViewController ()

@property (nonatomic, strong) UIImageView *backImageView;
@property (nonatomic, strong) UIButton *openDoorButton;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.hidden = YES;
    
    CJDotView *dotView = [[CJDotView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
    dotView.center = self.view.center;
    [self.view addSubview:dotView];
    
    
//    _backImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
//    _backImageView.image = [UIImage imageNamed:@"cj1"];
//    [self.view addSubview:_backImageView];
//
//    _openDoorButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    _openDoorButton.frame = CGRectMake(0, 0, self.view.frame.size.width, 100);
//    _openDoorButton.backgroundColor = [UIColor cyanColor];
//    [_openDoorButton setTitle:@"开门效果" forState:UIControlStateNormal];
//    [_openDoorButton addTarget:self action:@selector(openDoor) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:_openDoorButton];
}

- (void)openDoor {
    CJForeOpenDoorViewController *foreOpenDoorVC = [[CJForeOpenDoorViewController alloc] init];
    [self.navigationController pushViewController:foreOpenDoorVC animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
}

@end
