/*
 DCTSplitTableViewDataSource.m
 DCTTableViewDataSources
 
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
#import "UITableView+DCTTableViewDataSources.h"

@interface DCTSplitDataSource ()
- (NSMutableArray *)dctInternal_tableViewDataSources;
- (void)dctInternal_setupDataSource:(DCTDataSource *)dataSource;
@end

@implementation DCTSplitDataSource {
	__strong NSMutableArray *dctInternal_tableViewDataSources;
}

#pragma mark - DCTParentTableViewDataSource

- (NSArray *)childTableViewDataSources {
	return [[self dctInternal_tableViewDataSources] copy];
}

- (NSIndexPath *)convertIndexPath:(NSIndexPath *)indexPath fromChildTableViewDataSource:(DCTDataSource *)dataSource {
	
	NSAssert([dctInternal_tableViewDataSources containsObject:dataSource], @"dataSource should be a child table view data source");
	
	NSArray *dataSources = [self dctInternal_tableViewDataSources];
	
	if (self.type == DCTSplitTableViewDataSourceTypeRow) {
		
		__block NSInteger row = indexPath.row;
		
		[dataSources enumerateObjectsUsingBlock:^(DCTDataSource *ds, NSUInteger idx, BOOL *stop) {
						
			if ([ds isEqual:dataSource])
				*stop = YES;
			else
				row += [ds tableView:self.tableView numberOfRowsInSection:0];
			
		}];
		
		indexPath = [NSIndexPath indexPathForRow:row inSection:0];
		
	} else {
		
		indexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:[dataSources indexOfObject:dataSource]];
	}
	
	return indexPath;
}

- (NSInteger)convertSection:(NSInteger)section fromChildTableViewDataSource:(DCTDataSource *)dataSource {
	
	NSAssert([dctInternal_tableViewDataSources containsObject:dataSource], @"dataSource should be a child table view data source");
	
	if (self.type == DCTSplitTableViewDataSourceTypeRow) 
		section = 0;
	else 
		section = [[self dctInternal_tableViewDataSources] indexOfObject:dataSource];
	
	return section;
}

- (NSIndexPath *)convertIndexPath:(NSIndexPath *)indexPath toChildTableViewDataSource:(DCTDataSource *)dataSource {
	
	NSAssert([dctInternal_tableViewDataSources containsObject:dataSource], @"dataSource should be a child table view data source");
	
	if (self.type == DCTSplitTableViewDataSourceTypeRow) {
		
		__block NSInteger totalRows = 0;
		NSInteger row = indexPath.row;
		
		[[self dctInternal_tableViewDataSources] enumerateObjectsUsingBlock:^(DCTDataSource *ds, NSUInteger idx, BOOL *stop) {
			
			NSInteger numberOfRows = [ds tableView:self.tableView numberOfRowsInSection:0];
						
			if ((totalRows + numberOfRows) > row)
				*stop = YES;
			else
				totalRows += numberOfRows;
		}];
		
		row = indexPath.row - totalRows;
		
		return [NSIndexPath indexPathForRow:row inSection:0];
	}
	
	return [NSIndexPath indexPathForRow:indexPath.row inSection:0];
}

- (NSInteger)convertSection:(NSInteger)section toChildTableViewDataSource:(DCTDataSource *)dataSource {
	NSAssert([dctInternal_tableViewDataSources containsObject:dataSource], @"dataSource should be a child table view data source");
	return 0;
}

- (DCTDataSource *)childTableViewDataSourceForSection:(NSInteger)section {
	
	NSArray *dataSources = [self dctInternal_tableViewDataSources];
	
	if (self.type == DCTSplitTableViewDataSourceTypeRow) {
		
		if ([dataSources count] == 0) return nil;
		
		return [dataSources objectAtIndex:0];
	}
	
	return [dataSources objectAtIndex:section];
}

- (DCTDataSource *)childTableViewDataSourceForIndexPath:(NSIndexPath *)indexPath {
	
	if (self.type == DCTSplitTableViewDataSourceTypeRow) {
		
		__block NSInteger totalRows = 0;
		__block DCTDataSource * dataSource = nil;
		NSInteger row = indexPath.row;
		
		[[self dctInternal_tableViewDataSources] enumerateObjectsUsingBlock:^(DCTDataSource *ds, NSUInteger idx, BOOL *stop) {
			
			NSInteger numberOfRows = [ds tableView:self.tableView numberOfRowsInSection:0];
			
			totalRows += numberOfRows;
			
			if (totalRows > row) {
				dataSource = ds;
				*stop = YES;
			}
		}];
		
		return dataSource;
	}
	
	return [[self dctInternal_tableViewDataSources] objectAtIndex:indexPath.section];
}


#pragma mark - DCTSplitTableViewDataSource methods

- (void)addChildTableViewDataSource:(DCTDataSource *)tableViewDataSource {
	
	NSMutableArray *childDataSources = [self dctInternal_tableViewDataSources];
		
	[self dctInternal_setupDataSource:tableViewDataSource];
		
	[self beginUpdates];
	
	[childDataSources addObject:tableViewDataSource];
	
	if (self.type == DCTSplitTableViewDataSourceTypeRow) {
		
		[tableViewDataSource enumerateIndexPathsUsingBlock:^(NSIndexPath *indexPath, BOOL *stop) {
			[tableViewDataSource performRowUpdate:DCTDataSourceUpdateTypeItemInsert
										indexPath:indexPath
										animation:self.insertionAnimation];
		}];
		
	} else {
		
		[self performSectionUpdate:DCTDataSourceUpdateTypeSectionInsert
					  sectionIndex:[childDataSources indexOfObject:tableViewDataSource]
						 animation:self.insertionAnimation];
	}
	
	[self endUpdates];
}

- (void)removeChildTableViewDataSource:(DCTDataSource *)tableViewDataSource {
	
	NSAssert([dctInternal_tableViewDataSources containsObject:tableViewDataSource], @"dataSource should be a child table view data source");
	
	NSMutableArray *childDataSources = [self dctInternal_tableViewDataSources];
	
	[self beginUpdates];
	
	NSUInteger index = [childDataSources indexOfObject:tableViewDataSource];
	[childDataSources removeObject:tableViewDataSource];
	
	if (self.type == DCTSplitTableViewDataSourceTypeRow) {
		
		[tableViewDataSource enumerateIndexPathsUsingBlock:^(NSIndexPath *indexPath, BOOL *stop) {
			[tableViewDataSource performRowUpdate:DCTDataSourceUpdateTypeItemDelete
										indexPath:indexPath
										animation:self.deletionAnimation];
		}];
		
	} else {
		
		[self performSectionUpdate:DCTDataSourceUpdateTypeSectionDelete
					  sectionIndex:index
						 animation:self.deletionAnimation];
	}
	
	[self endUpdates];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
	
	if (self.type == DCTSplitTableViewDataSourceTypeRow)
		return 1;
		
	self.tableView = tv;
	return [[self dctInternal_tableViewDataSources] count];
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
	if (self.type == DCTSplitTableViewDataSourceTypeSection)
		return [super tableView:tv numberOfRowsInSection:section];
	
	
	__block NSInteger numberOfRows = 0;
	
	[[self dctInternal_tableViewDataSources] enumerateObjectsUsingBlock:^(DCTDataSource * ds, NSUInteger idx, BOOL *stop) {
		numberOfRows += [ds tableView:self.tableView numberOfRowsInSection:0];
	}];
	
	return numberOfRows;
}

#pragma mark - Private methods

- (NSMutableArray *)dctInternal_tableViewDataSources {
	
	if (!dctInternal_tableViewDataSources) 
		dctInternal_tableViewDataSources = [[NSMutableArray alloc] init];
	
	return dctInternal_tableViewDataSources;	
}
		 
- (void)dctInternal_setupDataSource:(DCTDataSource *)dataSource {
	dataSource.tableView = self.tableView;
	dataSource.parent = self;
}

@end
