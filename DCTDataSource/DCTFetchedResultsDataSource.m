/*
 DCTFetchedResultsTableViewDataSource.m
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

#import "DCTFetchedResultsDataSource.h"

@interface DCTFetchedResultsDataSource () <NSFetchedResultsControllerDelegate>
@end

@implementation DCTFetchedResultsDataSource

#pragma mark - DCTTableViewDataSource

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
	return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

#pragma mark - DCTFetchedResultsTableViewDataSource

- (id)initWithFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController {
	self = [super init];
	if (!self) return nil;
	_fetchedResultsController = fetchedResultsController;
	_fetchedResultsController.delegate = self;
	[_fetchedResultsController performFetch:nil];
	return self;
}

#pragma mark - DCTDataSource

- (NSInteger)numberOfSections {
	return [[self.fetchedResultsController sections] count];
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	NSString *sectionName = [sectionInfo name];
	if ([sectionName length] == 0)
		sectionName = [super tableView:tableView titleForHeaderInSection:section];
	return sectionName;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	
	if (!_showIndexList) return nil;
	
	return [self.fetchedResultsController sectionIndexTitles];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index {
	return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller 
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex
	 forChangeType:(NSFetchedResultsChangeType)type {
	
    switch(type) {
        case NSFetchedResultsChangeInsert:
			[self performUpdate:[DCTDataSourceUpdate updateWithType:DCTDataSourceUpdateTypeSectionInsert index:sectionIndex]];
            break;
			
        case NSFetchedResultsChangeDelete:
			[self performUpdate:[DCTDataSourceUpdate updateWithType:DCTDataSourceUpdateTypeSectionDelete index:sectionIndex]];
            break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller 
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath {
	
    switch(type) {
			
		case NSFetchedResultsChangeInsert:
			[self performUpdate:[DCTDataSourceUpdate updateWithType:DCTDataSourceUpdateTypeItemInsert indexPath:newIndexPath]];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self performUpdate:[DCTDataSourceUpdate updateWithType:DCTDataSourceUpdateTypeItemDelete indexPath:indexPath]];
			break;
			
        case NSFetchedResultsChangeUpdate:
			[self performUpdate:[DCTDataSourceUpdate updateWithType:DCTDataSourceUpdateTypeItemReload indexPath:indexPath]];
			break;
			
        case NSFetchedResultsChangeMove:
			[self performUpdate:[DCTDataSourceUpdate updateWithType:DCTDataSourceUpdateTypeItemDelete indexPath:indexPath]];
			[self performUpdate:[DCTDataSourceUpdate updateWithType:DCTDataSourceUpdateTypeItemInsert indexPath:newIndexPath]];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self endUpdates];
}

@end
