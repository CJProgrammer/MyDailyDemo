//
//  CJSon.m
//  CategoryDemo
//
//  Created by CJ on 2019/6/24.
//  Copyright © 2019 CJ. All rights reserved.
//

#import "CJSon.h"

@implementation CJSon

+ (void)load {
    NSLog(@"CJSon ++ load");
}

+ (void)initialize {
    NSLog(@"CJSon ++ initialize");
}

- (void)eat {
    NSLog(@"CJSon -- %@",NSStringFromSelector(_cmd));
}

- (void)drink {
    NSLog(@"CJSon -- %@",NSStringFromSelector(_cmd));
}

+ (void)run {
    NSLog(@"CJSon ++ %@",NSStringFromSelector(_cmd));
}

@end
