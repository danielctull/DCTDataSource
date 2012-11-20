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
#import "DCTTableViewDataSource.h"
#import "DCTParentTableViewDataSource.h"

#import "DCTArrayTableViewDataSource.h"
#import "DCTArrayObservingTableViewDataSource.h"
#import "DCTCollapsableSectionTableViewDataSource.h"
#import "DCTFetchedResultsTableViewDataSource.h"
#import "DCTHorizontalTableViewDataSource.h"
#import "DCTInterspersedTableViewDataSource.h"
#import "DCTObjectTableViewDataSource.h"
#import "DCTSplitTableViewDataSource.h"

#import "UITableView+DCTCellRegistration.h"

@interface DCTTableViewDataSources : NSObject
+ (NSBundle *)bundle;
@end
