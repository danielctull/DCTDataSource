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


/**
 *  A class to adapt a DCTDataSource to a UITableView.
 */
@interface DCTTableViewDataSource : DCTParentDataSource <UITableViewDataSource>

/**
 *  Creates a table view data source.
 *
 *  Assigns itself as the dataSource of the table view.
 *
 *  @param tableView  The table view
 *  @param dataSource The root data source to adapt
 *
 *  @return The table view data source.
 */
- (id)initWithTableView:(UITableView *)tableView dataSource:(DCTDataSource *)dataSource;
@property (nonatomic, readonly, weak) UITableView *tableView;
@property (nonatomic, readonly) DCTDataSource *dataSource;

@property (nonatomic, weak) id<DCTTableViewDataSourceDelegate> delegate;

@property (nonatomic) NSString *cellReuseIdentifier;
@property (nonatomic) UITableViewRowAnimation animation;

@property (nonatomic) DCTTableViewDataSourceReloadType reloadType;
@property (nonatomic) NSArray *sectionIndexTitles;

@end



@protocol DCTTableViewDataSourceDelegate <NSObject>

@optional
- (NSString *)tableViewDataSource:(DCTTableViewDataSource *)tableViewDataSource cellReuseIdentifierForCellAtIndexPath:(NSIndexPath *)indexPath;
- (UITableViewRowAnimation)tableViewDataSource:(DCTTableViewDataSource *)tableViewDataSource animationForCellAtIndexPath:(NSIndexPath *)indexPath updateType:(DCTDataSourceUpdateType)updateType;
- (UITableViewCell *)tableViewDataSource:(DCTTableViewDataSource *)tableViewDataSource cellWithIdentifier:(NSString *)identifier forIndexPath:(NSIndexPath *)indexPath;
- (NSInteger)tableViewDataSource:(DCTTableViewDataSource *)tableViewDataSource sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index;
- (BOOL)tableViewDataSource:(DCTTableViewDataSource *)tableViewDataSource shouldReloadRowAtIndexPath:(NSIndexPath *)indexPath;

@end
