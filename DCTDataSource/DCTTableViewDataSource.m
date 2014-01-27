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
	[self.tableView beginUpdates];
}

- (void)performUpdate:(DCTDataSourceUpdate *)update {
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
}

- (void)endUpdates {
	[self.tableView endUpdates];
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

@end
