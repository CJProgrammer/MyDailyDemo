//
//  ViewController.m
//  Core Foundation
//
//  Created by 耳东米青 on 2017/3/9.
//  Copyright © 2017年 耳东米青. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (void)bridgeOCToCF
{
    NSString * nsstr = [[NSString alloc]initWithFormat:@"CJProgrammer"];
    CFStringRef cfstr = (__bridge CFStringRef)nsstr;
    //告诉编译器，这个变量我（假装）使用了，不要提示变量未使用的警告。
    (void)cfstr;
}

- (void)bridgeCFToOC
{
    CFStringRef cfstr = CFStringCreateWithCString(NULL, "CJProgrammer", kCFStringEncodingASCII);
    NSString * nsstr = (__bridge NSString *)cfstr;
    
    (void)nsstr;
    
    CFRelease(cfstr);
}

- (void)bridge_retained
{
    NSString * nsstr = [[NSString alloc]initWithFormat:@"CJProgrammer"];
    CFStringRef cfstr = (CFStringRef)CFBridgingRetain(nsstr);
//    CFStringRef cfstr = (__bridge_retained CFStringRef)nsstr;
    
    (void)cfstr;
    
    CFRelease(cfstr);
}


- (void)bridge_transfer
{
    CFStringRef cfstr = CFStringCreateWithCString(NULL, "CJProgrammer", kCFStringEncodingASCII);
//    NSString * nsstr = (__bridge_transfer NSString *)cfstr;
    NSString * nsstr = (NSString *)CFBridgingRelease(cfstr);
    (void)nsstr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end







