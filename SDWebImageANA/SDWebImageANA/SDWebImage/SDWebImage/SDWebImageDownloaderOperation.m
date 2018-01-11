/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageDownloaderOperation.h"
#import "SDWebImageDecoder.h"
#import "UIImage+MultiFormat.h"
#import <ImageIO/ImageIO.h>
#import "SDWebImageManager.h"

NSString *const SDWebImageDownloadStartNotification = @"SDWebImageDownloadStartNotification";
NSString *const SDWebImageDownloadReceiveResponseNotification = @"SDWebImageDownloadReceiveResponseNotification";
NSString *const SDWebImageDownloadStopNotification = @"SDWebImageDownloadStopNotification";
NSString *const SDWebImageDownloadFinishNotification = @"SDWebImageDownloadFinishNotification";

@interface SDWebImageDownloaderOperation () <NSURLConnectionDataDelegate>

@property (copy, nonatomic) SDWebImageDownloaderProgressBlock progressBlock;
@property (copy, nonatomic) SDWebImageDownloaderCompletedBlock completedBlock;
@property (copy, nonatomic) SDWebImageNoParamsBlock cancelBlock;

@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;
@property (strong, nonatomic) NSMutableData *imageData;
@property (strong, nonatomic) NSURLConnection *connection;
@property (strong, atomic) NSThread *thread;

#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
@property (assign, nonatomic) UIBackgroundTaskIdentifier backgroundTaskId;
#endif

@end

@implementation SDWebImageDownloaderOperation {
    size_t width, height;
    UIImageOrientation orientation;
    BOOL responseFromCached;
}

@synthesize executing = _executing;
@synthesize finished = _finished;

- (id)initWithRequest:(NSURLRequest *)request
              options:(SDWebImageDownloaderOptions)options
             progress:(SDWebImageDownloaderProgressBlock)progressBlock
            completed:(SDWebImageDownloaderCompletedBlock)completedBlock
            cancelled:(SDWebImageNoParamsBlock)cancelBlock {
    if ((self = [super init])) {
        _request = request;
        _shouldDecompressImages = YES;
        _shouldUseCredentialStorage = YES;
        _options = options;
        _progressBlock = [progressBlock copy];
        _completedBlock = [completedBlock copy];
        _cancelBlock = [cancelBlock copy];
        _executing = NO;
        _finished = NO;
        _expectedSize = 0;
        responseFromCached = YES; // Initially wrong until `connection:willCacheResponse:` is called or not called
    }
    return self;
}

