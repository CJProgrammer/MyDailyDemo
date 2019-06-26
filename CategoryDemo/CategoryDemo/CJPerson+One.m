//
//  CJPerson+One.m
//  CategoryDemo
//
//  Created by CJ on 2019/6/18.
//  Copyright © 2019 CJ. All rights reserved.
//

#import "CJPerson+One.h"
#import <objc/runtime.h>
#import "WeakObject.h"

@implementation CJPerson (One)

+ (void)load {
    NSLog(@"One ++ load");
}

+ (void)initialize {
    NSLog(@"One ++ initialize");
}

- (void)setName:(NSObject *)name {
    WeakObject *weakObj = [[WeakObject alloc] initWithBlock:^{
        objc_setAssociatedObject(self, @selector(name), nil, OBJC_ASSOCIATION_ASSIGN);
    }];
    // name释放的时候会销毁它所关联的对象，即weakObj会随即被释放，然后就会调用weakObj的dealloc，dealloc会执行上面的block
    objc_setAssociatedObject(name, &weakObj, weakObj, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(self, @selector(name), name, OBJC_ASSOCIATION_ASSIGN);
}

- (NSObject *)name {
    return objc_getAssociatedObject(self, _cmd);
}

- (void)eat {
    NSLog(@"One -- %@",NSStringFromSelector(_cmd));
}

- (void)drink {
    NSLog(@"One -- %@",NSStringFromSelector(_cmd));
}

+ (void)run {
    NSLog(@"One ++ %@",NSStringFromSelector(_cmd));
}

@end
