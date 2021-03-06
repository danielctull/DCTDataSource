//
//  DCTOutlineViewDataSource.h
//  DCTDataSource
//
//  Created by Daniel Tull on 17.02.2015.
//  Copyright (c) 2015 Daniel Tull. All rights reserved.
//

@import AppKit;
#import "DCTDataSource.h"


extern const struct DCTOutlineViewDataSourceUserInfoKeys {
	__unsafe_unretained NSString *headerTitle;
	__unsafe_unretained NSString *headerCellIdentifier;
	__unsafe_unretained NSString *objectCellIdentifier;
} DCTOutlineViewDataSourceUserInfoKeys;


@interface DCTOutlineViewDataSource : DCTParentDataSource <NSOutlineViewDataSource>

/**
 *  Creates an outline view data source.
 *
 *  Assigns itself as the dataSource of the outline view.
 *
 *  @param outlineView  The outline view
 *  @param dataSources The root data source to adapt
 *
 *  @return The table view data source.
 */
- (instancetype)initWithOutlineView:(NSOutlineView *)outlineView dataSources:(NSArray *)dataSources;
@property (nonatomic, readonly, weak) NSOutlineView *outlineView;
@property (nonatomic, readonly) NSArray *dataSources;

- (id)viewForTableColumn:(NSTableColumn *)tableColumn item:(id)item;

@end
