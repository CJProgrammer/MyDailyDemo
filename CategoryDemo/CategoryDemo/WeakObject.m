//
//  WeakObject.m
//  CategoryDemo
//
//  Created by CJ on 2019/6/25.
//  Copyright © 2019 CJ. All rights reserved.
//

#import "WeakObject.h"

@implementation WeakObject

- (instancetype)initWithBlock:(DeallocBlock)block
{
    self = [super init];
    if (self) {
        self.block = block;
    }
    return self;
}

- (void)dealloc {
    self.block ? self.block() : nil;
}

@end