// 当创建的 SDWebImageDownloaderOperation 对象被加入到 downloader.h 的 downloadQueue 中时，该对象的 -start 方法就会被自动调用。
- (void)start {
    // 1. 添加互斥锁，防止发生线程冲突
    @synchronized (self) {
        // 2. 如果 `self` 被 cancel 掉的话，finished 属性变为 YES，reset 下载数据和回调 block，然后直接 return
        if (self.isCancelled) {
            self.finished = YES;
            [self reset];
            return;
        }

#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
        Class UIApplicationClass = NSClassFromString(@"UIApplication");
        BOOL hasApplication = UIApplicationClass && [UIApplicationClass respondsToSelector:@selector(sharedApplication)];
        // 3. 如果允许程序退到后台后继续下载，就标记为允许后台执行
        if (hasApplication && [self shouldContinueWhenAppEntersBackground]) {
            __weak __typeof__ (self) wself = self;
            UIApplication * app = [UIApplicationClass performSelector:@selector(sharedApplication)];
            // 3.1 开启后台任务，在后台任务执行时间超过最大时间时，也就是后台任务过期执行过期回调block，在block中主动将这个后台任务结束。
            self.backgroundTaskId = [app beginBackgroundTaskWithExpirationHandler:^{
                __strong __typeof (wself) sself = wself;

                if (sself) {
                    // 3.2 调用 cancel 方法（这个方法里面又做了一些处理，反正就是 cancel 掉当前的 operation）
                    [sself cancel];

                    // 3.3 调用 UIApplication 的 endBackgroundTask： 方法结束任务
                    [app endBackgroundTask:sself.backgroundTaskId];
                    sself.backgroundTaskId = UIBackgroundTaskInvalid;
                }
            }];
        }
#endif

        // 4. 标记 executing 属性为 YES
        self.executing = YES;
        // 5. 初始化 connection，Designated initializer，赋值给 connection 属性
        self.connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO];
        // 6. currentThread，赋值给 thread 属性
        self.thread = [NSThread currentThread];
    }

    // 7. 开始下载
    [self.connection start];

    // 8.A 如果connection创建完成（因为上面初始化 connection 时可能会失败，所以这里我们需要根据不同情况做处理）
    if (self.connection) {
        if (self.progressBlock) {
            // 8.1 回调 progressBlock（初始的 receivedSize 为 0，expectSize 为 -1）
            self.progressBlock(0, NSURLResponseUnknownLength);
        }
        /* 这里说一下，要回到主线程去发通知，如果在不同的线程中发送通知是不能收到的*/
        dispatch_async(dispatch_get_main_queue(), ^{
            // 8.2 发出 SDWebImageDownloadStartNotification 通知（SDWebImageDownloader 会监听到
            [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadStartNotification object:self];
        });

        /**
         // 8.3 开启 runloop，在 [self.connection start];有返回结果(正常完成,有错误都算是结果)之前,代码会一直阻塞在CFRunLoopRun()或者CFRunLoopRunInMode(kCFRunLoopDefaultMode, 10, false) 这里,也就是说  [self.connection start];之后下载就一直在进行中,一直到下载完成或者出错了(这两种情况都会调用CFRunLoopStop),这个阻塞才会解除
         */
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_5_1) {
            // 确保在后台线程中运行runloop，以便它可以处理下载的数据
            // Note: we use a timeout to work around an issue with NSURLConnection cancel under iOS 5
            //       not waking up the runloop, leading to dead threads (see https://github.com/rs/SDWebImage/issues/466)
            CFRunLoopRunInMode(kCFRunLoopDefaultMode, 10, false);
        }
        else {
            CFRunLoopRun();
        }

        // 8.4 runloop 结束后继续往下执行，如果未完成，则取消连接
        if (!self.isFinished) {
            [self.connection cancel];
            /**
             NSURLConnectionDelegate代理方法
             主动调用,并制造一个错误,这个方法一旦被调用，代理就不会再接收connection的消息,也就是不在调用其他的任何代理方法,connection彻底结束。
             */
            [self connection:self.connection didFailWithError:[NSError errorWithDomain:NSURLErrorDomain code:NSURLErrorTimedOut userInfo:@{NSURLErrorFailingURLErrorKey : self.request.URL}]];
        }
    }
    // 8.B 如果 connection 为 nil，回调 completedBlock，返回 connection 初始化失败的错误信息
    else {
        if (self.completedBlock) {
            self.completedBlock(nil, nil, [NSError errorWithDomain:NSURLErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"Connection can't be initialized"}], YES);
        }
    }
// 9. 执行到这里说明下载操作已经完成了(无论是成功还是错误),所以要停止在后台的执行,使用endBackgroundTask:
#if TARGET_OS_IPHONE && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_4_0
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    if(!UIApplicationClass || ![UIApplicationClass respondsToSelector:@selector(sharedApplication)]) {
        return;
    }
    if (self.backgroundTaskId != UIBackgroundTaskInvalid) {
        UIApplication * app = [UIApplication performSelector:@selector(sharedApplication)];
        [app endBackgroundTask:self.backgroundTaskId];
        self.backgroundTaskId = UIBackgroundTaskInvalid;
    }
#endif
}

- (void)cancel {
    @synchronized (self) {
        if (self.thread) {
            [self performSelector:@selector(cancelInternalAndStop) onThread:self.thread withObject:nil waitUntilDone:NO];
        }
        else {
            [self cancelInternal];
        }
    }
}

- (void)cancelInternalAndStop {
    if (self.isFinished) {
        return;
    }
    [self cancelInternal];
    CFRunLoopStop(CFRunLoopGetCurrent());
}

- (void)cancelInternal {
    if (self.isFinished) {
        return;
    }
    [super cancel];
    if (self.cancelBlock) self.cancelBlock();

    if (self.connection) {
        [self.connection cancel];
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadStopNotification object:self];
        });

        // As we cancelled the connection, its callback won't be called and thus won't
        // maintain the isFinished and isExecuting flags.
        if (self.isExecuting) self.executing = NO;
        if (!self.isFinished) self.finished = YES;
    }

    [self reset];
}

- (void)done {
    self.finished = YES;
    self.executing = NO;
    [self reset];
}

