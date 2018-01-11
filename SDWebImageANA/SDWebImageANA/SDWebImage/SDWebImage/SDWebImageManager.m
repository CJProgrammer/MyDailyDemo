/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageManager.h"
#import <objc/message.h>

@interface SDWebImageCombinedOperation : NSObject <SDWebImageOperation>

// 是否取消
@property (assign, nonatomic, getter = isCancelled) BOOL cancelled;
// 取消任务时需要处理的东西，例如下载任务
@property (copy, nonatomic) SDWebImageNoParamsBlock cancelBlock;
// 缓存的cacheOperation
@property (strong, nonatomic) NSOperation *cacheOperation;

@end

@interface SDWebImageManager ()

// 图片缓存方案
@property (strong, nonatomic, readwrite) SDImageCache *imageCache;
// 图片下载
@property (strong, nonatomic, readwrite) SDWebImageDownloader *imageDownloader;
// 下载失败的url集合
@property (strong, nonatomic) NSMutableSet *failedURLs;
// 存储正在下载 operation，添加的就是 SDWebImageCombinedOperation 的实例
@property (strong, nonatomic) NSMutableArray *runningOperations;

@end

@implementation SDWebImageManager

+ (id)sharedManager {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (id)init {
    if ((self = [super init])) {
        // 获得一个SDImageCache的单例
        _imageCache = [self createCache];
        // 获得一个SDWebImageDownloader的单例
        _imageDownloader = [SDWebImageDownloader sharedDownloader];
        // 新建一个MutableSet来存储下载失败的url，可排除相同的url
        _failedURLs = [NSMutableSet new];
        // 新建一个用来存储下载operation的可变数组
        _runningOperations = [NSMutableArray new];
    }
    return self;
}

- (SDImageCache *)createCache {
    return [SDImageCache sharedImageCache];
}

- (id <SDWebImageOperation>)downloadImageWithURL:(NSURL *)url
                                         options:(SDWebImageOptions)options
                                        progress:(SDWebImageDownloaderProgressBlock)progressBlock
                                       completed:(SDWebImageCompletionWithFinishedBlock)completedBlock {
    // completedBlock不存在的话，调用此方法就没有什么意义了
    NSAssert(completedBlock != nil, @"If you mean to prefetch the image, use -[SDWebImagePrefetcher prefetchURLs] instead");

    // 1. 对 completedBlock 和 url 进行检查
    if ([url isKindOfClass:NSString.class]) {
        url = [NSURL URLWithString:(NSString *)url];
    }
    
    if (![url isKindOfClass:NSURL.class]) {
        url = nil;
    }

    // 2. 创建 SDWebImageCombinedOperation 对象，遵循 SDWebImageOperation 协议
    __block SDWebImageCombinedOperation *operation = [SDWebImageCombinedOperation new];
    __weak SDWebImageCombinedOperation *weakOperation = operation;

    // 3. 判断是否是曾经下载失败过的 url
    BOOL isFailedUrl = NO;
    // 3.1 添加互斥锁，防止多线程同时操作 failedURLs
    @synchronized (self.failedURLs) {
        isFailedUrl = [self.failedURLs containsObject:url];
    }

    // 4. url 为空或者如果这个 url 曾经下载失败过，并且没有设置 SDWebImageRetryFailed，就直回调 completedBlock，并且直接返回
    if (url.absoluteString.length == 0 || (!(options & SDWebImageRetryFailed) && isFailedUrl)) {
        dispatch_main_sync_safe(^{
            NSError *error = [NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorFileDoesNotExist userInfo:nil];
            completedBlock(nil, error, SDImageCacheTypeNone, YES, url);
        });
        return operation;
    }
 
    // 5. 添加 operation 到 runningOperations 中，使用互斥锁，防止多线程同时操作 runningOperations
    @synchronized (self.runningOperations) {
        [self.runningOperations addObject:operation];
    }
    
    // 6. 计算缓存用的 key，读取缓存
    NSString *key = [self cacheKeyForURL:url];
    // 7. 处理缓存查询结果回调，把查询的 operation 赋予 operation.cacheOperation
    operation.cacheOperation = [self.imageCache queryDiskCacheForKey:key done:^(UIImage *image, SDImageCacheType cacheType) {
        // 7.1 判断 operation 是否已经被取消了（例如 tableView 快速滑动，就会不停的取消 operation），如果已经取消了就直接移除 operation
        if (operation.isCancelled) {
            @synchronized (self.runningOperations) {
                [self.runningOperations removeObject:operation];
            }
            return;
        }

        // 7.2 在缓存查询成功之后根据回调信息做出相应处理
        // 7.2.A 无论缓存有没有，反正需要下载，去做下载的任务
        /*
         >条件1:在（缓存中没有找到图片）或者（options选项里面包含了SDWebImageRefreshCached）--(这两项都需要进行请求网络图片的)
         >条件2:代理是否允许下载,（SDWebImageManagerDelegate的delegate不能响应imageManager:shouldDownloadImageForURL:方法）或者（能响应方法且方法返回值为YES允许下载）-- 也就是：1、没有实现这个方法就是允许下载的；2、如果实现了的话,返回YES才是允许下载的；
        */
        if ((!image || options & SDWebImageRefreshCached) && (![self.delegate respondsToSelector:@selector(imageManager:shouldDownloadImageForURL:)] || [self.delegate imageManager:self shouldDownloadImageForURL:url])) {
            // 7.2.A.1 如果（在缓存中找到了image）且（options选项包含SDWebImageRefreshCached）,先在主线程完成一次回调,使用的是缓存中找的图片，后面会再次下载刷新缓存
            if (image && options & SDWebImageRefreshCached) {
                dispatch_main_sync_safe(^{
                    completedBlock(image, nil, cacheType, YES, url);
                });
            }

            // 7.2.A.2 如果（没有在缓存中找到image）或者（设置了需要刷新缓存的选项）,则仍需要下载操作
            SDWebImageDownloaderOptions downloaderOptions = 0;
            // a = a|b;
            if (options & SDWebImageLowPriority) downloaderOptions |= SDWebImageDownloaderLowPriority;
            if (options & SDWebImageProgressiveDownload) downloaderOptions |= SDWebImageDownloaderProgressiveDownload;
            if (options & SDWebImageRefreshCached) downloaderOptions |= SDWebImageDownloaderUseNSURLCache;
            if (options & SDWebImageContinueInBackground) downloaderOptions |= SDWebImageDownloaderContinueInBackground;
            if (options & SDWebImageHandleCookies) downloaderOptions |= SDWebImageDownloaderHandleCookies;
            if (options & SDWebImageAllowInvalidSSLCertificates) downloaderOptions |= SDWebImageDownloaderAllowInvalidSSLCertificates;
            if (options & SDWebImageHighPriority) downloaderOptions |= SDWebImageDownloaderHighPriority;
            if (image && options & SDWebImageRefreshCached) {
                // 如果image已经被缓存但是设置了需要请求服务器刷新的选项，强制关闭渐进式选项
                downloaderOptions &= ~SDWebImageDownloaderProgressiveDownload;
                // 如果image已经被缓存但是设置了需要请求服务器刷新的选项，忽略从NSURLCache读取的image
                downloaderOptions |= SDWebImageDownloaderIgnoreCachedResponse;
            }
            
            // 7.2.A.3 创建下载操作,先使用 self.imageDownloader 下载，获的 subOperation
            id <SDWebImageOperation> subOperation = [self.imageDownloader downloadImageWithURL:url options:downloaderOptions progress:progressBlock completed:^(UIImage *downloadedImage, NSData *data, NSError *error, BOOL finished) {
                __strong __typeof(weakOperation) strongOperation = weakOperation;
                
                // 7.2.A.3.A 操作被取消，什么都不干
                if (!strongOperation || strongOperation.isCancelled) {
                    
                }
                // 7.2.A.3.B 下载失败
                else if (error) {
                    // 7.2.A.3.B.1 没有被取消的话，回调 completedBlock
                    dispatch_main_sync_safe(^{
                        if (strongOperation && !strongOperation.isCancelled) {
                            completedBlock(nil, error, SDImageCacheTypeNone, finished, url);
                        }
                    });

                    // 7.2.A.2.B.2 如果需要，则将 URL 加入下载失败的黑名单
                    if (   error.code != NSURLErrorNotConnectedToInternet
                        && error.code != NSURLErrorCancelled
                        && error.code != NSURLErrorTimedOut
                        && error.code != NSURLErrorInternationalRoamingOff
                        && error.code != NSURLErrorDataNotAllowed
                        && error.code != NSURLErrorCannotFindHost
                        && error.code != NSURLErrorCannotConnectToHost) {
                        @synchronized (self.failedURLs) {
                            [self.failedURLs addObject:url];
                        }
                    }
                }
                // 7.2.A.3.C 下载成功
                else {
                    // 7.2.A.3.C.1 如果设置了下载失败重试，将 URL 从下载失败的黑名单中移除
                    if ((options & SDWebImageRetryFailed)) {
                        @synchronized (self.failedURLs) {
                            [self.failedURLs removeObject:url];
                        }
                    }
                    
                    // 7.2.A.3.C.2 判断是否缓存到磁盘，下面会用到
                    BOOL cacheOnDisk = !(options & SDWebImageCacheMemoryOnly);

                    // 7.2.A.3.C.3.A options包含了SDWebImageRefreshCached选项,且缓存中找到了image且没有下载成功，所以不需要更新缓存，在上面缓存内的图片也已经传出去了
                    if (options & SDWebImageRefreshCached && image && !downloadedImage) {
                        
                    }
                    // 7.2.A.3.C.3.B (图片下载成功)且(下载的不是图片数组或者设置了需要变形Image的选项)且(变形的代理方法已经实现)
                    else if (downloadedImage && (!downloadedImage.images || (options & SDWebImageTransformAnimatedImage)) && [self.delegate respondsToSelector:@selector(imageManager:transformDownloadedImage:withURL:)]) {
                        
                        // 7.2.A.3.C.3.B.1 全局队列异步执行任务
                        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                            
                            // 7.2.A.3.C.3.B.2 调用代理方法完成图片transform
                            UIImage *transformedImage = [self.delegate imageManager:self transformDownloadedImage:downloadedImage withURL:url];
                            
                            // 7.2.A.3.C.3.B.3 如果变形处理的图片存在并且下载任务完成，对已经transform的图片进行缓存
                            if (transformedImage && finished) {
                                BOOL imageWasTransformed = ![transformedImage isEqual:downloadedImage];
                                [self.imageCache storeImage:transformedImage recalculateFromImage:imageWasTransformed imageData:(imageWasTransformed ? nil : data) forKey:key toDisk:cacheOnDisk];
                            }

                            // 7.2.A.3.C.3.B.4 主线程执行完成回调
                            dispatch_main_sync_safe(^{
                                if (strongOperation && !strongOperation.isCancelled) {
                                    completedBlock(transformedImage, nil, SDImageCacheTypeNone, finished, url);
                                }
                            });
                        });
                    }
                    // 7.2.A.3.C.3.C 如果没有图片transform的需求
                    else {
                        // 7.2.A.3.C.3.C.1 图片存在且图片下载完成就直接缓存
                        if (downloadedImage && finished) {
                            [self.imageCache storeImage:downloadedImage recalculateFromImage:NO imageData:data forKey:key toDisk:cacheOnDisk];
                        }
                        
                        // 7.2.A.3.C.3.C.2 主线程执行完成回调
                        dispatch_main_sync_safe(^{
                            if (strongOperation && !strongOperation.isCancelled) {
                                completedBlock(downloadedImage, nil, SDImageCacheTypeNone, finished, url);
                            }
                        });
                    }
                }
                // 7.2.A.3.2 如果下载完成，就移除 operation
                if (finished) {
                    @synchronized (self.runningOperations) {
                        if (strongOperation) {
                            [self.runningOperations removeObject:strongOperation];
                        }
                    }
                }
            }];// 下载任务 downloadImageWithURL:options:progress:completed: 的尾部
            
            // 7.2.A.4 如果需要下载才设置 operation 的 cancelBlock，可以取消下载任务
            operation.cancelBlock = ^{
                // 7.2.A.4.1 cancel 掉下载任务 subOperation，
                [subOperation cancel];
                
                // 7.2.A.4.2 移除 operation.
                @synchronized (self.runningOperations) {
                    __strong __typeof(weakOperation) strongOperation = weakOperation;
                    if (strongOperation) {
                        [self.runningOperations removeObject:strongOperation];
                    }
                }
            };
        }
        // 7.2.B 如果（有缓存图片）且(代理不允许下载 或者 没有设置SDWebImageRefreshCached选项，满足至少一项)--不需要下载，直接回调
        else if (image) {
            // 7.2.B.1 回调 completedBlock，传出去 image
            dispatch_main_sync_safe(^{
                __strong __typeof(weakOperation) strongOperation = weakOperation;
                if (strongOperation && !strongOperation.isCancelled) {
                    completedBlock(image, nil, cacheType, YES, url);
                }
            });
            // 7.2.B.2 流程结束，从 runningOperations 中移除 operation
            @synchronized (self.runningOperations) {
                [self.runningOperations removeObject:operation];
            }
        }
        // 7.2.C 缓存中没有找到图片且代理不允许下载
        else {
            // 7.2.C.1 回调 completedBlock，传出去 nil
            dispatch_main_sync_safe(^{
                __strong __typeof(weakOperation) strongOperation = weakOperation;
                if (strongOperation && !weakOperation.isCancelled) {
                    completedBlock(nil, nil, SDImageCacheTypeNone, YES, url);
                }
            });
            // 7.2.C.2 流程结束，从 runningOperations 中移除 operation
            @synchronized (self.runningOperations) {
                [self.runningOperations removeObject:operation];
            }
        }
    }];// 查询缓存的方法 queryDiskCacheForKey:done: 尾部

    // 8. 最后返回出去 operation，
    return operation;
}

