//
//  DCTTableViewDataSource.h
//  DCTTableViewDataSources
//
//  Created by Daniel Tull on 30/10/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DCTParentDataSource.h"

@interface DCTTableViewDataSource : DCTParentDataSource <UITableViewDataSource>

- (id)initWithTableView:(UITableView *)tableView dataSource:(DCTDataSource *)dataSource;
@property (nonatomic, readonly, weak) UITableView *tableView;
@property (nonatomic, readonly, strong) DCTDataSource *dataSource;

@property (nonatomic, copy) NSString *(^cellReuseIdentifierHandler)(NSIndexPath *indexPath, id object);

@property (nonatomic, assign) DCTTableViewDataSourceReloadType reloadType;
@property (nonatomic, assign) UITableViewRowAnimation insertionAnimation;
@property (nonatomic, assign) UITableViewRowAnimation reloadAnimation;
@property (nonatomic, assign) UITableViewRowAnimation deletionAnimation;

@end
