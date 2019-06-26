//
//  CJPerson+One.h
//  CategoryDemo
//
//  Created by CJ on 2019/6/18.
//  Copyright © 2019 CJ. All rights reserved.
//

#import "CJPerson.h"

NS_ASSUME_NONNULL_BEGIN

@interface CJPerson (One)

@property (nonatomic, strong) NSObject *name;
- (void)eat;
- (void)drink;
+ (void)run;

@end

NS_ASSUME_NONNULL_END