- (void)reset {
    self.cancelBlock = nil;
    self.completedBlock = nil;
    self.progressBlock = nil;
    self.connection = nil;
    self.imageData = nil;
    self.thread = nil;
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isConcurrent {
    return YES;
}

#pragma mark NSURLConnection (delegate)

// 下载过程中的 response 回调，调用一次
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    
    // A. 返回 code 不是 304 Not Modified
    if (![response respondsToSelector:@selector(statusCode)] || ([((NSHTTPURLResponse *)response) statusCode] < 400 && [((NSHTTPURLResponse *)response) statusCode] != 304)) {
        // 1. 获取 expectedSize，文件的预期大小
        NSInteger expected = response.expectedContentLength > 0 ? (NSInteger)response.expectedContentLength : 0;
        self.expectedSize = expected;
        // 2. 立即完成一次进度回调 progressBlock
        if (self.progressBlock) {
            self.progressBlock(0, expected);
        }

        // 3. 初始化属性imageDate,用于拼接图片 二进制数据
        self.imageData = [[NSMutableData alloc] initWithCapacity:expected];
        self.response = response;
        // 4. 异步的向主队列发送一个 SDWebImageDownloadReceiveResponseNotification 通知
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadReceiveResponseNotification object:self];
        });
    }
    // B. 针对 304 Not Modified 做处理，直接 cancel operation，并返回缓存的 image
    else {
        NSUInteger code = [((NSHTTPURLResponse *)response) statusCode];
        
        //This is the case when server returns '304 Not Modified'. It means that remote image is not changed.
        //In case of 304 we need just cancel the operation and return cached image from the cache.
        /**
         在服务器返回'304 Not Modified'的情况，意味着远程的图片没有变化，在 304 的情况下我们只需要取消操作并且返回从缓存中取的缓存图片；
         */
        if (code == 304) {
            [self cancelInternal];
        } else {
            [self.connection cancel];
        }
        // 2. 异步的向主队列发送 SDWebImageDownloadStopNotification 通知停止操作
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadStopNotification object:self];
        });
        // 3. 执行完成回调 completedBlock
        if (self.completedBlock) {
            self.completedBlock(nil, nil, [NSError errorWithDomain:NSURLErrorDomain code:[((NSHTTPURLResponse *)response) statusCode] userInfo:nil], YES);
        }
        // 4. 停止当前的runloop
        CFRunLoopStop(CFRunLoopGetCurrent());
        // 5. 设置下载完成标记为YES,正在执行的为NO,将属性置为nil
        [self done];
    }
}

