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
#import "DCTDataSourceUpdate.h"

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

	[_updates enumerateObjectsUsingBlock:^(DCTDataSourceUpdate *update, NSUInteger i, BOOL *stop) {

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

	[updates enumerateObjectsUsingBlock:^(DCTDataSourceUpdate *update, NSUInteger i, BOOL *stop) {

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

- (void)_performUpdate:(DCTDataSourceUpdate *)update {
	[_updates addObject:update];
}

- (void)performSectionUpdate:(DCTDataSourceUpdateType)updateType
				sectionIndex:(NSInteger)index {

	DCTDataSourceUpdate *update = [DCTDataSourceUpdate new];
	update.animation = self.insertionAnimation;
	update.type = updateType;
	update.section = index;
	[self _performUpdate:update];
}

- (void)performRowUpdate:(DCTDataSourceUpdateType)updateType
			   indexPath:(NSIndexPath *)indexPath {

	DCTDataSourceUpdate *update = [DCTDataSourceUpdate new];
	update.animation = self.insertionAnimation;
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
	return [self numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self numberOfItemsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	id object = [self.dataSource objectAtIndexPath:indexPath];
	NSString *cellIdentifier = self.cellReuseIdentifierHandler(indexPath, object);
    UITableViewCell *cell = [tv dct_dequeueReusableCellWithIdentifier:cellIdentifier];

	if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
											 reuseIdentifier:cellIdentifier];

	return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

	if (![self.dataSource conformsToProtocol:@protocol(DCTEditableDataSource)]) return NO;

	return [((id<DCTEditableDataSource>)self.dataSource) canEditObjectAtIndexPath:indexPath];
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {

	if (![self.dataSource conformsToProtocol:@protocol(DCTEditableDataSource)]) return NO;

	return [((id<DCTEditableDataSource>)self.dataSource) canMoveObjectAtIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView
commitEditingStyle:(UITableViewCellEditingStyle)editingStyle
forRowAtIndexPath:(NSIndexPath *)indexPath {

	if (![self.dataSource conformsToProtocol:@protocol(DCTEditableDataSource)]) return;

	DCTDataSource<DCTEditableDataSource> *editableDataSource = (DCTDataSource<DCTEditableDataSource> *)self.dataSource;

	if (editingStyle == UITableViewCellEditingStyleDelete)
		[editableDataSource removeObjectAtIndexPath:indexPath];

	else if (editingStyle == UITableViewCellEditingStyleInsert)
		[editableDataSource insertObject:[editableDataSource generateObject] atIndexPath:indexPath];
}

- (void)tableView:(UITableView *)tableView
moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath
	  toIndexPath:(NSIndexPath *)destinationIndexPath {

	if (![self.dataSource conformsToProtocol:@protocol(DCTEditableDataSource)]) return;

	DCTDataSource<DCTEditableDataSource> *editableDataSource = (DCTDataSource<DCTEditableDataSource> *)self.dataSource;
	[editableDataSource moveObjectAtIndexPath:sourceIndexPath toIndexPath:destinationIndexPath];
}

@end
