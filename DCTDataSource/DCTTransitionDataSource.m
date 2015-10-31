
#import "DCTTransitionDataSource.h"
#import "DCTDataSourceUpdate.h"

@implementation DCTTransitionDataSource

- (void)reloadData {
	[self.parent reloadData];
}

- (NSArray *)childDataSources {

	if (!self.childDataSource) {
		return @[];
	}

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

	if (!animated
		|| !oldDataSource
		|| !newDataSource
		|| oldDataSource.numberOfSections > 1
		|| newDataSource.numberOfSections > 1
		|| newCount > 1000
		|| oldCount > 1000
	) {
		[self reloadData];
		return;
	}

	[self beginUpdates];

	for (NSInteger old = 0; old < oldCount; old++) {
		NSIndexPath *oldIndexPath = [NSIndexPath indexPathForItem:old inSection:0];
		id object = [oldDataSource objectAtIndexPath:oldIndexPath];
		NSIndexPath *newIndexPath = [newDataSource indexPathOfObject:object];

		if (!newIndexPath) {
			DCTDataSourceUpdate *update = [DCTDataSourceUpdate deleteUpdateWithOldIndexPath:oldIndexPath];
			[self performUpdate:update];
		}
	}

	for (NSInteger new = 0; new < newCount; new++) {
		NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:new inSection:0];
		id object = [newDataSource objectAtIndexPath:newIndexPath];
		NSIndexPath *oldIndexPath = [oldDataSource indexPathOfObject:object];

		if (!oldIndexPath) {
			DCTDataSourceUpdate *update = [DCTDataSourceUpdate insertUpdateWithNewIndexPath:newIndexPath];
			[self performUpdate:update];
		}
	}

	[self endUpdates];
}

@end
