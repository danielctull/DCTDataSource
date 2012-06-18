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

#import "DCTTableViewDataSource.h"
#import "DCTTableViewCell.h"
#import "UITableView+DCTTableViewDataSources.h"
#import "UITableView+DCTNibRegistration.h"
#import "DCTParentTableViewDataSource.h"


@interface DCTTableViewDataSourceUpdate : NSObject
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) DCTTableViewDataSourceUpdateType type;
@property (nonatomic, assign) UITableViewRowAnimation animation;
@end


BOOL DCTTableViewDataSourceUpdateTypeIncludes(DCTTableViewDataSourceUpdateType type, DCTTableViewDataSourceUpdateType testType) {
	return (type & testType) == testType;
}

NSInteger const DCTTableViewDataSourceNoAnimationSet = -1912;

@implementation DCTTableViewDataSource {
	__strong NSMutableDictionary *_cellClassDictionary;
	DCTTableViewDataSourceUpdateType _updateTypes;
	__strong NSMutableSet *_cellClasses;
	__strong NSMutableSet *_setupCellClasses;
	
	__strong NSMutableArray *_updates;
	
	__strong NSIndexPath *_firstVisibleCellIndexPath;
	CGFloat _firstVisibleCellYPosition;
}

@synthesize tableView;
@synthesize cellClass = _cellClass;
@synthesize parent = _parent;
@synthesize sectionHeaderTitle;
@synthesize sectionFooterTitle;
@synthesize cellConfigurer;
@synthesize tableViewUpdateHandler;
@synthesize insertionAnimation;
@synthesize deletionAnimation;
@synthesize reloadAnimation;
@synthesize cellClassHandler = _cellClassHandler;

#pragma mark - NSObject

- (void)dealloc {
	_parent = nil;
}

- (id)init {
    
    if (!(self = [super init])) return nil;
	
	self.insertionAnimation = DCTTableViewDataSourceNoAnimationSet;
	self.deletionAnimation = DCTTableViewDataSourceNoAnimationSet;
	self.reloadAnimation = DCTTableViewDataSourceNoAnimationSet;
	self.cellClass = [DCTTableViewCell class];
	_cellClassDictionary = [NSMutableDictionary new];
	_cellClasses = [NSMutableSet new];
	_setupCellClasses = [NSMutableSet new];
	
    return self;
}

#pragma mark - DCTTableViewDataSource

- (void)setCellClass:(Class)cellClass {
	_cellClass = cellClass;
	[self setupCellClass:cellClass];
}
- (void)setCellClass:(Class)cellClass forObjectClass:(Class)objectClass {
	[_cellClassDictionary setObject:cellClass forKey:objectClass];
	[self setupCellClass:cellClass];
}
- (Class)cellClassForObjectClass:(Class)objectClass {
	return [_cellClassDictionary objectForKey:objectClass];
}
- (void)setCellClass:(Class)cellClass forObject:(id)object {
	
	NSNumber *hash = [NSNumber numberWithUnsignedInteger:[object hash]];
	
	if (cellClass == NULL) {
		[_cellClassDictionary removeObjectForKey:hash];
		return;
	}
	
	[_cellClassDictionary setObject:cellClass forKey:hash];
	[self setupCellClass:cellClass];
}
- (Class)cellClassForObject:(id)object {
	return [_cellClassDictionary objectForKey:[NSNumber numberWithUnsignedInteger:[object hash]]];
}

- (void)setTableView:(UITableView *)tv {
	
	if (tv == tableView) return;
	
	tableView = tv;
	[_cellClasses enumerateObjectsUsingBlock:^(Class cellClass, BOOL *stop) {
		[self setupCellClass:cellClass];
	}];
}

- (void)reloadData {
	[self beginUpdates];
	[self enumerateIndexPathsUsingBlock:^(NSIndexPath *indexPath, BOOL *stop) {
		
		[self performRowUpdate:DCTTableViewDataSourceUpdateTypeRowReload
					 indexPath:indexPath
					 animation:self.reloadAnimation];
		
	}];
	[self endUpdates];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath;
}

