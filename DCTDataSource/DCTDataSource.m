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
#import "DCTParentDataSource.h"
#import "DCTDataSourceUpdate.h"

void DCTDataSourceUpdateTypeAdd(DCTDataSourceUpdateType type, DCTDataSourceUpdateType typeToAdd) {
	
	if (type == DCTDataSourceUpdateTypeUnknown)
		type = typeToAdd;
	
	type = (type | typeToAdd);
}

NSInteger const DCTTableViewDataSourceNoAnimationSet = -1912;

@implementation DCTDataSource {
	__strong NSMutableArray *_updates;
}

+ (NSBundle *)bundle {
	static NSBundle *bundle;
	static dispatch_once_t bundleToken;
	dispatch_once(&bundleToken, ^{
		NSDirectoryEnumerator *enumerator = [[NSFileManager new] enumeratorAtURL:[[NSBundle mainBundle] bundleURL]
													  includingPropertiesForKeys:nil
																		 options:NSDirectoryEnumerationSkipsHiddenFiles
																	errorHandler:NULL];

		for (NSURL *URL in enumerator)
			if ([[URL lastPathComponent] isEqualToString:@"DCTDataSource.bundle"])
				bundle = [NSBundle bundleWithURL:URL];
	});

	return bundle;
}

#pragma mark - DCTTableViewDataSource

- (void)reloadData {
	[self beginUpdates];
	[self enumerateIndexPathsUsingBlock:^(NSIndexPath *indexPath, BOOL *stop) {
		[self performRowUpdate:DCTDataSourceUpdateTypeItemReload indexPath:indexPath];
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
	[self.parent beginUpdates];
}

- (void)endUpdates {
	[self.parent endUpdates];
}

- (void)performSectionUpdate:(DCTDataSourceUpdateType)updateType
				sectionIndex:(NSInteger)index {

	index = [self.parent convertSection:index fromChildTableViewDataSource:self];
	[self.parent performSectionUpdate:updateType sectionIndex:index];
}

- (void)performRowUpdate:(DCTDataSourceUpdateType)updateType
			   indexPath:(NSIndexPath *)indexPath {

	indexPath = [self.parent convertIndexPath:indexPath fromChildTableViewDataSource:self];
	[self.parent performRowUpdate:updateType indexPath:indexPath];
}

- (void)enumerateIndexPathsUsingBlock:(void(^)(NSIndexPath *, BOOL *stop))enumerator {

	NSInteger sectionCount = [self numberOfSections];

	for (NSInteger section = 0; section < sectionCount; section++) {

		NSInteger itemCount = [self numberOfItemsInSection:section];

		for (NSInteger item = 0; item < itemCount; item++) {
			NSIndexPath *indexPath = [NSIndexPath indexPathForRow:item inSection:section];
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
