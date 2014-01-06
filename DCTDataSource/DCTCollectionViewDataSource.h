//
//  DCTCollectionViewDataSource.h
//  DCTTableViewDataSources
//
//  Created by Daniel Tull on 30/10/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import <UIKit/UIKit.h>
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
