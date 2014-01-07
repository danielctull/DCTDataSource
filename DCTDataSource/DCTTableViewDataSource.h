//
//  DCTTableViewDataSource.h
//  DCTDataSource
//
//  Created by Daniel Tull on 30/10/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

@import UIKit;
#import "DCTParentDataSource.h"

extern const struct DCTTableViewDataSourceUserInfoKeys {
	__unsafe_unretained NSString *cellReuseIdentifier;
	__unsafe_unretained NSString *animation;
	__unsafe_unretained NSString *sectionHeaderTitle;
	__unsafe_unretained NSString *sectionFooterTitle;
} DCTTableViewDataSourceUserInfoKeys;


typedef enum {
	DCTTableViewDataSourceReloadTypeDefault = 0,
	DCTTableViewDataSourceReloadTypeBottom,
	DCTTableViewDataSourceReloadTypeTop
} DCTTableViewDataSourceReloadType;

@protocol DCTTableViewDataSourceDelegate;



@interface DCTTableViewDataSource : DCTParentDataSource <UITableViewDataSource>

- (id)initWithTableView:(UITableView *)tableView dataSource:(DCTDataSource *)dataSource;
@property (nonatomic, readonly, weak) UITableView *tableView;
@property (nonatomic, readonly) DCTDataSource *dataSource;

@property (nonatomic, weak) id<DCTTableViewDataSourceDelegate> delegate;

@property (nonatomic) NSString *cellReuseIdentifier;
@property (nonatomic) UITableViewRowAnimation animation;

@property (nonatomic) DCTTableViewDataSourceReloadType reloadType;

@end



@protocol DCTTableViewDataSourceDelegate <NSObject>

@optional
- (NSString *)tableViewDataSource:(DCTTableViewDataSource *)tableViewDataSource cellReuseIdentifierForCellAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewRowAnimation)tableViewDataSource:(DCTTableViewDataSource *)tableViewDataSource animationForCellAtIndexPath:(NSIndexPath *)indexPath updateType:(DCTDataSourceUpdateType)updateType;

@end