// 根据 url 缓存图片
- (void)saveImageToCache:(UIImage *)image forURL:(NSURL *)url {
    if (image && url) {
        NSString *key = [self cacheKeyForURL:url];
        [self.imageCache storeImage:image forKey:key toDisk:YES];
    }
}

// 取消所有任务
- (void)cancelAll {
    @synchronized (self.runningOperations) {
        // copy之后，数组内的元素并没有生成一份新的，所以直接调用取消即可
        NSArray *copiedOperations = [self.runningOperations copy];
        [copiedOperations makeObjectsPerformSelector:@selector(cancel)];
        [self.runningOperations removeObjectsInArray:copiedOperations];
    }
}

// 是否有正在处理的任务
- (BOOL)isRunning {
    BOOL isRunning = NO;
    @synchronized(self.runningOperations) {
        isRunning = (self.runningOperations.count > 0);
    }
    return isRunning;
}

// 根据 url 获取 key
- (NSString *)cacheKeyForURL:(NSURL *)url {
    if (self.cacheKeyFilter) {
        return self.cacheKeyFilter(url);
    }
    else {
        return [url absoluteString];
    }
}

// 检测图片是否缓存过
- (BOOL)cachedImageExistsForURL:(NSURL *)url {
    NSString *key = [self cacheKeyForURL:url];
    if ([self.imageCache imageFromMemoryCacheForKey:key] != nil) return YES;
    return [self.imageCache diskImageExistsWithKey:key];
}

