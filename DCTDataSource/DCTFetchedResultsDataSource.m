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
@property (nonatomic, strong) NSMutableArray *deletedSectionIndexes;
@property (nonatomic, strong) NSMutableArray *insertedSectionIndexes;
@property (nonatomic, strong) NSMutableArray *deletedRowIndexPaths;
@property (nonatomic, strong) NSMutableArray *insertedRowIndexPaths;
@property (nonatomic, strong) NSMutableArray *updatedRowIndexPaths;
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

			[self.insertedRowIndexPaths addObject:newIndexPath];
			break;

		case NSFetchedResultsChangeDelete:

			// If we've already been told that we're deleting a section for this deleted row we skip it since it will handled by the section deletion.
			if ([self.deletedSectionIndexes containsObject:@(oldIndexPath.section)])
				return;

			[self.deletedRowIndexPaths addObject:oldIndexPath];
			break;

        case NSFetchedResultsChangeUpdate:
			[self.updatedRowIndexPaths addObject:oldIndexPath];
			break;

        case NSFetchedResultsChangeMove:

			if (![self.deletedSectionIndexes containsObject:@(oldIndexPath.section)])
				[self.deletedRowIndexPaths addObject:oldIndexPath];

			if (![self.insertedSectionIndexes containsObject:@(newIndexPath.section)])
				[self.insertedRowIndexPaths addObject:newIndexPath];

            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {

    [self beginUpdates];

	for (NSNumber *index in self.deletedSectionIndexes)
		[self performUpdate:[DCTDataSourceUpdate deleteUpdateWithIndex:[index integerValue]]];

	for (NSNumber *index in self.insertedSectionIndexes)
		[self performUpdate:[DCTDataSourceUpdate insertUpdateWithIndex:[index integerValue]]];

	for (NSIndexPath *indexPath in self.deletedRowIndexPaths)
		[self performUpdate:[DCTDataSourceUpdate deleteUpdateWithOldIndexPath:indexPath]];

	for (NSIndexPath *indexPath in self.insertedRowIndexPaths)
		[self performUpdate:[DCTDataSourceUpdate insertUpdateWithNewIndexPath:indexPath]];

	for (NSIndexPath *indexPath in self.updatedRowIndexPaths)
		[self performUpdate:[DCTDataSourceUpdate reloadUpdateWithIndexPath:indexPath]];

	[self endUpdates];

    self.insertedSectionIndexes = nil;
    self.deletedSectionIndexes = nil;
    self.deletedRowIndexPaths = nil;
    self.insertedRowIndexPaths = nil;
    self.updatedRowIndexPaths = nil;
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

- (NSMutableArray *)deletedRowIndexPaths {

    if (!_deletedRowIndexPaths)
        _deletedRowIndexPaths = [NSMutableArray new];

    return _deletedRowIndexPaths;
}

- (NSMutableArray *)insertedRowIndexPaths {

    if (!_insertedRowIndexPaths)
        _insertedRowIndexPaths = [NSMutableArray new];

    return _insertedRowIndexPaths;
}

- (NSMutableArray *)updatedRowIndexPaths {

    if (!_updatedRowIndexPaths)
        _updatedRowIndexPaths = [NSMutableArray new];
	
    return _updatedRowIndexPaths;
}

@end
