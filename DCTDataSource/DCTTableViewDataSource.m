//
//  DCTTableViewDataSource.m
//  DCTDataSource
//
//  Created by Daniel Tull on 30/10/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTTableViewDataSource.h"

const struct DCTTableViewDataSourceUserInfoKeys DCTTableViewDataSourceUserInfoKeys = {
	.cellReuseIdentifier = @"cellReuseIdentifier",
	.animation = @"animation",
	.sectionHeaderTitle = @"sectionHeaderTitle",
	.sectionFooterTitle = @"sectionFooterTitle"
};

typedef id (^DCTTableViewDataSourceObjectOverideBlock)();

@interface DCTTableViewDataSource ()
@property (nonatomic) NSMutableArray *updates;
@property (nonatomic) NSMutableDictionary *objectOverideBlocks;
@end

@implementation DCTTableViewDataSource

- (id)initWithTableView:(UITableView *)tableView dataSource:(DCTDataSource *)dataSource {
	self = [super init];
	if (!self) return nil;
	_dataSource = dataSource;
	_dataSource.parent = self;
	_tableView = tableView;
	_tableView.dataSource = self;
	return self;
}

#pragma mark - Properties

- (NSString *)cellReuseIdentifier {
	return [self userInfoValueForKey:DCTTableViewDataSourceUserInfoKeys.cellReuseIdentifier];
}

- (void)setCellReuseIdentifier:(NSString *)cellReuseIdentifier {
	[self setUserInfoValue:cellReuseIdentifier forKey:DCTTableViewDataSourceUserInfoKeys.cellReuseIdentifier];
}

- (UITableViewRowAnimation)animation {
	return [[self userInfoValueForKey:DCTTableViewDataSourceUserInfoKeys.animation] integerValue];
}

- (void)setAnimation:(UITableViewRowAnimation)animation {
	[self setUserInfoValue:@(animation) forKey:DCTTableViewDataSourceUserInfoKeys.animation];
}

- (UITableViewRowAnimation)animationForIndexPath:(NSIndexPath *)indexPath updateType:(DCTDataSourceUpdateType)updateType {

	if ([self.delegate respondsToSelector:@selector(tableViewDataSource:animationForCellAtIndexPath:updateType:)])
		return [self.delegate tableViewDataSource:self animationForCellAtIndexPath:indexPath updateType:updateType];

	//NSNumber *animation = [self userInfoValueForKey:DCTTableViewDataSourceUserInfoKeys.animation indexPath:indexPath];
	return UITableViewRowAnimationAutomatic;// [animation integerValue];
}

- (NSString *)cellReuseIdentifierForIndexPath:(NSIndexPath *)indexPath {

	if ([self.delegate respondsToSelector:@selector(tableViewDataSource:cellReuseIdentifierForCellAtIndexPath:)])
		return [self.delegate tableViewDataSource:self cellReuseIdentifierForCellAtIndexPath:indexPath];

	return [self userInfoValueForKey:DCTTableViewDataSourceUserInfoKeys.cellReuseIdentifier indexPath:indexPath];
}

- (NSArray *)childDataSources {
	return @[self.dataSource];
}

#pragma mark - Updating the table view

- (void)reloadData {
	[self.tableView reloadData];
}

- (void)beginUpdates {
	self.updates = [NSMutableArray new];
	self.objectOverideBlocks = [NSMutableDictionary new];
}

- (void)endUpdates {
	self.objectOverideBlocks = nil;
	[self _endUpdates:self.reloadType];
	self.updates = nil;
}

- (void)_endUpdates:(DCTTableViewDataSourceReloadType)reloadType {

	// If the updates were all reloads and the delegate has refused them all,
	// we'll have no updates to perform
	if (self.updates.count == 0) return;

	if (reloadType == DCTTableViewDataSourceReloadTypeDefault)
		[self _endUpdatesDefault];
	else
		[self _endUpdatesNonDefault:reloadType];
}