// 检测图片是否在磁盘内缓存过
- (BOOL)diskImageExistsForURL:(NSURL *)url {
    NSString *key = [self cacheKeyForURL:url];
    return [self.imageCache diskImageExistsWithKey:key];
}

// 检测图片是否缓存过，并在检测完成之后回调 completionBlock
- (void)cachedImageExistsForURL:(NSURL *)url
                     completion:(SDWebImageCheckCacheCompletionBlock)completionBlock {
    NSString *key = [self cacheKeyForURL:url];
    
    BOOL isInMemoryCache = ([self.imageCache imageFromMemoryCacheForKey:key] != nil);
    
    if (isInMemoryCache) {
        // 确保 completion 在主线程中回调，会有 UI 操作
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completionBlock) {
                completionBlock(YES);
            }
        });
        return;
    }
    
    [self.imageCache diskImageExistsWithKey:key completion:^(BOOL isInDiskCache) {
        // completion 只会在主线程中回调
        if (completionBlock) {
            completionBlock(isInDiskCache);
        }
    }];
}

// 检测图片是否在磁盘内缓存过，并返回完成回调 completionBlock
- (void)diskImageExistsForURL:(NSURL *)url
                   completion:(SDWebImageCheckCacheCompletionBlock)completionBlock {
    NSString *key = [self cacheKeyForURL:url];
    
    [self.imageCache diskImageExistsWithKey:key completion:^(BOOL isInDiskCache) {
        // completion 只会在主线程中回调
        if (completionBlock) {
            completionBlock(isInDiskCache);
        }
    }];
}

