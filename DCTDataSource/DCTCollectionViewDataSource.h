//
//  DCTCollectionViewDataSource.h
//  DCTTableViewDataSources
//
//  Created by Daniel Tull on 30/10/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

@import UIKit;
#import "DCTParentDataSource.h"

extern const struct DCTCollectionViewDataSourceUserInfoKeys {
	__unsafe_unretained NSString *cellReuseIdentifier;
	__unsafe_unretained NSString *supplementaryViewReuseIdentifier;
} DCTCollectionViewDataSourceUserInfoKeys;


@interface DCTCollectionViewDataSource : DCTParentDataSource <UICollectionViewDataSource>

- (id)initWithCollectionView:(UICollectionView *)collectionView dataSource:(DCTDataSource *)dataSource;
@property (nonatomic, readonly, weak) UICollectionView *collectionView;
@property (nonatomic, readonly, strong) DCTDataSource *dataSource;

@property (nonatomic) NSString *cellReuseIdentifier;
@property (nonatomic) NSString *supplementaryViewReuseIdentifier;

@end



// Additional methods that will get called on the collection view's delegate
@protocol DCTCollectionViewDataSourceDelegate <UICollectionViewDelegate>

@optional
- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath;
- (void)collectionView:(UICollectionView *)collectionView willDisplaySupplementaryView:(UICollectionReusableView *)view forElementOfKind:(NSString *)elementKind atIndexPath:(NSIndexPath *)indexPath;
@end


