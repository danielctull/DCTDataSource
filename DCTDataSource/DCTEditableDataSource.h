//
//  DCTEditableDataSource.h
//  DCTDataSource
//
//  Created by Daniel Tull on 01/11/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTDataSource.h"

@protocol DCTEditableDataSource <NSObject>

- (BOOL)canEditObjectAtIndexPath:(NSIndexPath *)indexPath;
- (BOOL)canMoveObjectAtIndexPath:(NSIndexPath *)indexPath;
- (id)generateObject;

- (void)insertObject:(id)object atIndexPath:(NSIndexPath *)indexPath;
- (void)removeObjectAtIndexPath:(NSIndexPath *)indexPath;
- (void)moveObjectAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)indexPath;

@end
