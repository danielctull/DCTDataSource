/*
 FRCSplitTableViewDataSource.m
 FRCTableViewDataSources
 
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

#import "FRCSplitTableViewDataSource.h"
#import "UITableView+FRCTableViewDataSources.h"

@interface FRCSplitTableViewDataSource ()
- (NSMutableArray *)frcInternal_tableViewDataSources;
- (void)frcInternal_setupDataSource:(FRCTableViewDataSource *)dataSource;
@end

@implementation FRCSplitTableViewDataSource {
	__strong NSMutableArray *frcInternal_tableViewDataSources;
}

@synthesize type;

#pragma mark - FRCParentTableViewDataSource

- (NSArray *)childTableViewDataSources {
	return [[self frcInternal_tableViewDataSources] copy];
}

- (NSIndexPath *)convertIndexPath:(NSIndexPath *)indexPath fromChildTableViewDataSource:(FRCTableViewDataSource *)dataSource {
	
	NSAssert([frcInternal_tableViewDataSources containsObject:dataSource], @"dataSource should be a child table view data source");
	
	NSArray *dataSources = [self frcInternal_tableViewDataSources];
	
	if (self.type == FRCSplitTableViewDataSourceTypeRow) {
		
		__block NSInteger row = indexPath.row;
		
		[dataSources enumerateObjectsUsingBlock:^(FRCTableViewDataSource *ds, NSUInteger idx, BOOL *stop) {
						
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

- (NSInteger)convertSection:(NSInteger)section fromChildTableViewDataSource:(FRCTableViewDataSource *)dataSource {
	
	NSAssert([frcInternal_tableViewDataSources containsObject:dataSource], @"dataSource should be a child table view data source");
	
	if (self.type == FRCSplitTableViewDataSourceTypeRow) 
		section = 0;
	else 
		section = [[self frcInternal_tableViewDataSources] indexOfObject:dataSource];
	
	return section;
}

- (NSIndexPath *)convertIndexPath:(NSIndexPath *)indexPath toChildTableViewDataSource:(FRCTableViewDataSource *)dataSource {
	
	NSAssert([frcInternal_tableViewDataSources containsObject:dataSource], @"dataSource should be a child table view data source");
	
	if (self.type == FRCSplitTableViewDataSourceTypeRow) {
		
		__block NSInteger totalRows = 0;
		NSInteger row = indexPath.row;
		
		[[self frcInternal_tableViewDataSources] enumerateObjectsUsingBlock:^(FRCTableViewDataSource *ds, NSUInteger idx, BOOL *stop) {
			
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

- (NSInteger)convertSection:(NSInteger)section toChildTableViewDataSource:(FRCTableViewDataSource *)dataSource {
	NSAssert([frcInternal_tableViewDataSources containsObject:dataSource], @"dataSource should be a child table view data source");
	return 0;
}

- (FRCTableViewDataSource *)childTableViewDataSourceForSection:(NSInteger)section {
	
	NSArray *dataSources = [self frcInternal_tableViewDataSources];
	
	if (self.type == FRCSplitTableViewDataSourceTypeRow) {
		
		if ([dataSources count] == 0) return nil;
		
		return [dataSources objectAtIndex:0];
	}
	
	return [dataSources objectAtIndex:section];
}

- (FRCTableViewDataSource *)childTableViewDataSourceForIndexPath:(NSIndexPath *)indexPath {
	
	if (self.type == FRCSplitTableViewDataSourceTypeRow) {
		
		__block NSInteger totalRows = 0;
		__block FRCTableViewDataSource * dataSource = nil;
		NSInteger row = indexPath.row;
		
		[[self frcInternal_tableViewDataSources] enumerateObjectsUsingBlock:^(FRCTableViewDataSource *ds, NSUInteger idx, BOOL *stop) {
			
			NSInteger numberOfRows = [ds tableView:self.tableView numberOfRowsInSection:0];
			
			totalRows += numberOfRows;
			
			if (totalRows > row) {
				dataSource = ds;
				*stop = YES;
			}
		}];
		
		return dataSource;
	}
	
	return [[self frcInternal_tableViewDataSources] objectAtIndex:indexPath.section];
}


#pragma mark - FRCSplitTableViewDataSource methods

- (void)addChildTableViewDataSource:(FRCTableViewDataSource *)tableViewDataSource {
	
	NSMutableArray *childDataSources = [self frcInternal_tableViewDataSources];
		
	[self frcInternal_setupDataSource:tableViewDataSource];
		
	[self beginUpdates];
	
	[childDataSources addObject:tableViewDataSource];
	
	if (self.type == FRCSplitTableViewDataSourceTypeRow) {
		
		[tableViewDataSource enumerateIndexPathsUsingBlock:^(NSIndexPath *indexPath, BOOL *stop) {
			[self performRowUpdate:FRCTableViewDataSourceUpdateTypeRowInsert
						 indexPath:indexPath
						 animation:self.insertionAnimation];
		}];
		
	} else {
		
		[self performSectionUpdate:FRCTableViewDataSourceUpdateTypeSectionInsert
					  sectionIndex:[childDataSources indexOfObject:tableViewDataSource]
						 animation:self.insertionAnimation];
	}
	
	[self endUpdates];
}

- (void)removeChildTableViewDataSource:(FRCTableViewDataSource *)tableViewDataSource {
	
	NSAssert([frcInternal_tableViewDataSources containsObject:tableViewDataSource], @"dataSource should be a child table view data source");
	
	NSMutableArray *childDataSources = [self frcInternal_tableViewDataSources];
	
	[self beginUpdates];
	
	NSUInteger index = [childDataSources indexOfObject:tableViewDataSource];
	[childDataSources removeObject:tableViewDataSource];
	
	if (self.type == FRCSplitTableViewDataSourceTypeRow) {
		
		[tableViewDataSource enumerateIndexPathsUsingBlock:^(NSIndexPath *indexPath, BOOL *stop) {
			[self performRowUpdate:FRCTableViewDataSourceUpdateTypeRowDelete
						 indexPath:indexPath
						 animation:self.deletionAnimation];
		}];
		
	} else {
		
		[self performSectionUpdate:FRCTableViewDataSourceUpdateTypeSectionDelete
					  sectionIndex:index
						 animation:self.deletionAnimation];
	}
	
	[self endUpdates];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tv {
	self.tableView = tv;
	return [[self frcInternal_tableViewDataSources] count];
}

- (NSInteger)tableView:(UITableView *)tv numberOfRowsInSection:(NSInteger)section {
	if (self.type == FRCSplitTableViewDataSourceTypeSection)
		return [super tableView:tv numberOfRowsInSection:section];
	
	
	__block NSInteger numberOfRows = 0;
	
	[[self frcInternal_tableViewDataSources] enumerateObjectsUsingBlock:^(FRCTableViewDataSource * ds, NSUInteger idx, BOOL *stop) {
		numberOfRows += [ds tableView:self.tableView numberOfRowsInSection:0];
	}];
	
	return numberOfRows;
}

#pragma mark - Private methods

- (NSMutableArray *)frcInternal_tableViewDataSources {
	
	if (!frcInternal_tableViewDataSources) 
		frcInternal_tableViewDataSources = [[NSMutableArray alloc] init];
	
	return frcInternal_tableViewDataSources;	
}
		 
- (void)frcInternal_setupDataSource:(FRCTableViewDataSource *)dataSource {
	dataSource.tableView = self.tableView;
	dataSource.parent = self;
}

@end
