//
//  LJSwitchMenuViewCell.h
//  Lianjia_Beike_Home
//
//  Created by CJ on 2019/4/3.
//

#import <UIKit/UIKit.h>

@class LJSwitchMenuViewCellTitleModel;

@interface LJSwitchMenuViewCell : UITableViewCell

@property (nonatomic, strong) LJSwitchMenuViewCellTitleModel *titleModel;

@end

@interface LJSwitchMenuViewCellTitleModel : NSObject

@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) BOOL isSelected;

@end

