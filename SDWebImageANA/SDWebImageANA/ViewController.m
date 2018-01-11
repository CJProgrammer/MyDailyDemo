//
//  ViewController.m
//  SDWebImageANA
//
//  Created by CJ on 2017/12/27.
//  Copyright © 2017年 CJ. All rights reserved.
//

#import "ViewController.h"
#import "UIImageView+WebCache.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    UIImageView * imageView = [[UIImageView alloc]init];
    [imageView sd_setImageWithURL:[NSURL URLWithString:@"CJ"] placeholderImage:[UIImage imageNamed:@"CJ"]];
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
