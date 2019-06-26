//
//  CJPerson+Two.m
//  CategoryDemo
//
//  Created by CJ on 2019/6/24.
//  Copyright © 2019 CJ. All rights reserved.
//

#import "CJPerson+Two.h"

@implementation CJPerson (Two)

+ (void)load {
    NSLog(@"Two ++ load");
}

+ (void)initialize {
    NSLog(@"Two ++ initialize");
}

- (void)eat {
    NSLog(@"Two -- %@",NSStringFromSelector(_cmd));
}

- (void)drink {
    NSLog(@"Two -- %@",NSStringFromSelector(_cmd));
}

+ (void)run {
    NSLog(@"Two ++ %@",NSStringFromSelector(_cmd));
}

@end