@end


@implementation SDWebImageCombinedOperation

- (void)setCancelBlock:(SDWebImageNoParamsBlock)cancelBlock {
    // 如果 operation 已经取消掉，则直接执行 cancelBlock
    if (self.isCancelled) {
        if (cancelBlock) {
            cancelBlock();
        }
        // don't forget to nil the cancelBlock, otherwise we will get crashes
        _cancelBlock = nil;
    } else {// 如果 operation 没有取消，则赋值给 _cancelBlock
        _cancelBlock = [cancelBlock copy];
    }
}

#pragma mark - SDWebImageOperation

- (void)cancel {
    // 1. 设置成取消状态
    self.cancelled = YES;
    // 2. 如果缓存任务存在，则取消任务并设置为空
    if (self.cacheOperation) {
        [self.cacheOperation cancel];
        self.cacheOperation = nil;
    }
    // 3. 如果 cancelBlock 存在则执行
    if (self.cancelBlock) {
        self.cancelBlock();
        
        // TODO: this is a temporary fix to #809.
        // Until we can figure the exact cause of the crash, going with the ivar instead of the setter
//        self.cancelBlock = nil;
        _cancelBlock = nil;
    }
}

@end


@implementation SDWebImageManager (Deprecated)

// deprecated method, uses the non deprecated method
// adapter for the completion block
- (id <SDWebImageOperation>)downloadWithURL:(NSURL *)url options:(SDWebImageOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageCompletedWithFinishedBlock)completedBlock {
    return [self downloadImageWithURL:url
                              options:options
                             progress:progressBlock
                            completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                if (completedBlock) {
                                    completedBlock(image, error, cacheType, finished);
                                }
                            }];
}

@end
