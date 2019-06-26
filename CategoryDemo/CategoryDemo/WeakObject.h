//
//  WeakObject.h
//  CategoryDemo
//
//  Created by CJ on 2019/6/25.
//  Copyright © 2019 CJ. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^DeallocBlock)(void);

@interface WeakObject : NSObject

@property (nonatomic, copy) DeallocBlock block;
- (instancetype)initWithBlock:(DeallocBlock)block;

@end

NS_ASSUME_NONNULL_END
