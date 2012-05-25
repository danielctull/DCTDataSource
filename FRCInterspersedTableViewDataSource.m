//
//  FRCInterspersedTableViewDataSource.m
//  Tweetville
//
//  Created by Daniel Tull on 23.05.2012.
//  Copyright (c) 2012 Daniel Tull Limited. All rights reserved.
//

#import "FRCInterspersedTableViewDataSource.h"
#import "FRCObjectTableViewDataSource.h"

@implementation FRCInterspersedTableViewDataSource {
	__strong FRCObjectTableViewDataSource *_interspersedDataSource;
	NSUInteger _interspersedDataSourceCount;
	NSUInteger _childRowCount;
}
@synthesize childTableViewDataSource = _childTableViewDataSource;

- (id)init {
	if (!(self = [super init])) return nil;
	_interspersedDataSource = [FRCObjectTableViewDataSource new];
	_interspersedDataSourceCount = 0;
	_childRowCount = 0;
	return self;
}
 
- (void)setChildTableViewDataSource:(FRCTableViewDataSource *)childTableViewDataSource {
	_childTableViewDataSource = childTableViewDataSource;
	_childTableViewDataSource.parent = self;
}

- (void)setInterspersedCellClass:(Class)interspersedCellClass {
	_interspersedDataSource.cellClass = interspersedCellClass;
}
- (Class)interspersedCellClass {
	return _interspersedDataSource.cellClass;
}

- (void)reloadData {
	[super reloadData];
	_childRowCount = [self.childTableViewDataSource tableView:self.tableView numberOfRowsInSection:0];
	_interspersedDataSourceCount = 0;
}

- (void)performRowUpdate:(FRCTableViewDataSourceUpdateType)update
			   indexPath:(NSIndexPath *)indexPath
			   animation:(UITableViewRowAnimation)animation {
	
	if (update == FRCTableViewDataSourceUpdateTypeRowDelete)
		[self performDeleteWithIndexPath:indexPath animation:animation];
		
	else if (update == FRCTableViewDataSourceUpdateTypeRowInsert)
		[self performInsertWithIndexPath:indexPath animation:animation];
	
	else
		[super performRowUpdate:update indexPath:indexPath animation:animation];
}

- (void)performDeleteWithIndexPath:(NSIndexPath *)indexPath animation:(UITableViewRowAnimation)animation {
	
	_childRowCount--;
	[super performRowUpdate:FRCTableViewDataSourceUpdateTypeRowDelete indexPath:indexPath animation:animation];
	
	if (_childRowCount == 0) return;
	
	NSIndexPath *childIndexPath = [self convertIndexPath:indexPath toChildTableViewDataSource:self.childTableViewDataSource];
	NSInteger interspersedRowToDelete = indexPath.row + 1;
	if (childIndexPath.row == _childRowCount) interspersedRowToDelete = indexPath.row - 1;
	
	_interspersedDataSourceCount--;
	[super performRowUpdate:FRCTableViewDataSourceUpdateTypeRowDelete indexPath:[NSIndexPath indexPathForRow:interspersedRowToDelete inSection:0] animation:animation];
}

- (void)performInsertWithIndexPath:(NSIndexPath *)indexPath animation:(UITableViewRowAnimation)animation {
	
	_childRowCount++;
	[super performRowUpdate:FRCTableViewDataSourceUpdateTypeRowInsert indexPath:indexPath animation:animation];
	
	if (_childRowCount == 1) return;
	
	NSIndexPath *childIndexPath = [self convertIndexPath:indexPath toChildTableViewDataSource:self.childTableViewDataSource];
	NSInteger interspersedRowToInsert = indexPath.row - 1;
	if (childIndexPath.row == 0) interspersedRowToInsert = indexPath.row + 1;
	
	_interspersedDataSourceCount++;
	[super performRowUpdate:FRCTableViewDataSourceUpdateTypeRowInsert indexPath:[NSIndexPath indexPathForRow:interspersedRowToInsert inSection:0] animation:animation];
}

#pragma mark - FRCParentTableViewDataSource

- (NSArray *)childTableViewDataSources {
	return [NSArray arrayWithObjects:self.childTableViewDataSource, _interspersedDataSource, nil];
}

- (NSIndexPath *)convertIndexPath:(NSIndexPath *)indexPath fromChildTableViewDataSource:(FRCTableViewDataSource *)dataSource {
	
	if ([dataSource isEqual:_interspersedDataSource])
		return [NSIndexPath indexPathForRow:1 inSection:indexPath.section];
	
	NSInteger row = 2*indexPath.row;
	
	return [NSIndexPath indexPathForRow:row inSection:indexPath.section];	
}

- (NSIndexPath *)convertIndexPath:(NSIndexPath *)indexPath toChildTableViewDataSource:(FRCTableViewDataSource *)dataSource {
	
	if ([dataSource isEqual:_interspersedDataSource])
		return [NSIndexPath indexPathForRow:0 inSection:0];
	
	NSInteger row = indexPath.row;
		
	row = row/2;
	
	return [NSIndexPath indexPathForRow:row inSection:indexPath.section];
}

- (FRCTableViewDataSource *)childTableViewDataSourceForSection:(NSInteger)section {
	return self.childTableViewDataSource;
}

- (FRCTableViewDataSource *)childTableViewDataSourceForIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.row % 2 == 0) return self.childTableViewDataSource;
		
	return _interspersedDataSource;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	_childRowCount = [self.childTableViewDataSource tableView:tableView numberOfRowsInSection:section];
	if (_childRowCount < 2) return _childRowCount;
	return 2*_childRowCount - 1;
}

@end
