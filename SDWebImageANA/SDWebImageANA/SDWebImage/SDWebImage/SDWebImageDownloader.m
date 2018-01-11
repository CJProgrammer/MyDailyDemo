/*
 * This file is part of the SDWebImage package.
 * (c) Olivier Poitrey <rs@dailymotion.com>
 *
 * For the full copyright and license information, please view the LICENSE
 * file that was distributed with this source code.
 */

#import "SDWebImageDownloader.h"
#import "SDWebImageDownloaderOperation.h"
#import <ImageIO/ImageIO.h>

static NSString *const kProgressCallbackKey = @"progress";
static NSString *const kCompletedCallbackKey = @"completed";

@interface SDWebImageDownloader ()

// 下载任务队列
@property (strong, nonatomic) NSOperationQueue *downloadQueue;
// 上次添加的下载任务
@property (weak, nonatomic) NSOperation *lastAddedOperation;
// 下载任务的类
@property (assign, nonatomic) Class operationClass;
// 根据每个url保存对应的处理回调progressBlock、completedBlock
@property (strong, nonatomic) NSMutableDictionary *URLCallbacks;
// 设置HTTPHeaders的内容
@property (strong, nonatomic) NSMutableDictionary *HTTPHeaders;
// This queue is used to serialize the handling of the network responses of all the download operation in a single queue
// 用来在单独的一个队列中序列化处理网络下载任务
@property (SDDispatchQueueSetterSementics, nonatomic) dispatch_queue_t barrierQueue;

@end

@implementation SDWebImageDownloader

+ (void)initialize {
    // Bind SDNetworkActivityIndicator if available (download it here: http://github.com/rs/SDNetworkActivityIndicator )
    // To use it, just add #import "SDNetworkActivityIndicator.h" in addition to the SDWebImage import
    /*
     这个方法中主要是通过注册通知让SDNetworkActivityIndicator 监听下载事件，来显示和隐藏状态栏上的 network activity indicator。为了让 SDNetworkActivityIndicator 文件可以不用导入项目中来（如果不要的话），这里使用了 runtime 的方式来实现动态创建类以及调用方法。
     */
    if (NSClassFromString(@"SDNetworkActivityIndicator")) {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        id activityIndicator = [NSClassFromString(@"SDNetworkActivityIndicator") performSelector:NSSelectorFromString(@"sharedActivityIndicator")];
#pragma clang diagnostic pop

        // Remove observer in case it was previously added.
        [[NSNotificationCenter defaultCenter] removeObserver:activityIndicator name:SDWebImageDownloadStartNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:activityIndicator name:SDWebImageDownloadStopNotification object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:activityIndicator
                                                 selector:NSSelectorFromString(@"startActivity")
                                                     name:SDWebImageDownloadStartNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:activityIndicator
                                                 selector:NSSelectorFromString(@"stopActivity")
                                                     name:SDWebImageDownloadStopNotification object:nil];
    }
}

+ (SDWebImageDownloader *)sharedDownloader {
    static dispatch_once_t once;
    static id instance;
    dispatch_once(&once, ^{
        instance = [self new];
    });
    return instance;
}

- (id)init {
    if ((self = [super init])) {
        _operationClass = [SDWebImageDownloaderOperation class];
        _shouldDecompressImages = YES;
        _executionOrder = SDWebImageDownloaderFIFOExecutionOrder;
        _downloadQueue = [NSOperationQueue new];
        _downloadQueue.maxConcurrentOperationCount = 6;
        _URLCallbacks = [NSMutableDictionary new];
#ifdef SD_WEBP
        _HTTPHeaders = [@{@"Accept": @"image/webp,image/*;q=0.8"} mutableCopy];
#else
        _HTTPHeaders = [@{@"Accept": @"image/*;q=0.8"} mutableCopy];
#endif
        _barrierQueue = dispatch_queue_create("com.hackemist.SDWebImageDownloaderBarrierQueue", DISPATCH_QUEUE_CONCURRENT);
        _downloadTimeout = 15.0;
    }
    return self;
}

- (void)dealloc {
    [self.downloadQueue cancelAllOperations];
    SDDispatchQueueRelease(_barrierQueue);
}

- (void)setValue:(NSString *)value forHTTPHeaderField:(NSString *)field {
    if (value) {
        self.HTTPHeaders[field] = value;
    }
    else {
        [self.HTTPHeaders removeObjectForKey:field];
    }
}

- (NSString *)valueForHTTPHeaderField:(NSString *)field {
    return self.HTTPHeaders[field];
}

