//
//  _DCTTableViewDataSourceUpdate.m
//  DCTTableViewDataSources
//
//  Created by Daniel Tull on 08.10.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "_DCTTableViewDataSourceUpdate.h"

BOOL DCTTableViewDataSourceUpdateTypeIncludes(DCTTableViewDataSourceUpdateType type, DCTTableViewDataSourceUpdateType testType) {
	return (type & testType) == testType;
}

@implementation _DCTTableViewDataSourceUpdate

- (BOOL)isSectionUpdate {
	return (DCTTableViewDataSourceUpdateTypeIncludes(self.type, DCTTableViewDataSourceUpdateTypeSectionInsert)
			|| DCTTableViewDataSourceUpdateTypeIncludes(self.type, DCTTableViewDataSourceUpdateTypeSectionDelete));
}

- (NSComparisonResult)compare:(_DCTTableViewDataSourceUpdate *)update {
	
	NSComparisonResult result = [[NSNumber numberWithInteger:self.type] compare:[NSNumber numberWithInteger:update.type]];
	
	if (result != NSOrderedSame) return result;
	
	return [self.indexPath compare:update.indexPath];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; indexPath = %@; type = %i; animation = %i>",
			NSStringFromClass([self class]),
			self,
			self.indexPath,
			self.type,
			self.animation];
}

@end
