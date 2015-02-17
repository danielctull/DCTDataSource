//
//  NSIndexPath+DCTDataSource.m
//  DCTDataSource
//
//  Created by Daniel Tull on 17.02.2015.
//  Copyright (c) 2015 Daniel Tull. All rights reserved.
//

#import "NSIndexPath+DCTDataSource.h"

@implementation NSIndexPath (DCTDataSource)

+ (instancetype)dctDataSource_indexPathForRow:(NSInteger)row inSection:(NSInteger)section {
#if TARGET_OS_IPHONE
	return [self indexPathForRow:row inSection:section];
#else
	NSIndexPath *indexPath = [self indexPathWithIndex:section];
	return [indexPath indexPathByAddingIndex:row];
#endif
}

- (NSInteger)dctDataSource_row {
#if TARGET_OS_IPHONE
	return self.row;
#else
	return [self indexAtPosition:1];
#endif
}

- (NSInteger)dctDataSource_section {
#if TARGET_OS_IPHONE
	return self.section;
#else
	return [self indexAtPosition:0];
#endif
}

@end
