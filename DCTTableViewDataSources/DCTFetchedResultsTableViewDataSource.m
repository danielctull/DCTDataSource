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

#import "DCTFetchedResultsTableViewDataSource.h"
#import "DCTTableViewCell.h"
#import "DCTParentTableViewDataSource.h"
#import "UITableView+DCTTableViewDataSources.h"

@implementation DCTFetchedResultsTableViewDataSource {
	DCTTableViewDataSourceUpdateType updateType;
}

@synthesize managedObjectContext;
@synthesize fetchedResultsController;
@synthesize fetchRequestBlock;
@synthesize fetchRequest;
@synthesize showIndexList;

#pragma mark - DCTTableViewDataSource

- (void)reloadData {

	if (self.fetchRequestBlock != nil)
		self.fetchRequest = self.fetchRequestBlock();
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
	return [self.fetchedResultsController objectAtIndexPath:indexPath];
}

#pragma mark - DCTFetchedResultsTableViewDataSource

- (void)setFetchRequest:(NSFetchRequest *)fr {
	
	if ([fr isEqual:fetchRequest]) return;
	
	fetchedResultsController = nil;
	
	fetchRequest = fr;
	
	if (self.managedObjectContext) [self fetchedResultsController]; // Causes the DCT to load
}

- (NSFetchRequest *)fetchRequest {
	
	if (fetchRequest == nil) [self loadFetchRequest];
	
	return fetchRequest;
}

- (void)loadFetchRequest {

	if (self.fetchRequestBlock != nil)
		self.fetchRequest = self.fetchRequestBlock();
}

- (void)setFetchedResultsController:(NSFetchedResultsController *)dct {
	
	if ([fetchedResultsController isEqual:dct]) return;
	
	if (dct && (self.managedObjectContext == nil || self.managedObjectContext != dct.managedObjectContext))
		self.managedObjectContext = dct.managedObjectContext;
	
	fetchedResultsController.delegate = nil;
	fetchedResultsController = dct;
	
	fetchedResultsController.delegate = self;
	[fetchedResultsController performFetch:nil];
	
	[self.tableView reloadData];
}

- (NSFetchedResultsController *)fetchedResultsController {
	
	if (fetchedResultsController == nil) [self loadFetchedResultsController];
	
	return fetchedResultsController;
}

- (void)loadFetchedResultsController {
	
	if (!self.fetchRequest) return;
	if (!self.managedObjectContext) return;
	
	self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:self.fetchRequest
																		managedObjectContext:self.managedObjectContext
																		  sectionNameKeyPath:nil
																				   cacheName:nil];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section {
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	NSInteger amount = [self tableView:tableView numberOfRowsInSection:indexPath.section];
    if (indexPath.row >= amount) {
        NSLog(@"%@:%@ RELOADING TABLE VIEW NAH NAH NAH", self, NSStringFromSelector(_cmd));
        [tableView reloadData];
        return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"blah"];
    }
	
	return [super tableView:tableView cellForRowAtIndexPath:indexPath];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section { 
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
	NSString *sectionName = [sectionInfo name];
	if ([sectionName length] == 0)
		sectionName = [super tableView:tableView titleForHeaderInSection:section];
	return sectionName;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
	
	if (!showIndexList) return nil;
	
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
			[self performSectionUpdate:DCTTableViewDataSourceUpdateTypeSectionInsert
						  sectionIndex:sectionIndex
							 animation:self.insertionAnimation];
            break;
			
        case NSFetchedResultsChangeDelete:
			[self performSectionUpdate:DCTTableViewDataSourceUpdateTypeSectionDelete
						  sectionIndex:sectionIndex
							 animation:self.deletionAnimation];
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
			[self performRowUpdate:DCTTableViewDataSourceUpdateTypeRowInsert
						 indexPath:newIndexPath
						 animation:self.insertionAnimation];
			break;
			
		case NSFetchedResultsChangeDelete:
			[self performRowUpdate:DCTTableViewDataSourceUpdateTypeRowDelete
						 indexPath:indexPath
						 animation:self.deletionAnimation];
			break;
			
        case NSFetchedResultsChangeUpdate:
			[self performRowUpdate:DCTTableViewDataSourceUpdateTypeRowReload
						 indexPath:indexPath
						 animation:self.reloadAnimation];
			break;
			
        case NSFetchedResultsChangeMove:
			[self performRowUpdate:DCTTableViewDataSourceUpdateTypeRowDelete
						 indexPath:indexPath
						 animation:self.deletionAnimation];
			[self performRowUpdate:DCTTableViewDataSourceUpdateTypeRowInsert
						 indexPath:newIndexPath
						 animation:self.insertionAnimation];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
	[self endUpdates];
}



@end
