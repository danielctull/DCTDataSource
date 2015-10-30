
#import "DCTTransitionDataSource.h"
#import "DCTDataSourceUpdate.h"

@implementation DCTTransitionDataSource

- (void)reloadData {
	[self.parent reloadData];
}

- (NSArray *)childDataSources {
	return @[self.childDataSource];
}

- (void)setChildDataSource:(DCTDataSource *)childDataSource {
	[self setChildDataSource:childDataSource animated:NO];
}

- (void)setChildDataSource:(DCTDataSource *)childDataSource animated:(BOOL)animated {

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdirect-ivar-access"
	_childDataSource.parent = nil;
	DCTDataSource *oldDataSource = _childDataSource;

	_childDataSource = childDataSource;

	_childDataSource.parent = self;
	DCTDataSource *newDataSource = _childDataSource;
#pragma clang diagnostic pop

	NSInteger oldCount = [oldDataSource numberOfItemsInSection:0];
	NSInteger newCount = [newDataSource numberOfItemsInSection:0];

	if (!oldDataSource
		|| !newDataSource
		|| oldDataSource.numberOfSections > 1
		|| newDataSource.numberOfSections > 1
		|| newCount > 1000
		|| oldCount > 1000
	) {
		[self reloadData];
		return;
	}

	NSMutableArray *updates = [NSMutableArray new];

	for (NSInteger old = 0; old < oldCount; old++) {
		NSIndexPath *oldIndexPath = [NSIndexPath indexPathForItem:old inSection:0];
		id object = [oldDataSource objectAtIndexPath:oldIndexPath];
		NSIndexPath *newIndexPath = [newDataSource indexPathOfObject:object];

		if (!newIndexPath) {
			DCTDataSourceUpdate *update = [DCTDataSourceUpdate deleteUpdateWithOldIndexPath:oldIndexPath];
			[updates addObject:update];
		}
	}

	for (NSInteger new = 0; new < newCount; new++) {
		NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:new inSection:0];
		id object = [newDataSource objectAtIndexPath:newIndexPath];
		NSIndexPath *oldIndexPath = [oldDataSource indexPathOfObject:object];

		if (!oldIndexPath) {
			DCTDataSourceUpdate *update = [DCTDataSourceUpdate insertUpdateWithNewIndexPath:newIndexPath];
			[updates addObject:update];
		}
	}

	[updates sortUsingComparator:^NSComparisonResult(DCTDataSourceUpdate *update1, DCTDataSourceUpdate *update2) {

		NSIndexPath *indexPath1 = update1.oldIndexPath ?: update1.newIndexPath;
		NSIndexPath *indexPath2 = update2.oldIndexPath ?: update2.newIndexPath;

		NSComparisonResult result = [indexPath1 compare:indexPath2];
		if (result != NSOrderedSame) {
			return result;
		}

		DCTDataSourceUpdateType type1 = update1.type;
		DCTDataSourceUpdateType type2 = update2.type;


		if (type1 == type2) {
			return NSOrderedSame;
		} else if (type1 == DCTDataSourceUpdateTypeItemDelete) {
			return NSOrderedAscending;
		}

		return NSOrderedDescending;
	}];

	[self beginUpdates];
	for (DCTDataSourceUpdate *update in updates) {
		[self performUpdate:update];
	}
	[self endUpdates];
}

@end
