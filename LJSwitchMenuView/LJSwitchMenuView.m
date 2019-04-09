//
//  LJSwitchMenuView.m
//  Lianjia_Beike_Home
//
//  Created by CJ on 2019/4/3.
//

#import "LJSwitchMenuView.h"
#import "LJSwitchMenuViewCell.h"

@interface LJSwitchMenuView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSArray <LJSwitchMenuViewCellTitleModel *>*titleModels;
@property (nonatomic, assign) CGPoint originPoint;
@property (nonatomic, strong) UIView *mySuperView;
@property (nonatomic, strong) UIControl *fullScreenControl;
@property (nonatomic, strong) UIView *menuView;
@property (nonatomic, strong) UIImageView *menuBackImageView;
@property (nonatomic, strong) UITableView *tableView;

@end

// show and hide animation duration
static NSTimeInterval const kAnimDuration = 0.2;
// cell height
static CGFloat const kCellHeight = 44.f;
// tableView's top bottom spacing
static CGFloat const kTopBottomSpacing = 10.f;

@implementation LJSwitchMenuView

- (instancetype)initWithTitles:(nonnull NSArray *)titles originPoint:(CGPoint)originPoint inSuperView:(UIView *)mySuperView {
    self = [super initWithFrame:CGRectZero];
    if (self) {
        // parse to titleModels
        [self parseToTitleModelsWithTitles:titles];
        _originPoint = originPoint;
        if (mySuperView) {
            _mySuperView = mySuperView;
        } else {
            _mySuperView = [UIApplication sharedApplication].keyWindow;
        }
        // set up self attributes
        [self setupSelfAttributes];
        // set up content views
        [self setupContentViews];
    }
    return self;
}

// set up self attributes
- (void)setupSelfAttributes {
    self.frame = self.mySuperView.bounds;
    self.alpha = 0;
    [self.mySuperView addSubview:self];
    
    _fullScreenControl = [[UIControl alloc] initWithFrame:self.bounds];
    [_fullScreenControl addTarget:self action:@selector(hide) forControlEvents:UIControlEventAllTouchEvents];
    [self addSubview:_fullScreenControl];
}

// set up content views
- (void)setupContentViews {
    
    // menu
    _menuView = [[UIView alloc] initWithFrame:CGRectMake(self.originPoint.x, self.originPoint.y, [self width], [self height])];
    _menuView.backgroundColor = [UIColor clearColor];
    [self addSubview:_menuView];
    
    // background image
    _menuBackImageView = [[UIImageView alloc] initWithFrame:_menuView.bounds];
    UIImage *menuBackImage = [LJHomeResource imageNamed:@"home_switch_menu_back"];
    CGSize size = menuBackImage.size;
    menuBackImage = [menuBackImage resizableImageWithCapInsets:UIEdgeInsetsMake(size.height/2.0, size.width/2.0, size.height/2.0, size.width/2.0) resizingMode:UIImageResizingModeStretch];
    _menuBackImageView.image = menuBackImage;
    [_menuView addSubview:_menuBackImageView];
    
    // tableView
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(25, kTopBottomSpacing, _menuView.width - 50, _menuView.height - kTopBottomSpacing * 2) style:UITableViewStylePlain];
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.scrollEnabled = NO;
    [_menuView addSubview:_tableView];
    
    [_tableView registerClass:[LJSwitchMenuViewCell class] forCellReuseIdentifier:NSStringFromClass([LJSwitchMenuViewCell class])];
}

#pragma mark - UITableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _titleModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_titleModels.count <= indexPath.row) {
        return [UITableViewCell new];
    }
    
    LJSwitchMenuViewCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([LJSwitchMenuViewCell class]) forIndexPath:indexPath];
    cell.titleModel = _titleModels[indexPath.row];
    return cell;
}

#pragma mark - UITableView Delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (_titleModels.count <= indexPath.row) {
        return;
    }
    
    if ([_delegate respondsToSelector:@selector(switchMenuDidSelectAtIndex:title:)]) {
        // 1.hide
        [self hide];
        
        // 2.make all cell selected NO
        for (LJSwitchMenuViewCellTitleModel *titleModel in _titleModels) {
            titleModel.isSelected = NO;
        }
        
        // 3.make selected cell YES
        LJSwitchMenuViewCellTitleModel *titleModel = _titleModels[indexPath.row];
        titleModel.isSelected = YES;
        [_tableView reloadData];
        
        [_delegate switchMenuDidSelectAtIndex:indexPath.row title:_titleModels[indexPath.row].title];
    }
}

#pragma mark - Action

// show
- (void)show {
    self.hidden = NO;
    [self.mySuperView bringSubviewToFront:self];
    [UIView animateWithDuration:kAnimDuration animations:^{
        self.alpha = 1;
    }];
}

// hide
- (void)hide {
    [UIView animateWithDuration:kAnimDuration animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        self.hidden = YES;
    }];
}

#pragma mark - Private

// parse to titleModels
- (void)parseToTitleModelsWithTitles:(NSArray *)titles {
    if (titles.count > 0) {
        NSMutableArray *titleModels = [NSMutableArray array];
        for (NSInteger i = 0; i < titles.count; i++) {
            NSString *title = titles[i];
            LJSwitchMenuViewCellTitleModel *titleModel = [[LJSwitchMenuViewCellTitleModel alloc] init];
            titleModel.title = title;
            titleModel.isSelected = i == 0 ? YES : NO;
            [titleModels addObject:titleModel];
        }
        _titleModels = titleModels;
    }
}

// width
- (CGFloat)width {
    if (_titleModels.count > 0) {
        for (LJSwitchMenuViewCellTitleModel *titleModel in _titleModels) {
            CGFloat titleWidth = [titleModel.title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 20) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:16.f]} context:nil].size.width;
            if (titleWidth < 50) {
                return 100;
            } else {
                return ceil(titleWidth + 50);
            }
        }
    }
    return 0;
}

// height
- (CGFloat)height {
    if (_titleModels.count > 0) {
        return _titleModels.count * kCellHeight + kTopBottomSpacing * 2;
    }
    return 0;
}

@end
