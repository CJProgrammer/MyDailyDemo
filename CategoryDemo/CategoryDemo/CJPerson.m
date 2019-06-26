//
//  CJPerson.m
//  CategoryDemo
//
//  Created by CJ on 2019/6/18.
//  Copyright © 2019 CJ. All rights reserved.
//

#import "CJPerson.h"

@implementation CJPerson

+ (void)load {
    NSLog(@"CJPerson ++ load");
}

+ (void)initialize {
    NSLog(@"CJPerson ++ initialize");
}

- (void)eat {
    NSLog(@"CJPerson -- %@",NSStringFromSelector(_cmd));
}

- (void)drink {
    NSLog(@"CJPerson -- %@",NSStringFromSelector(_cmd));
}

+ (void)run {
    NSLog(@"CJPerson ++ %@",NSStringFromSelector(_cmd));
}

@end