- (Class)cellClassAtIndexPath:(NSIndexPath *)indexPath {
	
	id object = [self objectAtIndexPath:indexPath];
	
	Class cellClass = NULL;
	
	if (self.cellClassHandler != NULL) {
		cellClass = self.cellClassHandler(indexPath, object);
		if (cellClass != NULL) {
			[self setupCellClass:cellClass];
			return cellClass;
		}
	}
	
	cellClass = [self cellClassForObject:object];
	if (cellClass != NULL) return cellClass;
	
	cellClass = [self cellClassForObjectClass:[object class]];
	if (cellClass != NULL) return cellClass;
	
	return self.cellClass;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath withObject:(id)object {}


#pragma mark - Updating the table view

- (void)beginUpdates {
	[self beginUpdates:_updateTypes];
}

- (void)endUpdates {
	[self endUpdates:_updateTypes];
}

- (void)beginUpdates:(DCTTableViewDataSourceUpdateType)updates {
	
	if (self.forceReload) updates = (updates | DCTTableViewDataSourceUpdateTypeReloadAll);
	
	if (self.parent) {
		[self.parent beginUpdates:updates];
		return;
	}
	
	if (DCTTableViewDataSourceUpdateTypeIncludes(updates, DCTTableViewDataSourceUpdateTypeReloadAll))
		_updates = [NSMutableArray new];
	else
		[self.tableView beginUpdates];
}

- (void)endUpdates:(DCTTableViewDataSourceUpdateType)updateTypes {
	
	_updateTypes = DCTTableViewDataSourceUpdateTypeUnknown;
	
	if (self.forceReload) updateTypes = (updateTypes | DCTTableViewDataSourceUpdateTypeReloadAll);
	
	if (self.parent) {
		[self.parent endUpdates:updateTypes];
		return;
	}
	
	if (!DCTTableViewDataSourceUpdateTypeIncludes(updateTypes, DCTTableViewDataSourceUpdateTypeReloadAll)) {
		
		[self.tableView endUpdates];
		
	} else {
		
		NSArray *indexPaths = [self.tableView indexPathsForVisibleRows];
		
		if ([indexPaths count] == 0) {
			[self.tableView reloadData];
		} else {
			
			__block NSIndexPath *indexPath = [indexPaths objectAtIndex:0];
			CGFloat firstVisibleCellYPosition = [self.tableView rectForRowAtIndexPath:indexPath].origin.y;
			
			NSArray *updates = [_updates sortedArrayUsingSelector:@selector(compare:)];
			
			NSLog(@"%@:%@ %@", self, NSStringFromSelector(_cmd), updates);
			
			[updates enumerateObjectsUsingBlock:^(DCTTableViewDataSourceUpdate *update, NSUInteger i, BOOL *stop) {
				
				NSLog(@"%@:%@ %i", self, NSStringFromSelector(_cmd), [update.indexPath compare:indexPath]);
				
				if ([update.indexPath compare:indexPath] == NSOrderedDescending) {
					*stop = YES;
					return;
				}
				
				if (DCTTableViewDataSourceUpdateTypeIncludes(update.type, DCTTableViewDataSourceUpdateTypeRowDelete))
					indexPath = [NSIndexPath indexPathForRow:indexPath.row-1 inSection:indexPath.section];
				
				else if (DCTTableViewDataSourceUpdateTypeIncludes(update.type, DCTTableViewDataSourceUpdateTypeRowInsert))
					indexPath = [NSIndexPath indexPathForRow:indexPath.row+1 inSection:indexPath.section];
				
				else if (DCTTableViewDataSourceUpdateTypeIncludes(update.type, DCTTableViewDataSourceUpdateTypeSectionDelete))
					indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section-1];
				
				else if (DCTTableViewDataSourceUpdateTypeIncludes(update.type, DCTTableViewDataSourceUpdateTypeSectionInsert))
					indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section+1];
			}];
			
			[self.tableView reloadData];
			
			CGFloat newFirstVisibleCellYPosition = [self.tableView rectForRowAtIndexPath:indexPath].origin.y;
			
			CGPoint offset = self.tableView.contentOffset;
			offset.y += (newFirstVisibleCellYPosition - firstVisibleCellYPosition);
			self.tableView.contentOffset = offset;			
			
		}
	}
	
	_updates = nil;
	
	if (self.tableViewUpdateHandler != NULL)
		self.tableViewUpdateHandler(updateTypes);
}

- (void)performSectionUpdate:(DCTTableViewDataSourceUpdateType)update
				sectionIndex:(NSInteger)index
				   animation:(UITableViewRowAnimation)animation {
	[self performRowUpdate:update indexPath:[NSIndexPath indexPathForRow:0 inSection:index] animation:animation];
}

