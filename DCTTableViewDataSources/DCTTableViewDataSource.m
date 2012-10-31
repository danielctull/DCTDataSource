//
//  DCTTableViewDataSource.m
//  DCTTableViewDataSources
//
//  Created by Daniel Tull on 30/10/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTTableViewDataSource.h"
#import "UITableView+DCTNibRegistration.h"
#import "DCTTableViewCell.h"
#import "_DCTDataSourceUpdate.h"

@implementation DCTTableViewDataSource {
	__strong NSMutableArray *_updates;
}

- (id)initWithTableView:(UITableView *)tableView dataSource:(DCTDataSource *)dataSource {
	self = [super init];
	if (!self) return nil;
	_dataSource = dataSource;
	_tableView = tableView;
	_tableView.dataSource = self;

	[_tableView registerClass:[DCTTableViewCell class] forCellReuseIdentifier:@"DCTTableViewCell"];
	_cellReuseIdentifierHandler = ^NSString *(NSIndexPath *indexPath, id object) {
		return @"DCTTableViewCell";
	};

	return self;
}

#pragma mark - Updating the table view

- (void)beginUpdates {
	_updates = [NSMutableArray new];
}

- (void)endUpdates {
	[self _endUpdates:self.reloadType];
	_updates = nil;
}

- (void)_endUpdates:(DCTTableViewDataSourceReloadType)reloadType {

	if (reloadType == DCTTableViewDataSourceReloadTypeDefault)
		[self _endUpdatesDefault];
	else
		[self _endUpdatesNonDefault:reloadType];
}

- (void)_endUpdatesDefault {

	[self.tableView beginUpdates];

	[_updates enumerateObjectsUsingBlock:^(_DCTDataSourceUpdate *update, NSUInteger i, BOOL *stop) {

		switch (update.type) {

			case DCTDataSourceUpdateTypeItemInsert:
				[self.tableView insertRowsAtIndexPaths:@[update.indexPath] withRowAnimation:update.animation];
				break;

			case DCTDataSourceUpdateTypeItemDelete:
				[self.tableView deleteRowsAtIndexPaths:@[update.indexPath] withRowAnimation:update.animation];
				break;

			case DCTDataSourceUpdateTypeItemReload:
				[self.tableView reloadRowsAtIndexPaths:@[update.indexPath] withRowAnimation:update.animation];
				break;

			case DCTDataSourceUpdateTypeSectionInsert:
				[self.tableView insertSections:[NSIndexSet indexSetWithIndex:update.section] withRowAnimation:update.animation];
				break;

			case DCTDataSourceUpdateTypeSectionDelete:
				[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:update.section] withRowAnimation:update.animation];
				break;

			default:
				break;
		}
	}];

	[self.tableView endUpdates];
}

- (void)_endUpdatesNonDefault:(DCTTableViewDataSourceReloadType)reloadType {

	NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];

	if ([indexPaths count] == 0) {
		[self.tableView reloadData];
		return;
	}

	__block NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
	if (reloadType == DCTTableViewDataSourceReloadTypeBottom)
		indexPath = [indexPaths lastObject];

	CGFloat firstVisibleCellYPosition = [self.tableView rectForRowAtIndexPath:indexPath].origin.y;

	NSArray *updates = [_updates sortedArrayUsingSelector:@selector(compare:)];

	[updates enumerateObjectsUsingBlock:^(_DCTDataSourceUpdate *update, NSUInteger i, BOOL *stop) {

		if ([update.indexPath compare:indexPath] == NSOrderedDescending) {
			*stop = YES;
			return;
		}

		switch (update.type) {

			case DCTDataSourceUpdateTypeItemInsert:
				indexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
				break;

			case DCTDataSourceUpdateTypeItemDelete:
				indexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
				break;

			case DCTDataSourceUpdateTypeSectionInsert:
				indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section+1];
				break;

			case DCTDataSourceUpdateTypeSectionDelete:
				indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
				break;

			default:
				break;
		}
	}];

	[self.tableView reloadData];

	CGFloat newFirstVisibleCellYPosition = [self.tableView rectForRowAtIndexPath:indexPath].origin.y;

	CGPoint offset = self.tableView.contentOffset;
	offset.y += (newFirstVisibleCellYPosition - firstVisibleCellYPosition);
	self.tableView.contentOffset = offset;
}

- (void)_performUpdate:(_DCTDataSourceUpdate *)update {
	[_updates addObject:update];
}

- (void)performSectionUpdate:(DCTDataSourceUpdateType)updateType
				sectionIndex:(NSInteger)index
				   animation:(UITableViewRowAnimation)animation {

	_DCTDataSourceUpdate *update = [_DCTDataSourceUpdate new];
	update.animation = animation;
	update.type = updateType;
	update.section = index;
	[self _performUpdate:update];
}

- (void)performRowUpdate:(DCTDataSourceUpdateType)updateType
			   indexPath:(NSIndexPath *)indexPath
			   animation:(UITableViewRowAnimation)animation {

	_DCTDataSourceUpdate *update = [_DCTDataSourceUpdate new];
	update.animation = animation;
	update.type = updateType;
	update.indexPath = indexPath;
	[self _performUpdate:update];
}

- (void)enumerateIndexPathsUsingBlock:(void(^)(NSIndexPath *, BOOL *stop))enumerator {

	NSInteger sectionCount = [self numberOfSectionsInTableView:self.tableView];

	for (NSInteger section = 0; section < sectionCount; section++) {

		NSInteger rowCount = [self tableView:self.tableView numberOfRowsInSection:section];

		for (NSInteger row = 0; row < rowCount; row++) {
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:section];
			BOOL stop = NO;
			enumerator(indexPath, &stop);
			if (stop) return;
		}
	}
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self.dataSource numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.dataSource numberOfItemsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	NSString *cellIdentifier = [self _cellReuseIdentifierAtIndexPath:indexPath];
    UITableViewCell *cell = [tv dct_dequeueReusableCellWithIdentifier:cellIdentifier];

	if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
											 reuseIdentifier:cellIdentifier];

	id object = [self.dataSource objectAtIndexPath:indexPath];

	if (self.cellConfigurer != NULL) self.cellConfigurer(cell, indexPath, object);

	return cell;
}

- (NSString *)_cellReuseIdentifierAtIndexPath:(NSIndexPath *)indexPath {
	id object = [self.dataSource objectAtIndexPath:indexPath];
	return self.cellReuseIdentifierHandler(indexPath, object);
}

@end
