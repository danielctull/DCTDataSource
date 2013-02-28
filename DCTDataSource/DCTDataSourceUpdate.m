//
//  _DCTTableViewDataSourceUpdate.m
//  DCTTableViewDataSources
//
//  Created by Daniel Tull on 08.10.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTDataSourceUpdate.h"

BOOL DCTDataSourceUpdateTypeIncludes(DCTDataSourceUpdateType type, DCTDataSourceUpdateType testType) {
	return (type & testType) == testType;
}

@implementation DCTDataSourceUpdate

+ (instancetype)updateWithType:(DCTDataSourceUpdateType)type indexPath:(NSIndexPath *)indexPath {
	DCTDataSourceUpdate *update = [self new];
	update.type = type;
	update.indexPath = indexPath;
	return update;
}

+ (instancetype)updateWithType:(DCTDataSourceUpdateType)type index:(NSInteger)index {
	DCTDataSourceUpdate *update = [self new];
	update.type = type;
	update.indexPath = [NSIndexPath indexPathWithIndex:index];
	return update;
}

- (NSInteger)section {
	return [self.indexPath indexAtPosition:0];
}

- (BOOL)isSectionUpdate {
	return (DCTDataSourceUpdateTypeIncludes(self.type, DCTDataSourceUpdateTypeSectionInsert)
			|| DCTDataSourceUpdateTypeIncludes(self.type, DCTDataSourceUpdateTypeSectionDelete));
}

- (NSComparisonResult)compare:(DCTDataSourceUpdate *)update {
	
	NSComparisonResult result = [[NSNumber numberWithInteger:self.type] compare:[NSNumber numberWithInteger:update.type]];
	
	if (result != NSOrderedSame) return result;
	
	return [self.indexPath compare:update.indexPath];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; indexPath = %@; type = %i>",
			NSStringFromClass([self class]),
			self,
			self.indexPath,
			self.type];
}

@end
