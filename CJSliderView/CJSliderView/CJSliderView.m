//
//  CJSliderView.m
//  CJSliderView
//
//  Created by CJ on 2017/8/22.
//  Copyright © 2017年 CJ. All rights reserved.
//

#import "CJSliderView.h"

@interface CJSliderView ()

@property (nonatomic, weak) UIView * backLineView;
@property (nonatomic, weak) UIView * progressView;
@property (nonatomic, weak) UILabel * numLabel;
@property (nonatomic, weak) UIButton * panButton;

@end

@implementation CJSliderView

-(instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        UIView * backLineView = [[UIView alloc]initWithFrame:CGRectMake(10, 50, self.frame.size.width - 20, 10)];
        backLineView.backgroundColor = [UIColor lightGrayColor];
        backLineView.layer.cornerRadius = 5;
        backLineView.layer.masksToBounds = YES;
        
        [self addSubview:backLineView];
        self.backLineView = backLineView;
        
        UIView * progressView = [[UIView alloc]initWithFrame:CGRectMake(10, 50, 0, 10)];
        progressView.backgroundColor = [UIColor cyanColor];
        progressView.layer.cornerRadius = 5;
        progressView.layer.masksToBounds = YES;
        
        [self addSubview:progressView];
        self.progressView = progressView;
        
        UIButton * panButton = [UIButton buttonWithType:UIButtonTypeCustom];
        panButton.frame = CGRectMake(10, 45, 20, 20);
        panButton.layer.cornerRadius = 10;
        panButton.layer.masksToBounds = YES;
        panButton.backgroundColor = [UIColor redColor];
        UIPanGestureRecognizer * pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
        [pan setMaximumNumberOfTouches:1];
        [panButton addGestureRecognizer:pan];
        
        [self addSubview:panButton];
        self.panButton = panButton;
        
        UILabel * numLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 10, 50, 20)];
        numLabel.center = CGPointMake(panButton.center.x, 20);
        numLabel.font = [UIFont boldSystemFontOfSize:20];
        numLabel.textAlignment = NSTextAlignmentCenter;
        numLabel.text = @"1000";
        numLabel.textColor = [UIColor blackColor];
        
        [self addSubview:numLabel];
        self.numLabel = numLabel;
    }
    return self;
}

- (void)panAction:(UIPanGestureRecognizer *)pan {
    
    CGPoint point = [pan locationInView:self];
    
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:{
            
            break;
        }
        case UIGestureRecognizerStateChanged:{
            
            CGFloat x = point.x;
            
            if (x <= 20) {
                x = 20;
            }
            
            if (x >= self.frame.size.width - 20) {
                x = self.frame.size.width - 20;
            }
            
            NSLog(@"%f",x);
            
            self.panButton.center = CGPointMake(x, 55);
            self.numLabel.center = CGPointMake(self.panButton.center.x, 20);
            self.progressView.frame = CGRectMake(10, 50, x - 10, 10);
            
            CGFloat count = 15;
            CGFloat radio = ((x - 20)/(self.frame.size.width - 40));
            
            NSInteger num = 500 + round(count * radio) * 100;
            
            self.numLabel.text = [NSString stringWithFormat:@"%ld",(long)num];
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:{
            
            break;
        }
        default:
            break;
    }
}

@end











