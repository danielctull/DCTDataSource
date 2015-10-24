/*
 DCTFetchedResultsDataSource.m
 DCTDataSource

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
#import "DCTTableViewDataSource.h"

@interface DCTFetchedResultsDataSource () <NSFetchedResultsControllerDelegate>
@property (nonatomic) NSMutableArray *deletedSectionIndexes;
@property (nonatomic) NSMutableArray *insertedSectionIndexes;
@property (nonatomic) NSMutableArray *rowUpdates;
@end

@implementation DCTFetchedResultsDataSource

#pragma mark - DCTTableViewDataSource

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
	return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

- (NSIndexPath *)indexPathOfObject:(id)object {
	return [self.fetchedResultsController indexPathForObject:object];
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

- (id)userInfoValueForKey:(NSString *)key indexPath:(NSIndexPath *)indexPath {

	if ([key isEqualToString:DCTTableViewDataSourceUserInfoKeys.sectionHeaderTitle]) {
		id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:indexPath.section];
		NSString *sectionName = [sectionInfo name];
		if ([sectionName length] > 0) return sectionName;
	}

	return [super userInfoValueForKey:key indexPath:indexPath];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex
	 forChangeType:(NSFetchedResultsChangeType)type {

    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.insertedSectionIndexes addObject:@(sectionIndex)];
            break;

        case NSFetchedResultsChangeDelete:
            [self.deletedSectionIndexes addObject:@(sectionIndex)];
            break;

		case NSFetchedResultsChangeMove:
		case NSFetchedResultsChangeUpdate:
			break;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)oldIndexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath {

    switch(type) {

		case NSFetchedResultsChangeInsert:

			if ([self.insertedSectionIndexes containsObject:@(newIndexPath.section)]) {
				// If we've already been told that we're adding a section for this inserted row we skip it since it will handled by the section insertion.
				return;
			}

			[self.rowUpdates addObject:[DCTDataSourceUpdate insertUpdateWithNewIndexPath:newIndexPath]];
			break;

		case NSFetchedResultsChangeDelete:

			// If we've already been told that we're deleting a section for this deleted row we skip it since it will handled by the section deletion.
			if ([self.deletedSectionIndexes containsObject:@(oldIndexPath.section)])
				return;

			[self.rowUpdates addObject:[DCTDataSourceUpdate deleteUpdateWithOldIndexPath:oldIndexPath]];
			break;

        case NSFetchedResultsChangeUpdate:
			[self.rowUpdates addObject:[DCTDataSourceUpdate reloadUpdateWithIndexPath:oldIndexPath]];
			break;

        case NSFetchedResultsChangeMove:

			// If the old section has been deleted, treat as an insert into the new section
			if ([self.deletedSectionIndexes containsObject:@(oldIndexPath.section)]) {

				if ([self.insertedSectionIndexes containsObject:@(newIndexPath.section)]) {
					[self.rowUpdates addObject:[DCTDataSourceUpdate insertUpdateWithNewIndexPath:newIndexPath]];
				}

			// If the new section has been inserted, treat as a delete from the old section
			} else if ([self.insertedSectionIndexes containsObject:@(newIndexPath.section)]) {

				if (![self.deletedSectionIndexes containsObject:@(oldIndexPath.section)]) {
					[self.rowUpdates addObject:[DCTDataSourceUpdate deleteUpdateWithOldIndexPath:oldIndexPath]];
				}

			// If the index paths are the same, treat it as a reload
			} else if ([oldIndexPath isEqual:newIndexPath]) {

				[self.rowUpdates addObject:[DCTDataSourceUpdate reloadUpdateWithIndexPath:oldIndexPath]];

			} else {

				[self.rowUpdates addObject:[DCTDataSourceUpdate moveUpdateWithOldIndexPath:oldIndexPath newIndexPath:newIndexPath]];
			}

            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {

    [self beginUpdates];

	for (NSNumber *index in self.deletedSectionIndexes)
		[self performUpdate:[DCTDataSourceUpdate deleteUpdateWithIndex:[index integerValue]]];

	for (NSNumber *index in self.insertedSectionIndexes)
		[self performUpdate:[DCTDataSourceUpdate insertUpdateWithIndex:[index integerValue]]];

	for (DCTDataSourceUpdate *update in self.rowUpdates)
		[self performUpdate:update];

	[self endUpdates];

    self.insertedSectionIndexes = nil;
    self.deletedSectionIndexes = nil;
    self.rowUpdates = nil;
}

#pragma mark -

- (NSMutableArray *)deletedSectionIndexes {

    if (!_deletedSectionIndexes)
        _deletedSectionIndexes = [NSMutableArray new];

    return _deletedSectionIndexes;
}

- (NSMutableArray *)insertedSectionIndexes {

    if (!_insertedSectionIndexes)
        _insertedSectionIndexes = [NSMutableArray new];

    return _insertedSectionIndexes;
}

- (NSMutableArray *)rowUpdates {

    if (!_rowUpdates)
        _rowUpdates = [NSMutableArray new];

    return _rowUpdates;
}

@end
