//
//  DCTCollectionViewDataSource.m
//  DCTTableViewDataSources
//
//  Created by Daniel Tull on 30/10/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTCollectionViewDataSource.h"

@implementation DCTCollectionViewDataSource

- (id)initWithCollectionView:(UICollectionView *)collectionView dataSource:(DCTDataSource *)dataSource {
	self = [super init];
	if (!self) return nil;
	_dataSource = dataSource;
	_collectionView = collectionView;
	_collectionView.dataSource = self;
	return self;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
	return 0;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
				  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
	return nil;
}

@end
