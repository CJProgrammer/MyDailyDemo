//
//  CJDotView.m
//  CJTranstionAnimation
//
//  Created by CJ on 2019/8/19.
//  Copyright © 2019 CJ. All rights reserved.
//

#import "CJDotView.h"

@interface CJDotView ()

@property (nonatomic, strong) UIView *subView1;

@end

@implementation CJDotView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.layer.cornerRadius = 20;
        
        _subView1 = [[UIView alloc] initWithFrame:CGRectMake(8, 8, 64, 64)];
        _subView1.backgroundColor = [UIColor darkGrayColor];
        _subView1.layer.cornerRadius = 32;
        _subView1.layer.borderColor = [UIColor blackColor].CGColor;
        _subView1.layer.borderWidth = 1;
        [self addSubview:_subView1];
        
        UIView *subView2 = [[UIView alloc] initWithFrame:CGRectMake(12, 12, 56, 56)];
        subView2.backgroundColor = [UIColor lightGrayColor];
        subView2.layer.cornerRadius = 28;
        subView2.layer.borderColor = [UIColor blackColor].CGColor;
        subView2.layer.borderWidth = 1;
        [self addSubview:subView2];
        
        UIView *subView3 = [[UIView alloc] initWithFrame:CGRectMake(16, 16, 48, 48)];
        subView3.backgroundColor = [UIColor whiteColor];
        subView3.layer.cornerRadius = 24;
        subView3.layer.borderColor = [UIColor blackColor].CGColor;
        subView3.layer.borderWidth = 1;
        [self addSubview:subView3];
    }
    return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.backgroundColor = [UIColor orangeColor];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.backgroundColor = [UIColor cyanColor];
    UITouch *touch = [touches anyObject];
    CGPoint currentLocation = [touch locationInView:self.superview];
    self.center = currentLocation;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    self.backgroundColor = [UIColor blackColor];
}

@end
