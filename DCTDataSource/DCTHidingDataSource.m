//
//  DCTHidingDataSource.m
//  DCTDataSource
//
//  Created by Daniel Tull on 08.12.2014.
//  Copyright (c) 2014 Daniel Tull. All rights reserved.
//

#import "DCTHidingDataSource.h"

@implementation DCTHidingDataSource

- (instancetype)initWithChildDataSource:(DCTDataSource *)childDataSource {
	self = [super init];
	if (!self) return nil;
	_childDataSource = childDataSource;
	_childDataSource.parent = self;
	return self;
}

#pragma mark - DCTParentDataSource

- (NSArray *)childDataSources {
	return @[self.childDataSource];
}

#pragma mark - DCTDataSource

- (id)userInfoValueForKey:(NSString *)key indexPath:(NSIndexPath *)indexPath {
	NSInteger numberOfItems = [self numberOfItemsInSection:0];
	if (numberOfItems > 0) {
		return [super userInfoValueForKey:key indexPath:indexPath];
	}
	return nil;
}

- (void)performUpdate:(DCTDataSourceUpdate *)update {

	NSInteger numberOfItems = [self numberOfItemsInSection:0];

	if (update.type == DCTDataSourceUpdateTypeItemInsert) {

		// Just inserted first object
		if (numberOfItems == 1) {
			update = [DCTDataSourceUpdate reloadUpdateWithIndex:0];
		}

	} else if (update.type == DCTDataSourceUpdateTypeItemDelete) {

		// Just deleted last object
		if (numberOfItems == 0) {
			update = [DCTDataSourceUpdate reloadUpdateWithIndex:0];
		}
	}

	[super performUpdate:update];
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
	return [self.childDataSource numberOfItemsInSection:section];
}

@end
