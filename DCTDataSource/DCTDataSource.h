/*
 DCTTableViewDataSource.m
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

#import <UIKit/UIKit.h>

typedef enum {
	DCTDataSourceUpdateTypeUnknown = 0,
	DCTDataSourceUpdateTypeItemDelete = 1 << 0,
	DCTDataSourceUpdateTypeSectionDelete = 1 << 1,
	DCTDataSourceUpdateTypeItemInsert = 1 << 2,
	DCTDataSourceUpdateTypeSectionInsert = 1 << 3,
	DCTDataSourceUpdateTypeItemReload = 1 << 4,
	DCTDataSourceUpdateTypeItemMove = 1 << 5,
} DCTDataSourceUpdateType;

typedef enum {
	DCTTableViewDataSourceReloadTypeDefault = 0,
	DCTTableViewDataSourceReloadTypeBottom,
	DCTTableViewDataSourceReloadTypeTop
} DCTTableViewDataSourceReloadType;

@class DCTParentDataSource;

/** An abstract class to represent a core DCTTableViewDataSource object. Examples of concrete 
 subclasses are DCTObjectTableViewDataSource and DCTFetchedResultsTableViewDataSource.
 
 When subclassing, generally you should write your own implmentation for the objectAtIndexPath:
 and reloadData methods.
 */
@interface DCTDataSource : NSObject <UITableViewDataSource>

+ (NSBundle *)bundle;

/** A parent data source, if one exists.
 
 To enable nesting any data source has the potential to have a
 parent, although this is not always true (for instance the root 
 data source).
 */
@property (nonatomic, weak) DCTParentDataSource *parent;

/** A convinient way to repload the cells of the data source, this 
 should be overridden by subclasses to provide desired results.
 */
- (void)reloadData;

- (NSInteger)numberOfSections;
- (NSInteger)numberOfItemsInSection:(NSInteger)section;

/** To get the associated object from the data source for the given 
 index path. By default this returns the index path, but subclasses
 should return the correct object to use.
 
 If the cellClass conforms to DCTTableViewCellObjectConfiguration,
 it is this object that will be given to the cell when
 configureWithObject: is called.
 
 @param indexPath The index path in the co-ordinate space of the data source.
 
 @return The representing object.
 */
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;


@property (nonatomic, copy) NSString *sectionHeaderTitle;
@property (nonatomic, copy) NSString *sectionFooterTitle;

- (void)beginUpdates;
//- (void)performUpdate:(DCTDataSourceUpdate *)update;
- (void)performSectionUpdate:(DCTDataSourceUpdateType)update sectionIndex:(NSInteger)index;
- (void)performRowUpdate:(DCTDataSourceUpdateType)update indexPath:(NSIndexPath *)indexPath;
- (void)endUpdates;

- (void)enumerateIndexPathsUsingBlock:(void(^)(NSIndexPath *, BOOL *stop))enumerator;

@end

#import "DCTEditableDataSource.h"
