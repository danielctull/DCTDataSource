//
//  NSIndexPath+DCTDataSource.m
//  DCTDataSource
//
//  Created by Daniel Tull on 17.02.2015.
//  Copyright (c) 2015 Daniel Tull. All rights reserved.
//

#import "NSIndexPath+DCTDataSource.h"

#if TARGET_OS_IPHONE

@import UIKit;

@implementation NSIndexPath (DCTDataSource)

+ (instancetype)dctDataSource_indexPathForRow:(NSInteger)row inSection:(NSInteger)section {
	return [self indexPathForRow:row inSection:section];
}

- (NSInteger)dctDataSource_row {
	return self.row;
}

- (NSInteger)dctDataSource_section {
	return self.section;
}

@end

#else

@implementation NSIndexPath (DCTDataSource)

+ (instancetype)dctDataSource_indexPathForRow:(NSInteger)row inSection:(NSInteger)section {
	NSIndexPath *indexPath = [self indexPathWithIndex:section];
	return [indexPath indexPathByAddingIndex:row];
}

- (NSInteger)dctDataSource_row {
	return [self indexAtPosition:1];
}

- (NSInteger)dctDataSource_section {
	return [self indexAtPosition:0];
}

@end

#endif
