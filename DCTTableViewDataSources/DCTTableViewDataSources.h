//
//  DCTTableViewDataSources.h
//  DCTTableViewDataSources
//
//  Created by Daniel Tull on 09.11.2011.
//  Copyright (c) 2011 Daniel Tull. All rights reserved.
//

#ifndef dcttableviewdatasources
#define dcttableviewdatasources_1_0     10000
#define dcttableviewdatasources_1_0_1   10001
#define dcttableviewdatasources_1_0_2   10002
#define dcttableviewdatasources         dcttableviewdatasources_1_0_2
#endif

#import "DCTTableViewCell.h"
#import "DCTDataSource.h"
#import "DCTParentDataSource.h"

#import "DCTArrayTableViewDataSource.h"
#import "DCTArrayObservingTableViewDataSource.h"
#import "DCTCollapsableSectionTableViewDataSource.h"
#import "DCTFetchedResultsTableViewDataSource.h"
#import "DCTHorizontalTableViewDataSource.h"
#import "DCTInterspersedTableViewDataSource.h"
#import "DCTObjectDataSource.h"
#import "DCTSplitTableViewDataSource.h"


@interface DCTTableViewDataSources : NSObject
+ (NSBundle *)bundle;
@end
