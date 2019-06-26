//
//  ViewController.m
//  CategoryDemo
//
//  Created by CJ on 2019/6/17.
//  Copyright © 2019 CJ. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
#import "CJPerson.h"
#import "CJPerson+One.h"
#import "CJSon.h"
#import "CJDaughter.h"

@interface ViewController ()

@property (nonatomic, strong) CJPerson *p;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    _p = [CJPerson new];
    
    [CJPerson test];
    
//    NSLog(@"%ld",(long)aaa);
    

//    [CJPerson run];
//    [[CJPerson new] eat];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    NSLog(@"%p", _p.name);
}

@end
