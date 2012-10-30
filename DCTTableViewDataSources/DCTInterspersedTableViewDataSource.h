//
//  DCTInterspersedTableViewDataSource.h
//  Tweetville
//
//  Created by Daniel Tull on 23.05.2012.
//  Copyright (c) 2012 Daniel Tull Limited. All rights reserved.
//

#import "DCTParentDataSource.h"

@interface DCTInterspersedTableViewDataSource : DCTParentDataSource
/** The child data source to intersperse.
 */
@property (nonatomic, strong) DCTDataSource *childTableViewDataSource;
@property (nonatomic, copy) NSString *interspersedCellReuseIdentifier;

@end
