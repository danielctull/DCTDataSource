//
//  DCTTestDataSource.m
//  DCTDataSource
//
//  Created by Daniel Tull on 02/02/2014.
//  Copyright (c) 2014 Daniel Tull. All rights reserved.
//

#import "DCTTestDataSource.h"

@interface DCTTestDataSource ()
@property (nonatomic) NSMutableArray *internalUpdates;
@end

@implementation DCTTestDataSource

- (instancetype)initWithDataSource:(DCTDataSource *)dataSource {
	self = [self init];
	if (!self) return nil;
	_dataSource = dataSource;
	_dataSource.parent = self;
	_internalUpdates = [NSMutableArray new];
	return self;
}

- (NSArray *)childDataSources {
	return @[self.dataSource];
}

- (NSArray *)updates {
	return [self.internalUpdates copy];
}

- (void)performUpdate:(DCTDataSourceUpdate *)update {
	NSLog(@"%@:%@ %@", self, NSStringFromSelector(_cmd), update);
	[self.internalUpdates addObject:update];
}

@end
