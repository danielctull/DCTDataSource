//
//  DCTTestDataSource.h
//  DCTDataSource
//
//  Created by Daniel Tull on 02/02/2014.
//  Copyright (c) 2014 Daniel Tull. All rights reserved.
//

#import <DCTDataSource/DCTDataSource.h>

@interface DCTTestDataSource : DCTParentDataSource

- (instancetype)initWithDataSource:(DCTDataSource *)dataSource;
@property (nonatomic, readonly) DCTDataSource *dataSource;
@property (nonatomic, readonly) NSArray *updates;

- (void)clearUpdates;

@end