- (void)performRowUpdate:(DCTTableViewDataSourceUpdateType)updateType
			   indexPath:(NSIndexPath *)indexPath
			   animation:(UITableViewRowAnimation)animation {
	
	if (animation == DCTTableViewDataSourceNoAnimationSet)
		animation = self.insertionAnimation;
	
	if (self.forceReload) updateType = (updateType | DCTTableViewDataSourceUpdateTypeReloadAll);
	
	if (self.parent) {
		
		if (DCTTableViewDataSourceUpdateTypeIncludes(updateType, DCTTableViewDataSourceUpdateTypeSectionInsert)
			|| DCTTableViewDataSourceUpdateTypeIncludes(updateType, DCTTableViewDataSourceUpdateTypeSectionDelete)) {
			NSInteger index = [self.parent convertSection:indexPath.section fromChildTableViewDataSource:self];
			[self.parent performSectionUpdate:updateType sectionIndex:index animation:animation];
			return;
		}
		
		indexPath = [self.parent convertIndexPath:indexPath fromChildTableViewDataSource:self];
		[self.parent performRowUpdate:updateType indexPath:indexPath animation:animation];
		return;
	}
	
	[self addToUpdateType:updateType];
	
	if (DCTTableViewDataSourceUpdateTypeIncludes(updateType, DCTTableViewDataSourceUpdateTypeReloadAll)) {
		DCTTableViewDataSourceUpdate *update = [DCTTableViewDataSourceUpdate new];
		update.animation = animation;
		update.type = updateType;
		update.indexPath = indexPath;
		[_updates addObject:update];
		return;
	}
	
	if (animation == DCTTableViewDataSourceNoAnimationSet)
		animation = DCTTableViewDataSourceTableViewRowAnimationAutomatic;
	
	if (DCTTableViewDataSourceUpdateTypeIncludes(updateType, DCTTableViewDataSourceUpdateTypeRowInsert))
		[self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:animation];
	
	else if (DCTTableViewDataSourceUpdateTypeIncludes(updateType, DCTTableViewDataSourceUpdateTypeRowDelete))
		[self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:animation];
	
	else if (DCTTableViewDataSourceUpdateTypeIncludes(updateType, DCTTableViewDataSourceUpdateTypeRowReload))
		[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:animation];
	
	else if (DCTTableViewDataSourceUpdateTypeIncludes(updateType, DCTTableViewDataSourceUpdateTypeSectionInsert))
		[self.tableView insertSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:animation];
	
	else if (DCTTableViewDataSourceUpdateTypeIncludes(updateType, DCTTableViewDataSourceUpdateTypeSectionDelete))
		[self.tableView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:animation];
}

- (void)addToUpdateType:(DCTTableViewDataSourceUpdateType)type {
	
	if (_updateTypes == DCTTableViewDataSourceUpdateTypeUnknown)
		_updateTypes = type;
	
	_updateTypes = (_updateTypes | type);
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

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
	return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSString *cellIdentifier = nil;
	
	Class theCellClass = [self cellClassAtIndexPath:indexPath];
	
	if ([theCellClass isSubclassOfClass:[DCTTableViewCell class]])
		cellIdentifier = [theCellClass reuseIdentifier];
	
    UITableViewCell *cell = [tv dct_dequeueReusableCellWithIdentifier:cellIdentifier];
	
	if (!cell && [theCellClass isSubclassOfClass:[DCTTableViewCell class]])
		cell = [theCellClass cell];
	
	if (!cell)
		cell = [[theCellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    
	id object = [self objectAtIndexPath:indexPath];
	
	[self configureCell:cell atIndexPath:indexPath withObject:object];
	
	if ([cell conformsToProtocol:@protocol(DCTTableViewCellObjectConfiguration)])
		[(id<DCTTableViewCellObjectConfiguration>)cell configureWithObject:object];
	
	if (self.cellConfigurer != NULL) self.cellConfigurer(cell, indexPath, object);
	
	return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return self.sectionFooterTitle;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return self.sectionHeaderTitle;
}

#pragma mark - Internal

- (void)setupCellClass:(Class)cellClass {
	
	[_cellClasses addObject:cellClass];
	
	if (!self.tableView) return;
	
	if ([_setupCellClasses containsObject:cellClass]) return;
	
	[_setupCellClasses addObject:cellClass];
	
	if (![cellClass isSubclassOfClass:[DCTTableViewCell class]]) return;
	
	NSString *nibName = [cellClass nibName];
	
	if ([nibName length] < 1) return;
	
	UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
	NSString *reuseIdentifier = [cellClass reuseIdentifier];
	
	[self.tableView dct_registerNib:nib forCellReuseIdentifier:reuseIdentifier];
}

@end



@implementation DCTTableViewDataSourceUpdate

- (NSComparisonResult)compare:(DCTTableViewDataSourceUpdate *)update {
	
	NSComparisonResult result = [[NSNumber numberWithInteger:self.type] compare:[NSNumber numberWithInteger:update.type]];
	
	if (result != NSOrderedSame) return result;
	
	return [self.indexPath compare:update.indexPath];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; indexPath = %@; type = %i; animation = %i>",
			NSStringFromClass([self class]),
			self,
			self.indexPath,
			self.type,
			self.animation];
}

@end
