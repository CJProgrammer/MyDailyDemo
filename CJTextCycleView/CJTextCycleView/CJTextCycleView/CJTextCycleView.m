//
//  CJTextCycleView.m
//  CJTextCycleScrollView
//
//  Created by CJ on 2017/4/11.
//  Copyright © 2017年 CJ. All rights reserved.
//

#import "CJTextCycleView.h"
#import "CJTextCycleCell.h"

static NSInteger const count = 100000;
static CGFloat const timeInterval = 2;
static CGFloat const kItemHeight = 50;

@interface CJTextCycleView ()<UICollectionViewDataSource,UICollectionViewDelegate>

@property (nonatomic, weak) UICollectionView * collectionView; // 显示图片的collectionView
@property (nonatomic, weak) UICollectionViewFlowLayout * flowLayout;
@property (nonatomic, weak) NSTimer * timer;
@property (nonatomic, assign) NSInteger currentPage;

@end

@implementation CJTextCycleView

- (NSInteger)currentPage {
    if (!_currentPage) {
        _currentPage = 0;
    }
    return _currentPage;
}

- (void)awakeFromNib {
    [super awakeFromNib];
 
    [self setupCollectionView];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

        [self setupCollectionView];
    }
    return self;
}

// 设置collectionView
- (void)setupCollectionView {
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing = 0;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    flowLayout.itemSize = CGSizeMake(self.bounds.size.width, kItemHeight);
    self.flowLayout = flowLayout;
    
    UICollectionView * collectionView = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:flowLayout];
    collectionView.backgroundColor = [UIColor whiteColor];
    collectionView.pagingEnabled = YES;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.showsVerticalScrollIndicator = NO;
    collectionView.scrollsToTop = NO;
    collectionView.userInteractionEnabled = NO;
    [collectionView registerNib:[UINib nibWithNibName:@"CJTextCycleCell" bundle: [NSBundle mainBundle]] forCellWithReuseIdentifier:@"CJTextCycleCell"];
    collectionView.dataSource = self;
    collectionView.delegate = self;
    
    [self addSubview:collectionView];
    self.collectionView = collectionView;
    
    //开启定时器
    [self setupTimer];
}

- (void)setupTimer {
    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:timeInterval target:self selector:@selector(scrollToNextText) userInfo:nil repeats:YES];
    _timer = timer;
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

//每个循环要执行的东西
- (void)scrollToNextText {
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentPage inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
    if (self.currentPage == count - 1) {//如果是最后一个
        self.currentPage = 0;
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:self.currentPage inSection:0] atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
    }
    self.currentPage ++;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    CJTextCycleCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CJTextCycleCell" forIndexPath:indexPath];

    cell.type = arc4random()%3;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    //...
}

//解决当父View释放时，当前视图因为被Timer强引用而不能释放的问题
- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (!newSuperview) {
        [_timer invalidate];
        _timer = nil;
    }
}

//解决当timer释放后 回调scrollViewDidScroll时访问野指针导致崩溃
- (void)dealloc {
    self.collectionView.delegate = nil;
    self.collectionView.dataSource = nil;
}

@end