// 下载过程中 data 回调，调用多次。该方法的主要任务是接收数据。每次接收到数据时，都会用现有的数据创建一个CGImageSourceRef对象以做处理。在首次获取到数据时(width+height==0)会从这些包含图像信息的数据中取出图像的长、宽、方向等信息以备使用。而后在图片下载完成之前，会使用CGImageSourceRef对象创建一个图片对象，经过缩放、解压缩操作后生成一个UIImage对象供完成回调使用。当然，在这个方法中还需要处理的就是进度信息。如果我们有设置进度回调的话，就调用这个进度回调以处理当前图片的下载进度。**缩放操作可以查看SDWebImageCompat文件中的SDScaledImageForKey函数；解压缩操作可以查看SDWebImageDecoder文件+decodedImageWithImage方法**
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    // 1. 拼接图片数据
    [self.imageData appendData:data];

    // 2. 如果需要渐进式加载，则针对 `SDWebImageDownloaderProgressiveDownload` 做处理
    if ((self.options & SDWebImageDownloaderProgressiveDownload) && self.expectedSize > 0 && self.completedBlock) {

        // 2.1 根据self.imageData获取已接收的数据的长度
        const NSInteger totalSize = self.imageData.length;

        /**
         2.2 每次接收到数据时,都会用现有的数据创建一个CGImageSourceRef对象以做处理,
         而且这个数据应该是已接收的全部数据，而不仅仅是新的字节,所以才使用self.imageData作为参数(注意创建imageSource使用的数据是CoreFoundation的data,但是self.imageData是NSData,所以用(__bridge CFDataRef)self.imageData做转化 )
         */
        CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)self.imageData, NULL);
        
        // 2.3.A. 在首次接收到数据的时候,图片的长宽都是0(width+height == 0)，先从这些包含图像信息的数据中取出图像的长,宽,方向等信息以备使用
        if (width + height == 0) {
            // A.1 获取图片的属性信息
            CFDictionaryRef properties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, NULL);
            if (properties) {
                NSInteger orientationValue = -1;
                // A.2 图片像素的高度 可以前面加(__bridge NSNumber *)转换为NSNumber类型
                CFTypeRef val = CFDictionaryGetValue(properties, kCGImagePropertyPixelHeight);
                if (val) {
                    CFNumberGetValue(val, kCFNumberLongType, &height);
                }
                // A.3 获取图片的宽度
                val = CFDictionaryGetValue(properties, kCGImagePropertyPixelWidth);
                if (val) {
                    CFNumberGetValue(val, kCFNumberLongType, &width);
                }
                // A.4 获取图片的朝向
                val = CFDictionaryGetValue(properties, kCGImagePropertyOrientation);
                if (val) {
                    CFNumberGetValue(val, kCFNumberNSIntegerType, &orientationValue);
                }
                // A.5 CoreFoundation 对象类型不在ARC范围内,需要手动释放资源
                CFRelease(properties);

                // When we draw to Core Graphics, we lose orientation information,
                // which means the image below born of initWithCGIImage will be
                // oriented incorrectly sometimes. (Unlike the image born of initWithData
                // in connectionDidFinishLoading.) So save it here and pass it on later.
                // A.6 当我们使用 Core Graphics 的时候，我们会丢失图片朝向信息，它意味着使用Core Craphics框架绘制image时,使用的initWithCGImage这个函数有时候会造成图片朝向的错误，所以我们在这里保存了它的朝向信息方便后面使用。
                orientation = [[self class] orientationFromPropertyValue:(orientationValue == -1 ? 1 : orientationValue)];
            }
        }

        // 2.3.B. width+height>0 说明这时候已经接收到图片的数据了，totalSize < self.expectedSize 说明图片还没有接收完全，图片还没下载完，但也不是第一次拿到数据
        if (width + height > 0 && totalSize < self.expectedSize) {
            // B.1 使用现有图片数据 CGImageSourceRef 创建 CGImageRef 对象
            CGImageRef partialImageRef = CGImageSourceCreateImageAtIndex(imageSource, 0, NULL);

#ifdef TARGET_OS_IPHONE
            // B.2 适用于iOS变形图像的解决方案。
            if (partialImageRef) {
                const size_t partialHeight = CGImageGetHeight(partialImageRef);
                CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
                CGContextRef bmContext = CGBitmapContextCreate(NULL, width, height, 8, width * 4, colorSpace, kCGBitmapByteOrderDefault | kCGImageAlphaPremultipliedFirst);
                CGColorSpaceRelease(colorSpace);
                if (bmContext) {
                    CGContextDrawImage(bmContext, (CGRect){.origin.x = 0.0f, .origin.y = 0.0f, .size.width = width, .size.height = partialHeight}, partialImageRef);
                    CGImageRelease(partialImageRef);
                    partialImageRef = CGBitmapContextCreateImage(bmContext);
                    CGContextRelease(bmContext);
                }
                else {
                    CGImageRelease(partialImageRef);
                    partialImageRef = nil;
                }
            }
#endif
            // B.3 对图片进行缩放、解码操作
            if (partialImageRef) {
                UIImage *image = [UIImage imageWithCGImage:partialImageRef scale:1 orientation:orientation];
                // 获取key
                NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:self.request.URL];
                // 缩放
                UIImage *scaledImage = [self scaledImageForKey:key image:image];
                // 如果需要解码，则进行解码
                if (self.shouldDecompressImages) {
                    image = [UIImage decodedImageWithImage:scaledImage];
                }
                else {
                    image = scaledImage;
                }
                // 释放 CG 对象
                CGImageRelease(partialImageRef);
                // 回调 completedBlock
                dispatch_main_sync_safe(^{
                    if (self.completedBlock) {
                        self.completedBlock(image, nil, nil, NO);
                    }
                });
            }
        }
        
        // 2.4 释放 CF 对象
        CFRelease(imageSource);
    }

    // 3. 最后完成进度回调
    if (self.progressBlock) {
        self.progressBlock(self.imageData.length, self.expectedSize);
    }
}