- (void)_endUpdatesDefault {

	[self.tableView beginUpdates];

	[self.updates enumerateObjectsUsingBlock:^(DCTDataSourceUpdate *update, NSUInteger i, BOOL *stop) {

		NSIndexPath *indexPath = update.oldIndexPath ? update.oldIndexPath : update.newIndexPath;
		UITableViewRowAnimation animation = [self animationForIndexPath:indexPath updateType:update.type];

		switch (update.type) {

			case DCTDataSourceUpdateTypeItemInsert:
				[self.tableView insertRowsAtIndexPaths:@[update.newIndexPath] withRowAnimation:animation];
				break;

			case DCTDataSourceUpdateTypeItemDelete:
				[self.tableView deleteRowsAtIndexPaths:@[update.oldIndexPath] withRowAnimation:animation];
				break;

			case DCTDataSourceUpdateTypeItemReload:
				[self.tableView reloadRowsAtIndexPaths:@[update.oldIndexPath] withRowAnimation:animation];
				break;

			case DCTDataSourceUpdateTypeSectionInsert:
				[self.tableView insertSections:[NSIndexSet indexSetWithIndex:update.section] withRowAnimation:animation];
				break;

			case DCTDataSourceUpdateTypeSectionDelete:
				[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:update.section] withRowAnimation:animation];
				break;

			case DCTDataSourceUpdateTypeItemMove:
				[self.tableView moveRowAtIndexPath:update.oldIndexPath toIndexPath:update.newIndexPath];
				break;
		}
	}];

	NSArray *selectedRows = [self.tableView indexPathsForSelectedRows];

	[self.tableView endUpdates];

	for (NSIndexPath *indexPath in selectedRows)
		[self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
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

	NSArray *updates = [self.updates sortedArrayUsingSelector:@selector(compare:)];

	[updates enumerateObjectsUsingBlock:^(DCTDataSourceUpdate *update, NSUInteger i, BOOL *stop) {

		NSIndexPath *updateIndexPath = update.oldIndexPath ? update.oldIndexPath : update.newIndexPath;
		if ([updateIndexPath compare:indexPath] == NSOrderedDescending) {
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

			case DCTDataSourceUpdateTypeItemMove:
			case DCTDataSourceUpdateTypeItemReload:
				break;
		}
	}];

	[self.tableView reloadData];

	CGFloat newFirstVisibleCellYPosition = [self.tableView rectForRowAtIndexPath:indexPath].origin.y;

	CGPoint offset = self.tableView.contentOffset;
	offset.y += (newFirstVisibleCellYPosition - firstVisibleCellYPosition);
	self.tableView.contentOffset = offset;
}

- (void)performUpdate:(DCTDataSourceUpdate *)update {

	if (update.type == DCTDataSourceUpdateTypeItemReload) {
		NSIndexPath *indexPath = update.oldIndexPath;
		if ([self.delegate respondsToSelector:@selector(tableViewDataSource:shouldReloadRowAtIndexPath:)]
			&& ![self.delegate tableViewDataSource:self shouldReloadRowAtIndexPath:indexPath])
			return;
	} else if (update.type == DCTDataSourceUpdateTypeItemMove) {

		NSIndexPath *oldIndexPath = update.oldIndexPath;
		NSIndexPath *newIndexPath = update.newIndexPath;
		DCTTableViewDataSourceObjectOverideBlock block = ^id {
			return [self objectAtIndexPath:newIndexPath];
		};
		self.objectOverideBlocks[oldIndexPath] = block;
		[self.tableView reloadRowsAtIndexPaths:@[oldIndexPath] withRowAnimation:UITableViewRowAnimationNone];
	}

	[self.updates addObject:update];
}
/*
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
}*/

#pragma mark - DCTDataSource

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {

	DCTTableViewDataSourceObjectOverideBlock block = self.objectOverideBlocks[indexPath];
	if (block) return block();

	return [super objectAtIndexPath:indexPath];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self numberOfItemsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	NSString *cellIdentifier = [self cellReuseIdentifierForIndexPath:indexPath];

	if ([self.delegate respondsToSelector:@selector(tableViewDataSource:cellWithIdentifier:forIndexPath:)])
		return [self.delegate tableViewDataSource:self cellWithIdentifier:cellIdentifier forIndexPath:indexPath];

	return [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	DCTDataSource *dataSource = [self childDataSourceForSection:section];
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
	return [dataSource userInfoValueForKey:DCTTableViewDataSourceUserInfoKeys.sectionHeaderTitle indexPath:indexPath];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	DCTDataSource *dataSource = [self childDataSourceForSection:section];
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:section];
	return [dataSource userInfoValueForKey:DCTTableViewDataSourceUserInfoKeys.sectionFooterTitle indexPath:indexPath];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	return self.sectionIndexTitles;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {

	if ([self.delegate respondsToSelector:@selector(tableViewDataSource:sectionForSectionIndexTitle:atIndex:)])
		return [self.delegate tableViewDataSource:self sectionForSectionIndexTitle:title atIndex:index];

	return index;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {

	id<UITableViewDelegate> delegate = tableView.delegate;
	if ([delegate respondsToSelector:@selector(tableView:editActionsForRowAtIndexPath:)]) {
		NSArray *editActions = [delegate tableView:tableView editActionsForRowAtIndexPath:indexPath];
		return editActions.count > 0;
	}

	return NO;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {}

@end
