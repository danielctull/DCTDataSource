//
//  DCTCollectionViewDataSource.m
//  DCTTableViewDataSources
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

@implementation DCTCollectionViewDataSource

- (id)initWithCollectionView:(UICollectionView *)collectionView dataSource:(DCTDataSource *)dataSource {
	self = [super init];
	if (!self) return nil;
	_dataSource = dataSource;
	_dataSource.parent = self;
	_collectionView = collectionView;
	_collectionView.dataSource = self;
	return self;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
	return [self numberOfSections];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return [self numberOfItemsInSection:section];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
				  cellForItemAtIndexPath:(NSIndexPath *)indexPath {

	NSString *reuseIdentifier = [self userInfoValueForKey:DCTCollectionViewDataSourceUserInfoKeys.cellReuseIdentifier
												indexPath:indexPath];

	return [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
													 forIndexPath:indexPath];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
		   viewForSupplementaryElementOfKind:(NSString *)kind
								 atIndexPath:(NSIndexPath *)indexPath {

	NSString *reuseIdentifier = [self userInfoValueForKey:DCTCollectionViewDataSourceUserInfoKeys.supplementaryViewReuseIdentifier
												indexPath:indexPath];

	return [collectionView dequeueReusableSupplementaryViewOfKind:kind
											  withReuseIdentifier:reuseIdentifier
													 forIndexPath:indexPath];
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
	[super beginUpdates];
}

- (void)endUpdates {}

- (void)performUpdate:(DCTDataSourceUpdate *)update {
	
}

@end