// 下载完成时回调，调用一次
- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
    // 1. 下载结束
    SDWebImageDownloaderCompletedBlock completionBlock = self.completedBlock;
    @synchronized(self) {
        // 2. 停止 runloop
        CFRunLoopStop(CFRunLoopGetCurrent());
        self.thread = nil;
        self.connection = nil;
        // 3. 发送 SDWebImageDownloadStopNotification 通知和 SDWebImageDownloadFinishNotification 通知
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadStopNotification object:self];
            [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadFinishNotification object:self];
        });
    }
    
    // 4. 检查_request是否是NSURLCache响应的，如果没有就把responseFromCached设置为NO
    if (![[NSURLCache sharedURLCache] cachedResponseForRequest:_request]) {
        responseFromCached = NO;
    }
    
    // 5. 回调 completionBlock
    if (completionBlock) {
        // 5.A 如果是从 NSURLCache 响应的，且设置了忽略缓存响应，则回调返回 nil
        if (self.options & SDWebImageDownloaderIgnoreCachedResponse && responseFromCached) {
            completionBlock(nil, nil, nil, YES);
        }
        // 5.B 如果有图片数据
        else if (self.imageData) {
            // B.1 将数据转换为UIImage类型，针对不同图片格式进行数据转换 data -> image
            UIImage *image = [UIImage sd_imageWithData:self.imageData];
            // B.2 根据图片名中是否带 @2x 和 @3x 来做 scale 处理
            NSString *key = [[SDWebImageManager sharedManager] cacheKeyForURL:self.request.URL];
            image = [self scaledImageForKey:key image:image];
            
            // B.3 如果需要解码，就进行图片解码（如果不是 GIF 图）
            if (!image.images) {
                if (self.shouldDecompressImages) {
                    image = [UIImage decodedImageWithImage:image];
                }
            }
            
            // B.4.A 判断图片尺寸是否为空，并回调 completionBlock，返回 nil
            if (CGSizeEqualToSize(image.size, CGSizeZero)) {
                completionBlock(nil, nil, [NSError errorWithDomain:SDWebImageErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"Downloaded image has 0 pixels"}], YES);
            }
            // B.4.A 都正常，则传出 image 和 imageData
            else {
                completionBlock(image, self.imageData, nil, YES);
            }
        // 5.C 如果没有图片数据，回调带有错误信息的 completionBlock
        } else {
            completionBlock(nil, nil, [NSError errorWithDomain:SDWebImageErrorDomain code:0 userInfo:@{NSLocalizedDescriptionKey : @"Image data is nil"}], YES);
        }
    }
    // 6. 将 completionBlock 置为 nil
    self.completionBlock = nil;
    // 7. 设置完成，取消正在执行，重置所有
    [self done];
}

// 失败
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    @synchronized(self) {
        CFRunLoopStop(CFRunLoopGetCurrent());
        self.thread = nil;
        self.connection = nil;
        dispatch_async(dispatch_get_main_queue(), ^{
            [[NSNotificationCenter defaultCenter] postNotificationName:SDWebImageDownloadStopNotification object:self];
        });
    }

    if (self.completedBlock) {
        self.completedBlock(nil, nil, error, YES);
    }
    self.completionBlock = nil;
    [self done];
}

// 缓存 cachedResponse
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    responseFromCached = NO; // If this method is called, it means the response wasn't read from cache
    if (self.request.cachePolicy == NSURLRequestReloadIgnoringLocalCacheData) {
        // Prevents caching of responses
        return nil;
    }
    else {
        return cachedResponse;
    }
}

// 是否需要认证
- (BOOL)connectionShouldUseCredentialStorage:(NSURLConnection __unused *)connection {
    return self.shouldUseCredentialStorage;
}

// 发送认证信息
- (void)connection:(NSURLConnection *)connection willSendRequestForAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
        if (!(self.options & SDWebImageDownloaderAllowInvalidSSLCertificates) &&
            [challenge.sender respondsToSelector:@selector(performDefaultHandlingForAuthenticationChallenge:)]) {
            [challenge.sender performDefaultHandlingForAuthenticationChallenge:challenge];
        } else {
            NSURLCredential *credential = [NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust];
            [[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
        }
    } else {
        if ([challenge previousFailureCount] == 0) {
            if (self.credential) {
                [[challenge sender] useCredential:self.credential forAuthenticationChallenge:challenge];
            } else {
                [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
            }
        } else {
            [[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
        }
    }
}

#pragma mark Helper methods

+ (UIImageOrientation)orientationFromPropertyValue:(NSInteger)value {
    switch (value) {
        case 1:
            return UIImageOrientationUp;
        case 3:
            return UIImageOrientationDown;
        case 8:
            return UIImageOrientationLeft;
        case 6:
            return UIImageOrientationRight;
        case 2:
            return UIImageOrientationUpMirrored;
        case 4:
            return UIImageOrientationDownMirrored;
        case 5:
            return UIImageOrientationLeftMirrored;
        case 7:
            return UIImageOrientationRightMirrored;
        default:
            return UIImageOrientationUp;
    }
}

- (UIImage *)scaledImageForKey:(NSString *)key image:(UIImage *)image {
    return SDScaledImageForKey(key, image);
}

- (BOOL)shouldContinueWhenAppEntersBackground {
    return self.options & SDWebImageDownloaderContinueInBackground;
}

@end
