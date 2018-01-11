/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "UIView+WebCacheOperation.h"
#import "objc/runtime.h"

static char loadOperationKey;

@implementation UIView (WebCacheOperation)

- (NSMutableDictionary *)operationDictionary {
    /*
     这个loadOperationKey 的定义是:static char loadOperationKey;
     它对应的绑定在UIView的属性是operationDictionary(NSMutableDictionary类型)
     operationDictionary的value是操作,key是针对不同类型视图和不同类型的操作设定的字符串
     注意:&是一元运算符结果是右操作对象的地址(&loadOperationKey返回static char loadOperationKey的地址)
     */
    
    NSMutableDictionary *operations = objc_getAssociatedObject(self, &loadOperationKey);
    //如果可以查到operations,就rerun,反正给视图绑定一个新的,空的operations字典
    if (operations) {
        return operations;
    }
    operations = [NSMutableDictionary dictionary];
    objc_setAssociatedObject(self, &loadOperationKey, operations, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    return operations;
}

- (void)sd_setImageLoadOperation:(id)operation forKey:(NSString *)key {
    
    // 先取消之前的 operation
    [self sd_cancelImageLoadOperationWithKey:key];
    
    // 获取 operations 字典集合并添加 operation
    NSMutableDictionary *operationDictionary = [self operationDictionary];
    [operationDictionary setObject:operation forKey:key];
}

- (void)sd_cancelImageLoadOperationWithKey:(NSString *)key {
    // 获取 operationDictionary
    NSMutableDictionary *operationDictionary = [self operationDictionary];
    // 获取任务 operations
    id operations = [operationDictionary objectForKey:key];
    if (operations) {
        // 可能是任务数组也可能是单个的任务
        if ([operations isKindOfClass:[NSArray class]]) {
            for (id <SDWebImageOperation> operation in operations) {
                if (operation) {
                    [operation cancel];
                }
            }
        } else if ([operations conformsToProtocol:@protocol(SDWebImageOperation)]){
            [(id<SDWebImageOperation>) operations cancel];
        }
        // 最后根据 key 移除掉 operation
        [operationDictionary removeObjectForKey:key];
    }
}

- (void)sd_removeImageLoadOperationWithKey:(NSString *)key {
    NSMutableDictionary *operationDictionary = [self operationDictionary];
    [operationDictionary removeObjectForKey:key];
}

@end
