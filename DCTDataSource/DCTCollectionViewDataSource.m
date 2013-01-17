//
//  DCTCollectionViewDataSource.m
//  DCTTableViewDataSources
//
//  Created by Daniel Tull on 30/10/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTCollectionViewDataSource.h"
#import "_DCTDataSourceUpdate.h"

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

	id object = [self objectAtIndexPath:indexPath];
	NSString *reuseIdentifier = self.cellReuseIdentifierHandler(indexPath, object);
	return [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier
													 forIndexPath:indexPath];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
		   viewForSupplementaryElementOfKind:(NSString *)kind
								 atIndexPath:(NSIndexPath *)indexPath {
	
	id object = [self objectAtIndexPath:indexPath];
	NSString *reuseIdentifier = self.supplementaryViewReuseIdentifierHandler(indexPath, object);
	return [collectionView dequeueReusableSupplementaryViewOfKind:kind
											  withReuseIdentifier:reuseIdentifier
													 forIndexPath:indexPath];
}

- (void)reloadData {
	[super reloadData];
	[self.collectionView reloadData];
}

- (void)beginUpdates {
	[super beginUpdates];
}

- (void)endUpdates {}

- (void)performUpdate:(_DCTDataSourceUpdate *)update {
	
}

@end
