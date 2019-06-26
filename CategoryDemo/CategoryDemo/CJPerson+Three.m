//
//  CJPerson+Three.m
//  CategoryDemo
//
//  Created by CJ on 2019/6/24.
//  Copyright © 2019 CJ. All rights reserved.
//

#import "CJPerson+Three.h"

@implementation CJPerson (Three)

+ (void)load {
    NSLog(@"Three ++ load");
}

+ (void)initialize {
    NSLog(@"Three ++ initialize");
}

- (void)eat {
    NSLog(@"Three -- %@",NSStringFromSelector(_cmd));
}

- (void)drink {
    NSLog(@"Three -- %@",NSStringFromSelector(_cmd));
}

+ (void)run {
    NSLog(@"Three ++ %@",NSStringFromSelector(_cmd));
}

@end
