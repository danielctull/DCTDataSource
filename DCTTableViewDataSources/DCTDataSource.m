/*
 DCTTableViewDataSource.h
 DCTTableViewDataSources
 
 Created by Daniel Tull on 20.05.2011.
 
 
 
 Copyright (c) 2011 Daniel Tull. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 * Neither the name of the author nor the names of its contributors may be used
 to endorse or promote products derived from this software without specific
 prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "DCTDataSource.h"
#import "DCTTableViewCell.h"
#import "UITableView+DCTTableViewDataSources.h"
#import "UITableView+DCTNibRegistration.h"
#import "DCTParentDataSource.h"
#import "_DCTDataSourceUpdate.h"

void DCTDataSourceUpdateTypeAdd(DCTDataSourceUpdateType type, DCTDataSourceUpdateType typeToAdd) {
	
	if (type == DCTDataSourceUpdateTypeUnknown)
		type = typeToAdd;
	
	type = (type | typeToAdd);
}

NSInteger const DCTTableViewDataSourceNoAnimationSet = -1912;

@implementation DCTDataSource {
	__strong NSMutableArray *_updates;
}

#pragma mark - NSObject

- (void)dealloc {
	_parent = nil;
}

- (id)init {
    
    if (!(self = [super init])) return nil;
	
	_insertionAnimation = DCTTableViewDataSourceNoAnimationSet;
	_deletionAnimation = DCTTableViewDataSourceNoAnimationSet;
	_reloadAnimation = DCTTableViewDataSourceNoAnimationSet;
	
    return self;
}

#pragma mark - DCTTableViewDataSource

- (void)setTableView:(UITableView *)tableView {
	_tableView = tableView;
	[_tableView registerClass:[DCTTableViewCell class] forCellReuseIdentifier:@"DCTTableViewCell"];
}

- (void)reloadData {
	[self beginUpdates];
	[self enumerateIndexPathsUsingBlock:^(NSIndexPath *indexPath, BOOL *stop) {
		
		[self performRowUpdate:DCTDataSourceUpdateTypeRowReload
					 indexPath:indexPath
					 animation:self.reloadAnimation];
		
	}];
	[self endUpdates];
}


- (NSInteger)numberOfSections {
	return 0;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
	return 0;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath;
}

#pragma mark - Updating the table view

- (void)beginUpdates {
	
	if (self.parent) {
		[self.parent beginUpdates];
		return;
	}
	
	_updates = [NSMutableArray new];
}

- (void)endUpdates {
	[self _endUpdates:self.reloadType];
	_updates = nil;
}

- (void)_endUpdates:(DCTTableViewDataSourceReloadType)reloadType {
	
	if (self.parent)
		[self.parent _endUpdates:reloadType];
	
	else if (reloadType == DCTTableViewDataSourceReloadTypeDefault)
		[self _endUpdatesDefault];
	else
		[self _endUpdatesNonDefault:reloadType];
}

- (void)_endUpdatesDefault {
		
	[self.tableView beginUpdates];
	
	[_updates enumerateObjectsUsingBlock:^(_DCTDataSourceUpdate *update, NSUInteger i, BOOL *stop) {
		
		if (update.animation == DCTTableViewDataSourceNoAnimationSet)
			update.animation = UITableViewRowAnimationAutomatic;
		
		switch (update.type) {
			
			case DCTDataSourceUpdateTypeRowInsert:
				[self.tableView insertRowsAtIndexPaths:@[update.indexPath] withRowAnimation:update.animation];
				break;
			
			case DCTDataSourceUpdateTypeRowDelete:
				[self.tableView deleteRowsAtIndexPaths:@[update.indexPath] withRowAnimation:update.animation];
				break;
				
			case DCTDataSourceUpdateTypeRowReload:
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
				
			case DCTDataSourceUpdateTypeRowInsert:
				indexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
				break;
				
			case DCTDataSourceUpdateTypeRowDelete:
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
	
	if (update.animation == DCTTableViewDataSourceNoAnimationSet) {
		
		switch (update.type) {
			case DCTDataSourceUpdateTypeRowInsert:
			case DCTDataSourceUpdateTypeSectionInsert:
				update.animation = self.insertionAnimation;
				break;
				
			case DCTDataSourceUpdateTypeRowDelete:
			case DCTDataSourceUpdateTypeSectionDelete:
				update.animation = self.deletionAnimation;
				break;
				
			case DCTDataSourceUpdateTypeRowReload:
				update.animation = self.reloadAnimation;
				break;
				
			default:
				break;
		}
	}
	
	if (self.parent) {
		
		if ([update isSectionUpdate]) {
			update.section = [self.parent convertSection:update.section fromChildTableViewDataSource:self];
			[self.parent _performUpdate:update];
			return;
		}
		
		update.indexPath = [self.parent convertIndexPath:update.indexPath fromChildTableViewDataSource:self];
		[self.parent _performUpdate:update];
		return;
	}
	
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

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return self.sectionFooterTitle;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return self.sectionHeaderTitle;
}

@end
