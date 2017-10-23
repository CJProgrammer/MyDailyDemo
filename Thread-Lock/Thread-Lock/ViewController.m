//
//  ViewController.m
//  Thread-Lock
//
//  Created by CJ on 2017/10/18.
//  Copyright © 2017年 CJ. All rights reserved.
//

#import "ViewController.h"
#import <pthread.h>
#import <libkern/OSAtomic.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self osspinlock];
}

- (void)osspinlock {
    __block OSSpinLock theLock = OS_SPINLOCK_INIT;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        OSSpinLockLock(&theLock);
        NSLog(@"线程1开始");
        sleep(3);
        NSLog(@"线程1结束");
        OSSpinLockUnlock(&theLock);
        
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        OSSpinLockLock(&theLock);
        sleep(1);
        NSLog(@"线程2");
        OSSpinLockUnlock(&theLock);
        
    });
}

- (void)pthread_mutex_recursive {
    __block pthread_mutex_t cjlock;
    
    pthread_mutexattr_t attr;
    pthread_mutexattr_init(&attr);
    pthread_mutexattr_settype(&attr, PTHREAD_MUTEX_RECURSIVE);
    pthread_mutex_init(&cjlock, &attr);
    pthread_mutexattr_destroy(&attr);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        static void (^RecursiveBlock)(int);
        
        RecursiveBlock = ^(int value) {
            pthread_mutex_lock(&cjlock);
            NSLog(@"%d加锁成功",value);
            if (value > 0) {
                NSLog(@"value = %d", value);
                sleep(1);
                RecursiveBlock(value - 1);
            }
            NSLog(@"%d解锁成功",value);
            pthread_mutex_unlock(&cjlock);
        };
        RecursiveBlock(3);
    });
}

- (void)pthread_mutex {
    __block pthread_mutex_t cjlock;
    pthread_mutex_init(&cjlock, NULL);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        pthread_mutex_lock(&cjlock);
        NSLog(@"线程1开始");
        sleep(3);
        NSLog(@"线程1结束");
        pthread_mutex_unlock(&cjlock);
        
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        pthread_mutex_lock(&cjlock);
        NSLog(@"线程2");
        pthread_mutex_unlock(&cjlock);
    });
}

/*
 dispatch_semaphore_create(long value);
 dispatch_semaphore_wait(dispatch_semaphore_t  _Nonnull dsema, dispatch_time_t timeout);
 dispatch_semaphore_signal(dispatch_semaphore_t  _Nonnull dsema);
 */
- (void)dispatch_semaphore {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_time_t overTime = dispatch_time(DISPATCH_TIME_NOW, 3 * NSEC_PER_SEC);
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_semaphore_wait(semaphore, overTime);
        NSLog(@"线程1开始");
        sleep(5);
        NSLog(@"线程1结束");
        dispatch_semaphore_signal(semaphore);
    });
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        dispatch_semaphore_wait(semaphore, overTime);
        NSLog(@"线程2开始");
        dispatch_semaphore_signal(semaphore);
    });
}

- (void)nscondition {
    NSCondition * cjcondition = [NSCondition new];
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [cjcondition lock];
        NSLog(@"线程1线程加锁");
        [cjcondition wait];
        NSLog(@"线程1线程唤醒");
        [cjcondition unlock];
        NSLog(@"线程1线程解锁");
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [cjcondition lock];
        NSLog(@"线程2线程加锁");
        if ([cjcondition waitUntilDate:[NSDate dateWithTimeIntervalSinceNow:10]]) {
            NSLog(@"线程2线程唤醒");
            [cjcondition unlock];
            NSLog(@"线程2线程解锁");
        }
    });
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        sleep(2);
        [cjcondition broadcast];
    });
}

- (void)nsrecursivelock{
    NSRecursiveLock * cjlock = [[NSRecursiveLock alloc] init];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        static void (^RecursiveBlock)(int);
        RecursiveBlock = ^(int value) {
            [cjlock lock];
            NSLog(@"%d加锁成功",value);
            if (value > 0) {
                NSLog(@"value:%d", value);
                RecursiveBlock(value - 1);
            }
            NSLog(@"%d解锁成功",value);
            [cjlock unlock];
            
        };
        RecursiveBlock(3);
    });
}

- (void)nsconditionlock {
    NSConditionLock * cjlock = [[NSConditionLock alloc] initWithCondition:0];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [cjlock lock];
        NSLog(@"线程1加锁成功");
        sleep(1);
        [cjlock unlock];
        NSLog(@"线程1解锁成功");
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        [cjlock lockWhenCondition:1];
        NSLog(@"线程2加锁成功");
        [cjlock unlock];
        NSLog(@"线程2解锁成功");
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(2);
        if ([cjlock tryLockWhenCondition:0]) {
            NSLog(@"线程3加锁成功");
            sleep(2);
            [cjlock unlockWithCondition:2];
            NSLog(@"线程3解锁成功");
        } else {
            NSLog(@"线程3尝试加锁失败");
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([cjlock lockWhenCondition:2 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]]) {
            NSLog(@"线程4加锁成功");
            [cjlock unlockWithCondition:1];
            NSLog(@"线程4解锁成功");
        } else {
            NSLog(@"线程4尝试加锁失败");
        }
    });
}

- (void)nslock {
    NSLock * cjlock = [NSLock new];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [cjlock lock];
        NSLog(@"线程1加锁成功");
        sleep(2);
        [cjlock unlock];
        NSLog(@"线程1解锁成功");
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        [cjlock lock];
        NSLog(@"线程2加锁成功");
        [cjlock unlock];
        NSLog(@"线程2解锁成功");
    });

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([cjlock tryLock]) {
            NSLog(@"线程3加锁成功");
            [cjlock unlock];
            NSLog(@"线程3解锁成功");
        }else {
            NSLog(@"线程3加锁失败");
        }
    });

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(3);
        if ([cjlock tryLock]) {
            NSLog(@"线程4加锁成功");
            [cjlock unlock];
            NSLog(@"线程4解锁成功");
        }else {
            NSLog(@"线程4加锁失败");
        }
    });

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([cjlock lockBeforeDate:[NSDate dateWithTimeIntervalSinceNow:10]]) {
            NSLog(@"线程5加锁成功");
            [cjlock unlock];
            NSLog(@"线程5解锁成功");
        }else {
            NSLog(@"线程5加锁失败");
        }
    });
}

- (void)synchronized {
    NSObject * cjobj = [NSObject new];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        @synchronized(cjobj){
            NSLog(@"线程1开始");
            sleep(3);
            NSLog(@"线程1结束");
        }
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        sleep(1);
        @synchronized(cjobj){
            NSLog(@"线程2");
        }
    });
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
