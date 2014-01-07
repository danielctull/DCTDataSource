/*
 DCTFetchedResultsDataSource.h
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

#import "DCTDataSource.h"
@import CoreData;

/** A data source that stays in sync with a Core Data fetch request using a
 NSFetchedResultsController.
 
 You can set this up in a number of ways:
 
 - Provide a fetchedResultsController
 - Provide a managedObjectContext and a fetchRequest
 - Provide a managedObjectContext and a fetchRequestBlock
 - Implement loadFetchedResultsController in a subclass
 - Provide a managedObjectContext and implement loadFetchRequest in a subclass
 
 There may be other combinations that work also. Note however that without 
 a managed object context and some form of fetch request, this will crash.
 */
@interface DCTFetchedResultsDataSource : DCTDataSource

- (id)initWithFetchedResultsController:(NSFetchedResultsController *)fetchedResultsController;

/** The fetched results controller that is controlling the data for cells 
 maintained by this data source.
 */
@property (nonatomic, readonly, strong) NSFetchedResultsController *fetchedResultsController;

@property (nonatomic, assign) BOOL showIndexList;

@end
