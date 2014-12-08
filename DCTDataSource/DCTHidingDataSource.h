//
//  DCTHidingDataSource.h
//  DCTDataSource
//
//  Created by Daniel Tull on 08.12.2014.
//  Copyright (c) 2014 Daniel Tull. All rights reserved.
//

#import "DCTDataSource.h"

@interface DCTHidingDataSource : DCTParentDataSource

- (instancetype)initWithChildDataSource:(DCTDataSource *)childDataSource;

/** The child data source.
 */
@property (nonatomic, readonly) DCTDataSource *childDataSource;

@end
