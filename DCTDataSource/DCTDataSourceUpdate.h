//
//  _DCTTableViewDataSourceUpdate.h
//  DCTTableViewDataSources
//
//  Created by Daniel Tull on 08.10.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
	DCTDataSourceUpdateTypeUnknown = 0,
	DCTDataSourceUpdateTypeItemDelete = 1 << 0,
	DCTDataSourceUpdateTypeSectionDelete = 1 << 1,
	DCTDataSourceUpdateTypeItemInsert = 1 << 2,
	DCTDataSourceUpdateTypeSectionInsert = 1 << 3,
	DCTDataSourceUpdateTypeItemReload = 1 << 4,
	DCTDataSourceUpdateTypeItemMove = 1 << 5,
} DCTDataSourceUpdateType;

@interface DCTDataSourceUpdate : NSObject

+ (instancetype)updateWithType:(DCTDataSourceUpdateType)type indexPath:(NSIndexPath *)indexPath;
+ (instancetype)updateWithType:(DCTDataSourceUpdateType)type index:(NSInteger)index;

@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, assign) DCTDataSourceUpdateType type;

- (BOOL)isSectionUpdate;
- (NSInteger)section;
@end
