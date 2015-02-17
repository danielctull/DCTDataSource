/*
 DCTSplitDataSource.m
 DCTDataSource
 
 Created by Daniel Tull on 16.09.2010.
 
 
 
 Copyright (c) 2010 Daniel Tull. All rights reserved.
 
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

#import "DCTSplitDataSource.h"

@interface DCTSplitDataSource ()
@property (nonatomic, strong) NSMutableArray *internalChildDataSources;
@end

@implementation DCTSplitDataSource

- (id)initWithType:(DCTSplitDataSourceType)type {
	self = [self init];
	if (!self) return nil;
	_type = type;
	_internalChildDataSources = [NSMutableArray new];
	return self;
}

#pragma mark - DCTParentTableViewDataSource

- (NSArray *)childDataSources {
	return [self.internalChildDataSources copy];
}

- (NSIndexPath *)convertIndexPath:(NSIndexPath *)indexPath fromChildDataSource:(DCTDataSource *)dataSource {
	
	NSAssert([self.internalChildDataSources containsObject:dataSource], @"dataSource should be a child table view data source");
	
	NSArray *dataSources = self.childDataSources;
	
	if (self.type == DCTSplitDataSourceTypeRow) {
		
		__block NSInteger row = indexPath.dctDataSource_row;
		
		[dataSources enumerateObjectsUsingBlock:^(DCTDataSource *ds, NSUInteger idx, BOOL *stop) {
						
			if ([ds isEqual:dataSource])
				*stop = YES;
			else
				row += [ds numberOfItemsInSection:0];
			
		}];
		
		indexPath = [NSIndexPath dctDataSource_indexPathForRow:row inSection:0];
		
	} else {
		
		indexPath = [NSIndexPath dctDataSource_indexPathForRow:indexPath.dctDataSource_row inSection:[dataSources indexOfObject:dataSource]];
	}
	
	return indexPath;
}

- (NSInteger)convertSection:(NSInteger)section fromChildDataSource:(DCTDataSource *)dataSource {
	
	NSAssert([self.childDataSources containsObject:dataSource], @"dataSource should be a child table view data source");
	
	if (self.type == DCTSplitDataSourceTypeRow) 
		section = 0;
	else 
		section = [self.childDataSources indexOfObject:dataSource];
	
	return section;
}

- (NSIndexPath *)convertIndexPath:(NSIndexPath *)indexPath toChildDataSource:(DCTDataSource *)dataSource {
	
	NSAssert([self.childDataSources containsObject:dataSource], @"dataSource should be a child table view data source");
	
	if (self.type == DCTSplitDataSourceTypeRow) {
		
		__block NSInteger totalItems = 0;
		NSInteger row = indexPath.dctDataSource_row;
		
		[self.childDataSources enumerateObjectsUsingBlock:^(DCTDataSource *ds, NSUInteger idx, BOOL *stop) {
			
			NSInteger numberOfItems = [ds numberOfItemsInSection:0];
						
			if ((totalItems + numberOfItems) > row)
				*stop = YES;
			else
				totalItems += numberOfItems;
		}];
		
		row = indexPath.dctDataSource_row - totalItems;
		
		return [NSIndexPath dctDataSource_indexPathForRow:row inSection:0];
	}
	
	return [NSIndexPath dctDataSource_indexPathForRow:indexPath.dctDataSource_row inSection:0];
}

- (NSInteger)convertSection:(NSInteger)section toChildDataSource:(DCTDataSource *)dataSource {
	NSAssert([self.childDataSources containsObject:dataSource], @"dataSource should be a child table view data source");
	return 0;
}

- (DCTDataSource *)childDataSourceForSection:(NSInteger)section {
	
	NSArray *dataSources = self.childDataSources;
	
	if (self.type == DCTSplitDataSourceTypeRow) {
		
		if ([dataSources count] == 0) return nil;
		
		return [dataSources objectAtIndex:0];
	}
	
	return [dataSources objectAtIndex:section];
}

- (DCTDataSource *)childDataSourceForIndexPath:(NSIndexPath *)indexPath {
	
	if (self.type == DCTSplitDataSourceTypeRow) {
		
		__block NSInteger totalRows = 0;
		__block DCTDataSource * dataSource = nil;
		NSInteger row = indexPath.dctDataSource_row;
		
		[self.childDataSources enumerateObjectsUsingBlock:^(DCTDataSource *ds, NSUInteger idx, BOOL *stop) {
			
			NSInteger numberOfRows = [ds numberOfItemsInSection:0];
			
			totalRows += numberOfRows;
			
			if (totalRows > row) {
				dataSource = ds;
				*stop = YES;
			}
		}];
		
		return dataSource;
	}

	//if (indexPath.section >= self.childDataSources.count) return nil;

	return [self.childDataSources objectAtIndex:indexPath.dctDataSource_section];
}


#pragma mark - DCTSplitTableViewDataSource methods

- (void)addChildDataSource:(DCTDataSource *)dataSource {

	dataSource.parent = self;

	NSMutableArray *dataSources = self.internalChildDataSources;

	[self beginUpdates];
	
	[dataSources addObject:dataSource];
	
	if (self.type == DCTSplitDataSourceTypeRow) {
		
		[dataSource enumerateIndexPathsUsingBlock:^(NSIndexPath *indexPath, BOOL *stop) {
			DCTDataSourceUpdate *update = [DCTDataSourceUpdate insertUpdateWithNewIndexPath:indexPath];
			[dataSource performUpdate:update];
		}];
		
	} else {
		DCTDataSourceUpdate *update = [DCTDataSourceUpdate insertUpdateWithIndex:[dataSources indexOfObject:dataSource]];
		[self performUpdate:update];
	}
	
	[self endUpdates];
}

- (void)removeChildDataSource:(DCTDataSource *)dataSource {
	
	NSAssert([self.childDataSources containsObject:dataSource], @"dataSource should be a child table view data source");
	
	NSMutableArray *childDataSources = self.internalChildDataSources;
	
	[self beginUpdates];
	
	NSUInteger index = [childDataSources indexOfObject:dataSource];
	
	if (self.type == DCTSplitDataSourceTypeRow) {
		
		[dataSource enumerateIndexPathsUsingBlock:^(NSIndexPath *indexPath, BOOL *stop) {
			DCTDataSourceUpdate *update = [DCTDataSourceUpdate deleteUpdateWithOldIndexPath:indexPath];
			[dataSource performUpdate:update];
		}];
		
	} else {

		DCTDataSourceUpdate *update = [DCTDataSourceUpdate deleteUpdateWithIndex:index];
		[self performUpdate:update];
	}
	
	[childDataSources removeObject:dataSource];
	[self endUpdates];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSections {
	
	if (self.type == DCTSplitDataSourceTypeRow)
		return 1;
	
	return [self.childDataSources count];
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
	
	if (self.type == DCTSplitDataSourceTypeSection)
		return [super numberOfItemsInSection:section];
	
	__block NSInteger numberOfRows = 0;
	
	[self.childDataSources enumerateObjectsUsingBlock:^(DCTDataSource * ds, NSUInteger idx, BOOL *stop) {
		numberOfRows += [ds numberOfItemsInSection:0];
	}];
	
	return numberOfRows;
}

@end
