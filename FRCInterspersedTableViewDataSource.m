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
@synthesize showInterspersedCellOnBottom = _showInterspersedCellOnBottom;
@synthesize showInterspersedCellOnTop = _showInterspersedCellOnTop;

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
}

- (void)performDeleteWithIndexPath:(NSIndexPath *)indexPath animation:(UITableViewRowAnimation)animation {
	
	_childRowCount--;
	[super performRowUpdate:FRCTableViewDataSourceUpdateTypeRowDelete indexPath:indexPath animation:animation];
	
	if (_childRowCount == 0) {
		
		NSInteger interspersedBottomRow = 1;
		
		if (self.showInterspersedCellOnTop) {
			interspersedBottomRow++;
			[super performRowUpdate:FRCTableViewDataSourceUpdateTypeRowDelete
						  indexPath:[NSIndexPath indexPathForRow:0 inSection:0]
						  animation:animation];
		}
		
		if (self.showInterspersedCellOnBottom)
			[super performRowUpdate:FRCTableViewDataSourceUpdateTypeRowDelete
						  indexPath:[NSIndexPath indexPathForRow:interspersedBottomRow inSection:0]
						  animation:animation];
		
		return;
	}
	
	NSIndexPath *childIndexPath = [self convertIndexPath:indexPath toChildTableViewDataSource:self.childTableViewDataSource];
	NSInteger interspersedRowToDelete = indexPath.row + 1;
	if (childIndexPath.row == _childRowCount) interspersedRowToDelete = indexPath.row - 1;
	
	_interspersedDataSourceCount--;
	[super performRowUpdate:FRCTableViewDataSourceUpdateTypeRowDelete indexPath:[NSIndexPath indexPathForRow:interspersedRowToDelete inSection:0] animation:animation];
}

- (void)performInsertWithIndexPath:(NSIndexPath *)indexPath animation:(UITableViewRowAnimation)animation {
	
	if (_childRowCount == 0) {
		
		NSInteger interspersedBottomRow = 1;
		
		if (self.showInterspersedCellOnTop) {
			interspersedBottomRow++;
			[super performRowUpdate:FRCTableViewDataSourceUpdateTypeRowInsert
						  indexPath:[NSIndexPath indexPathForRow:0 inSection:0]
						  animation:animation];
		}
		
		_childRowCount++;
		[super performRowUpdate:FRCTableViewDataSourceUpdateTypeRowInsert indexPath:indexPath animation:animation];
		
		if (self.showInterspersedCellOnBottom)
			[super performRowUpdate:FRCTableViewDataSourceUpdateTypeRowInsert
						  indexPath:[NSIndexPath indexPathForRow:interspersedBottomRow inSection:0]
						  animation:animation];
		
		return;
	}
	
	_childRowCount++;
	[super performRowUpdate:FRCTableViewDataSourceUpdateTypeRowInsert indexPath:indexPath animation:animation];
	
	NSIndexPath *childIndexPath = [self convertIndexPath:indexPath toChildTableViewDataSource:self.childTableViewDataSource];
	NSInteger interspersedRowToInsert = indexPath.row - 1;
	if (childIndexPath.row == 0) interspersedRowToInsert = indexPath.row + 1;
	
	_interspersedDataSourceCount++;
	[super performRowUpdate:FRCTableViewDataSourceUpdateTypeRowInsert indexPath:[NSIndexPath indexPathForRow:interspersedRowToInsert inSection:0] animation:animation];
}

#pragma mark - FRCParentTableViewDataSource

- (NSArray *)childTableViewDataSources {
	return [NSArray arrayWithObjects:self.childTableViewDataSource, nil];
}

- (NSIndexPath *)convertIndexPath:(NSIndexPath *)indexPath fromChildTableViewDataSource:(FRCTableViewDataSource *)dataSource {
	
	if ([dataSource isEqual:_interspersedDataSource]) {
	
		if (self.showInterspersedCellOnTop)
			return [NSIndexPath indexPathForRow:0 inSection:indexPath.section];
		
		return [NSIndexPath indexPathForRow:1 inSection:indexPath.section];
	}
	
	NSInteger row = 2*indexPath.row;
		
	if (self.showInterspersedCellOnTop) row++;
	
	return [NSIndexPath indexPathForRow:row inSection:indexPath.section];	
}

- (NSIndexPath *)convertIndexPath:(NSIndexPath *)indexPath toChildTableViewDataSource:(FRCTableViewDataSource *)dataSource {
	
	if ([dataSource isEqual:_interspersedDataSource])
		return [NSIndexPath indexPathForRow:0 inSection:0];
	
	NSInteger row = indexPath.row;
	
	if (self.showInterspersedCellOnTop) row--;
	
	row = row/2;
	
	return [NSIndexPath indexPathForRow:row inSection:indexPath.section];
}

- (FRCTableViewDataSource *)childTableViewDataSourceForSection:(NSInteger)section {
	return self.childTableViewDataSource;
}

- (FRCTableViewDataSource *)childTableViewDataSourceForIndexPath:(NSIndexPath *)indexPath {
	
	BOOL isEvenRow = (indexPath.row % 2 == 0);
	
	if (self.showInterspersedCellOnTop) isEvenRow = !isEvenRow;
		
	if (isEvenRow) return self.childTableViewDataSource;
		
	return _interspersedDataSource;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger amount = [self.childTableViewDataSource tableView:tableView numberOfRowsInSection:section];
	if (amount == 0) return 0;
	amount += _interspersedDataSourceCount;
	if (self.showInterspersedCellOnTop) amount++;
	if (self.showInterspersedCellOnBottom) amount++;
	return amount;
}

@end