- (void)setMaxConcurrentDownloads:(NSInteger)maxConcurrentDownloads {
    _downloadQueue.maxConcurrentOperationCount = maxConcurrentDownloads;
}

- (NSUInteger)currentDownloadCount {
    return _downloadQueue.operationCount;
}

- (NSInteger)maxConcurrentDownloads {
    return _downloadQueue.maxConcurrentOperationCount;
}

- (void)setOperationClass:(Class)operationClass {
    _operationClass = operationClass ?: [SDWebImageDownloaderOperation class];
}

- (id <SDWebImageOperation>)downloadImageWithURL:(NSURL *)url options:(SDWebImageDownloaderOptions)options progress:(SDWebImageDownloaderProgressBlock)progressBlock completed:(SDWebImageDownloaderCompletedBlock)completedBlock {
    
    // 1. 创建 SDWebImageDownloaderOperation 任务，遵循 SDWebImageOperation 协议
    __block SDWebImageDownloaderOperation *operation;
    __weak __typeof(self)wself = self;

    // 2. 调用 - [SDWebImageDownloader addProgressCallback: andCompletedBlock: forURL: createCallback: ] 方法，直接把入参 url、progressBlock 和 completedBlock 传进该方法，并在第一次下载该 URL 时回调 createCallback
    [self addProgressCallback:progressBlock completedBlock:completedBlock forURL:url createCallback:^{
        
        // 2.1 配置下载超时的时间
        NSTimeInterval timeoutInterval = wself.downloadTimeout;
        if (timeoutInterval == 0.0) {
            timeoutInterval = 15.0;
        }

        // 2.2 创建下载 request，并根据options参数设置其属性，为了避免潜在的重复缓存(NSURLCache + SDImageCache)，如果没有明确告知需要缓存，则禁用图片请求的缓存操作, 这样就只有SDImageCache进行了缓存，这里的options 是SDWebImageDownloaderOptions，并设置 request 的 cachePolicy、timeoutInterval、HTTPShouldHandleCookies、HTTPShouldUsePipelining，以及 allHTTPHeaderFields（这个属性交由外面处理，设计的比较巧妙）
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url cachePolicy:(options & SDWebImageDownloaderUseNSURLCache ? NSURLRequestUseProtocolCachePolicy : NSURLRequestReloadIgnoringLocalCacheData) timeoutInterval:timeoutInterval];
        
        // 2.3 通过设置 NSMutableURLRequest.HTTPShouldHandleCookies 的方式来决定是否处理存储在NSHTTPCookieStore的cookies
        request.HTTPShouldHandleCookies = (options & SDWebImageDownloaderHandleCookies);
        
        // 2.4 返回在接到上一个请求得响应之前,是否需要传输数据,YES传输,NO不传输
        request.HTTPShouldUsePipelining = YES;
        
        /*
         2.5 设置 allHTTPHeaderFields
         > 如果你自定义了wself.headersFilter,那就用你自己设置的 wself.headersFilter 来设置 allHTTPHeaderFields,
         > 如果你没有自己设置wself.headersFilter那么就用SDWebImage提供的HTTPHeaders，在 init 方法里面初始化,下载webp图片需要的header不一样；
         ***(WebP格式，[谷歌]开发的一种旨在加快图片加载速度的图片格式。图片压缩体积大约只有JPEG的2/3，并能节省大量的服务器带宽资源和数据空间)***
         */
        if (wself.headersFilter) {
            request.allHTTPHeaderFields = wself.headersFilter(url, [wself.HTTPHeaders copy]);
        }
        else {
            request.allHTTPHeaderFields = wself.HTTPHeaders;
        }
        // 2.6 创建 SDWebImageDownloaderOperation（继承自 NSOperation），下载的操作就是在 SDWebImageDownLoaderOperation 类里面进行的
        operation = [[wself.operationClass alloc] initWithRequest:request
                                                          options:options
                                                         // 2.6.1 SDWebImageDownloaderOperation 的 progressBlock 回调处理，(两个回调参数：接收到的数据大小和预计数据大小）
                                                         progress:^(NSInteger receivedSize, NSInteger expectedSize) {
                                                             // 这里用了 weak-strong dance，首先使用 strongSelf 强引用 weakSelf，目的是为了保住 weakSelf 在block不被释放，然后检查 self 是否已经被释放（这里为什么先“保活”后“判空”呢？因为如果先判空的话，有可能判空后 self 就被释放了）
                                                             SDWebImageDownloader *sself = wself;
                                                             if (!sself) return;
                                                             // 取出 url 对应的回调 block 数组（这里取的时候有些讲究，考虑了多线程问题，而且取的是 copy 的内容）
                                                             __block NSArray *callbacksForURL;
                                                             dispatch_sync(sself.barrierQueue, ^{
                                                                 callbacksForURL = [sself.URLCallbacks[url] copy];
                                                             });
                                                             // 遍历数组，从每个元素（字典）中取出 progressBlock 进行回调
                                                             for (NSDictionary *callbacks in callbacksForURL) {
                                                                 // 回到主线程
                                                                 dispatch_async(dispatch_get_main_queue(), ^{
                                                                     // 根据kProgressCallbackKey这个key取出进度的操作
                                                                     SDWebImageDownloaderProgressBlock callback = callbacks[kProgressCallbackKey];
                                                                     // 返回已经接收的数据字节,以及未接收的数据(预计字节)
                                                                     if (callback) {
                                                                         callback(receivedSize, expectedSize);
                                                                     }
                                                                 });
                                                             }
                                                         }
                                                        // 2.6.2 SDWebImageDownloaderOperation 的 completedBlock 回调处理，（四个回调参数：图片 UIImage，图片数据 NSData，错误 NSError，是否结束 isFinished））
                                                        completed:^(UIImage *image, NSData *data, NSError *error, BOOL finished) {
                                                            
                                                            SDWebImageDownloader *sself = wself;
                                                            if (!sself) return;
                                                            // 取出 url 对应的回调 block 数组
                                                            __block NSArray *callbacksForURL;
                                                            dispatch_barrier_sync(sself.barrierQueue, ^{
                                                                callbacksForURL = [sself.URLCallbacks[url] copy];
                                                                // 如果结束了（isFinished），就移除 url 对应的回调 block 数组（移除的时候也要考虑多线程问题）
                                                                if (finished) {
                                                                    [sself.URLCallbacks removeObjectForKey:url];
                                                                }
                                                            });
                                                            // 遍历数组，从每个元素（字典）中取出 completedBlock 进行回调
                                                            for (NSDictionary *callbacks in callbacksForURL) {
                                                                SDWebImageDownloaderCompletedBlock callback = callbacks[kCompletedCallbackKey];
                                                                if (callback) {
                                                                    callback(image, data, error, finished);
                                                                }                                                                
                                                            }
                                                        }
                                                        // 2.6.3 SDWebImageDownloaderOperation 的 cancelBlock 回调处理
                                                        cancelled:^{
                                                            
                                                            SDWebImageDownloader *sself = wself;
                                                            if (!sself) return;
                                                            // 然后移除 url 对应的所有回调 block
                                                            dispatch_barrier_async(sself.barrierQueue, ^{
                                                                [sself.URLCallbacks removeObjectForKey:url];
                                                            });
                                                        }];
        
        // 2.7 设置下载完成后是否需要解压缩
        operation.shouldDecompressImages = wself.shouldDecompressImages;
        
        // 2.8 如果设置了 username 和 password，就给 operation 的下载请求设置一个 NSURLCredential,
        /*
         用户认证 NSURLCredential
         当连接客户端与服务端进行数据传输的时候,web服务器收到客户端请求时可能需要先验证客户端是否是正常用户,再决定是否返回该接口的真实数据;
         web 服务可以在返回 http 响应时附带认证要求 challenge，作用是询问 http 请求的发起方是谁，这时发起方应提供正确的用户名和密码（即认证信息），然后 web 服务才会返回真正的 http 响应。
         收到认证要求时，NSURLConnection 的委托对象会收到相应的消息并得到一个 NSURLAuthenticationChallenge 实例。该实例的发送方遵守 NSURLAuthenticationChallengeSender 协议。为了继续收到真实的数据，需要向该发送方向发回一个 NSURLCredential 实例。
         ** NSURLCredential 身份认证 **
         
         认证过程
         1.web服务器接收到来自客户端的请求
         2.web服务并不直接返回数据,而是要求客户端提供认证信息,也就是说挑战是服务端向客户端发起的
         2.1要求客户端提供用户名与密码挑战  NSInternetPassword
         2.2 要求客户端提供客户端证书           NSClientCertificate
         2.3要求客户端信任该服务器
         3.客户端回调执行,接收到需要提供认证信息,然后提供认证信息,并再次发送给web服务
         4.web服务验证认证信息
         4.1认证成功,将最终的数据结果发送给客户端
         4.2认证失败,错误此次请求,返回错误码401
         
         ---
         
         Web服务需要验证客户端网络请求
         NSURLConnectionDelegate 提供的接收挑战,SDWeImage使用的就是这个方案
         */
        if (wself.urlCredential) {
            operation.credential = wself.urlCredential;
        } else if (wself.username && wself.password) {
            operation.credential = [NSURLCredential credentialWithUser:wself.username password:wself.password persistence:NSURLCredentialPersistenceForSession];
        }
        
        // 2.9 设置 operation 的队列优先级
        if (options & SDWebImageDownloaderHighPriority) {
            operation.queuePriority = NSOperationQueuePriorityHigh;
        } else if (options & SDWebImageDownloaderLowPriority) {
            operation.queuePriority = NSOperationQueuePriorityLow;
        }

        // 2.10 将 operation 加入到队列 downloadQueue 中，队列（NSOperationQueue）会自动管理 operation 的执行
        [wself.downloadQueue addOperation:operation];
        if (wself.executionOrder == SDWebImageDownloaderLIFOExecutionOrder) {
            // 如果 operation 执行顺序是先进后出，就设置 operation 依赖关系（先加入的依赖于后加入的），并记录最后一个 operation（lastAddedOperation）
            [wself.lastAddedOperation addDependency:operation];
            wself.lastAddedOperation = operation;
        }
    }];

    // 返回 createCallback 中创建的 operation（SDWebImageDownloaderOperation）
    return operation;
}

