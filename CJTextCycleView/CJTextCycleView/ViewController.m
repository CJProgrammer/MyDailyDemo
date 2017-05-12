//
//  ViewController.m
//  CJTextCycleView
//
//  Created by CJ on 2017/5/12.
//  Copyright © 2017年 CJ. All rights reserved.
//

#import "ViewController.h"
#import "CJTextCycleView.h"

@interface ViewController ()

@property (nonatomic, strong) CJTextCycleView * textCycleView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor grayColor];
    
    self.textCycleView = [[CJTextCycleView alloc]initWithFrame:CGRectMake(50, 150, self.view.frame.size.width - 50, 50)];
    
    [self.view addSubview:self.textCycleView];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
