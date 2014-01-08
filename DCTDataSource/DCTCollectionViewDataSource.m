//
//  DCTCollectionViewDataSource.m
//  DCTDataSource
//
//  Created by Daniel Tull on 30/10/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTCollectionViewDataSource.h"
#import "DCTDataSourceUpdate.h"

const struct DCTCollectionViewDataSourceUserInfoKeys DCTCollectionViewDataSourceUserInfoKeys = {
	.cellReuseIdentifier = @"cellReuseIdentifier",
	.supplementaryViewReuseIdentifier = @"supplementaryViewReuseIdentifier"
};

@interface DCTCollectionViewDataSource ()
@property (nonatomic) NSMutableArray *updates;
@end

@implementation DCTCollectionViewDataSource

- (id)initWithCollectionView:(UICollectionView *)collectionView dataSource:(DCTDataSource *)dataSource {
	self = [super init];
	if (!self) return nil;
	_dataSource = dataSource;
	_dataSource.parent = self;
	_collectionView = collectionView;
	_collectionView.dataSource = self;
	[_collectionView reloadData];
	return self;
}

- (NSArray *)childDataSources {
	return @[self.dataSource];
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return [self.dataSource numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [self.dataSource numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
				  cellForItemAtIndexPath:(NSIndexPath *)indexPath {

	NSString *reuseIdentifier = [self userInfoValueForKey:DCTCollectionViewDataSourceUserInfoKeys.cellReuseIdentifier
												indexPath:indexPath];

	UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
																		   forIndexPath:indexPath];

	if ([self.collectionView.delegate conformsToProtocol:@protocol(DCTCollectionViewDataSourceDelegate)]) {
		id<DCTCollectionViewDataSourceDelegate> delegate = (id<DCTCollectionViewDataSourceDelegate>)self.collectionView.delegate;
		if ([delegate respondsToSelector:@selector(collectionView:willDisplayCell:forItemAtIndexPath:)])
			[delegate collectionView:collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
	}

	return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
		   viewForSupplementaryElementOfKind:(NSString *)kind
								 atIndexPath:(NSIndexPath *)indexPath {

	NSString *reuseIdentifier = [self userInfoValueForKey:DCTCollectionViewDataSourceUserInfoKeys.supplementaryViewReuseIdentifier
												indexPath:indexPath];

	UICollectionReusableView *view = [collectionView dequeueReusableSupplementaryViewOfKind:kind
																		withReuseIdentifier:reuseIdentifier
																			   forIndexPath:indexPath];

	if ([self.collectionView.delegate conformsToProtocol:@protocol(DCTCollectionViewDataSourceDelegate)]) {
		id<DCTCollectionViewDataSourceDelegate> delegate = (id<DCTCollectionViewDataSourceDelegate>)self.collectionView.delegate;
		if ([delegate respondsToSelector:@selector(collectionView:willDisplaySupplementaryView:forElementOfKind:atIndexPath:)])
			[delegate collectionView:collectionView willDisplaySupplementaryView:view forElementOfKind:kind atIndexPath:indexPath];
	}

	return view;
}

#pragma mark - Properties

- (NSString *)cellReuseIdentifier {
	return [self userInfoValueForKey:DCTCollectionViewDataSourceUserInfoKeys.cellReuseIdentifier];
}

- (void)setCellReuseIdentifier:(NSString *)cellReuseIdentifier {
	[self setUserInfoValue:cellReuseIdentifier forKey:DCTCollectionViewDataSourceUserInfoKeys.cellReuseIdentifier];
}

- (NSString *)supplementaryViewReuseIdentifier {
	return [self userInfoValueForKey:DCTCollectionViewDataSourceUserInfoKeys.supplementaryViewReuseIdentifier];
}

- (void)setSupplementaryViewReuseIdentifier:(NSString *)supplementaryViewReuseIdentifier {
	[self setUserInfoValue:supplementaryViewReuseIdentifier forKey:DCTCollectionViewDataSourceUserInfoKeys.supplementaryViewReuseIdentifier];
}

#pragma mark - Updates

- (void)reloadData {
	[super reloadData];
	[self.collectionView reloadData];
}

- (void)beginUpdates {
	self.updates = [NSMutableArray new];
}

- (void)performUpdate:(DCTDataSourceUpdate *)update {
	[self.updates addObject:update];
}

- (void)endUpdates {

	[self.collectionView performBatchUpdates:^{

		for (DCTDataSourceUpdate *update in self.updates)
			[self applyUpdate:update];

	} completion:nil];

	self.updates = nil;
}

- (void)applyUpdate:(DCTDataSourceUpdate *)update {

	switch (update.type) {

		case DCTDataSourceUpdateTypeItemInsert:
			[self.collectionView insertItemsAtIndexPaths:@[update.newIndexPath]];
			break;

		case DCTDataSourceUpdateTypeItemDelete:
			[self.collectionView deleteItemsAtIndexPaths:@[update.oldIndexPath]];
			break;

		case DCTDataSourceUpdateTypeItemReload:
			[self.collectionView reloadItemsAtIndexPaths:@[update.oldIndexPath]];
			break;

		case DCTDataSourceUpdateTypeSectionInsert:
			[self.collectionView insertSections:[NSIndexSet indexSetWithIndex:update.section]];
			break;

		case DCTDataSourceUpdateTypeSectionDelete:
			[self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:update.section]];
			break;

		case DCTDataSourceUpdateTypeItemMove:
			[self.collectionView moveItemAtIndexPath:update.oldIndexPath toIndexPath:update.newIndexPath];
			break;
	}
}

@end