- (void)addProgressCallback:(SDWebImageDownloaderProgressBlock)progressBlock completedBlock:(SDWebImageDownloaderCompletedBlock)completedBlock forURL:(NSURL *)url createCallback:(SDWebImageNoParamsBlock)createCallback {
    // 1. 判断 url 是否为 nil，如果为 nil 则直接回调 completedBlock，返回失败的结果，然后 return，因为 url 会作为存储 callbacks 的 key
    if (url == nil) {
        if (completedBlock != nil) {
            completedBlock(nil, nil, nil, NO);
        }
        return;
    }

    /*
     2. 处理同一个 URL 的多次下载请求（MARK: 使用 dispatch_barrier_sync 函数来保证同一时间只有一个线程能对 URLCallbacks 进行操作)；
     URLCallbacks是一个可变字典,key是NSURL类型,value为NSMutableArray类型,value(数组里面)只包含一个元素,这个元素的类型是NSMutableDictionary类型,这个字典的key为NSString类型代表着回调类型,value为block,是对应的回调，这些代码的目的都是为了给url绑定回调，方面后面下载任务使用；
     如果url第一次绑定它的回调，也就是第一次使用这个url创建下载任务则执行一次创建下载回调；
     在创建回调中 创建下载操作(下载操作并不是在这里创建的)，dispatch_barrier_sync执行确保同一时间只有一个线程操作URLCallbacks属性,也就是确保了下面创建过程中在给operation传递回调的时候能取到正确的self.URLCallbacks[url]值，同时确保后面有相同的url再次创建的时候 if (!self.URLCallbacks[url]) 分支不再进入，first==NO，也就不再继续调用创建回调,这样就确保了同一个url对应的图片不会重复下载；
     */
    dispatch_barrier_sync(self.barrierQueue, ^{
        
        BOOL first = NO;
        // 2.1 从属性 URLCallbacks(一个字典) 中取出对应 url 的 callBacksForURL(这是一个数组，因为可能一个 url 不止在一个地方下载)
        if (!self.URLCallbacks[url]) {
            // 2.2 如果没有取到，也就意味着这个 url 是第一次下载，那就初始化一个 callBacksForURL 放到属性 URLCallbacks 中
            self.URLCallbacks[url] = [NSMutableArray new];
            first = YES;
        }

        // 2.3 处理同一个URL的同时下载请求，绑定回调block（如果是同一个url的不同地方的多次下载，会绑定多个回调）
        NSMutableArray *callbacksForURL = self.URLCallbacks[url];
        
        // 2.4 创建保存回调的字典
        NSMutableDictionary *callbacks = [NSMutableDictionary new];
        if (progressBlock) {
            callbacks[kProgressCallbackKey] = [progressBlock copy];
        }
        if (completedBlock) {
            callbacks[kCompletedCallbackKey] = [completedBlock copy];
        }
        
        // 2.5 往数组 callBacksForURL 中添加包装有 callbacks（progressBlock 和 completedBlock）的字典
        [callbacksForURL addObject:callbacks];
        // 2.6 更新 URLCallbacks 存储的对应 url 的 callBacksForURL
        self.URLCallbacks[url] = callbacksForURL;

        // 2.7 如果这个 url 是第一次请求下载，就回调 createCallback 去下载
        if (first) {
            // 下载
            createCallback();
        }
    });
}

// 暂停队列
- (void)setSuspended:(BOOL)suspended {
    [self.downloadQueue setSuspended:suspended];
}

@end
