//
//  DCTDataSourceUpdate.m
//  DCTDataSource
//
//  Created by Daniel Tull on 08.10.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTDataSourceUpdate.h"

static NSString *const DCTDataSourceUpdateString[] = {
	@"DCTDataSourceUpdateTypeItemDelete",
	@"DCTDataSourceUpdateTypeSectionDelete",
	@"DCTDataSourceUpdateTypeItemInsert",
	@"DCTDataSourceUpdateTypeSectionInsert",
	@"DCTDataSourceUpdateTypeItemReload",
	@"DCTDataSourceUpdateTypeSectionReload",
	@"DCTDataSourceUpdateTypeItemMove"
};

BOOL DCTDataSourceUpdateTypeIncludes(DCTDataSourceUpdateType type, DCTDataSourceUpdateType testType) {
	return (type & testType) == testType;
}

@implementation DCTDataSourceUpdate

- (instancetype)initWithType:(DCTDataSourceUpdateType)type oldIndexPath:(NSIndexPath *)oldIndexPath newIndexPath:(NSIndexPath *)newIndexPath {
	self = [self init];
	if (!self) return nil;
	_type = type;
	_oldIndexPath = oldIndexPath;
	_newIndexPath = newIndexPath;
	return self;
}

+ (instancetype)reloadUpdateWithIndexPath:(NSIndexPath *)indexPath {
	return [[self alloc] initWithType:DCTDataSourceUpdateTypeItemReload oldIndexPath:indexPath newIndexPath:indexPath];
}

+ (instancetype)insertUpdateWithNewIndexPath:(NSIndexPath *)newIndexPath {
	return [[self alloc] initWithType:DCTDataSourceUpdateTypeItemInsert oldIndexPath:nil newIndexPath:newIndexPath];
}

+ (instancetype)deleteUpdateWithOldIndexPath:(NSIndexPath *)oldIndexPath {
	return [[self alloc] initWithType:DCTDataSourceUpdateTypeItemDelete oldIndexPath:oldIndexPath newIndexPath:nil];
}

+ (instancetype)moveUpdateWithOldIndexPath:(NSIndexPath *)oldIndexPath newIndexPath:(NSIndexPath *)newIndexPath {
	return [[self alloc] initWithType:DCTDataSourceUpdateTypeItemMove oldIndexPath:oldIndexPath newIndexPath:newIndexPath];
}

// Section
+ (instancetype)insertUpdateWithIndex:(NSInteger)index {
	NSUInteger indexes[] = {index,0};
	NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
	return [[self alloc] initWithType:DCTDataSourceUpdateTypeSectionInsert oldIndexPath:indexPath newIndexPath:indexPath];
}

+ (instancetype)deleteUpdateWithIndex:(NSInteger)index {
	NSUInteger indexes[] = {index,0};
	NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
	return [[self alloc] initWithType:DCTDataSourceUpdateTypeSectionDelete oldIndexPath:indexPath newIndexPath:indexPath];
}

+ (instancetype)reloadUpdateWithIndex:(NSInteger)index {
	NSUInteger indexes[] = {index,0};
	NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
	return [[self alloc] initWithType:DCTDataSourceUpdateTypeSectionReload oldIndexPath:indexPath newIndexPath:indexPath];
}

- (NSInteger)section {
	return [self.oldIndexPath indexAtPosition:0];
}

- (BOOL)isSectionUpdate {
	return (DCTDataSourceUpdateTypeIncludes(self.type, DCTDataSourceUpdateTypeSectionInsert)
			|| DCTDataSourceUpdateTypeIncludes(self.type, DCTDataSourceUpdateTypeSectionDelete));
}

- (NSComparisonResult)compare:(DCTDataSourceUpdate *)update {
	
	NSComparisonResult result = [[NSNumber numberWithInteger:self.type] compare:[NSNumber numberWithInteger:update.type]];
	
	if (result != NSOrderedSame) return result;
	
	return [self.oldIndexPath compare:update.oldIndexPath];
}

- (NSString *)description {
	return [NSString stringWithFormat:@"<%@: %p; oldIndexPath = %@; newIndexPath = %@; type = %@>",
			NSStringFromClass([self class]),
			self,
			[self descriptionForIndexPath:self.oldIndexPath],
			[self descriptionForIndexPath:self.newIndexPath],
			DCTDataSourceUpdateString[self.type]];
}

- (NSString *)descriptionForIndexPath:(NSIndexPath *)indexPath {

	NSMutableArray *indexes = [NSMutableArray new];
	NSUInteger length = indexPath.length;
	for (NSUInteger i = 0; i < length; i++)
		[indexes addObject:[@([indexPath indexAtPosition:i]) stringValue]];

	NSString *indexString = [indexes componentsJoinedByString:@" - "];
	return [NSString stringWithFormat:@"{%@}", indexString];
}

@end
