//
//  ViewController.m
//  CJSliderView
//
//  Created by CJ on 2017/8/22.
//  Copyright © 2017年 CJ. All rights reserved.
//

#import "ViewController.h"
#import "CJSliderView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    CJSliderView * slider = [[CJSliderView alloc]initWithFrame:CGRectMake(50, 100, self.view.frame.size.width - 100, 100)];
    slider.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:slider];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
