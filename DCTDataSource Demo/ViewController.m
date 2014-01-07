//
//  ViewController.m
//  DCTDataSource
//
//  Created by Daniel Tull on 06.01.2014.
//  Copyright (c) 2014 Daniel Tull. All rights reserved.
//

#import "ViewController.h"
#import "DCTDataSource.h"
#import "DCTCollectionViewDataSource.h"
#import "DCTSplitDataSource.h"
#import "CollectionViewCell.h"

@interface ViewController () <DCTCollectionViewDataSourceDelegate>
@property (nonatomic) DCTCollectionViewDataSource *dataSource;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	DCTObjectDataSource *objectDS = [DCTObjectDataSource new];
	objectDS.object = @"hello";

	DCTArrayDataSource *objectDS2 = [[DCTArrayDataSource alloc] initWithArray:@[ @"one", @"two", @"three", @"four" ]];
	[objectDS2 setUserInfoValue:@"cell2" forKey:DCTCollectionViewDataSourceUserInfoKeys.cellReuseIdentifier];

	DCTSplitDataSource *split = [[DCTSplitDataSource alloc] initWithType:DCTSplitDataSourceTypeRow];
	[split addChildDataSource:objectDS];
	[split addChildDataSource:objectDS2];

	self.dataSource = [[DCTCollectionViewDataSource alloc] initWithCollectionView:self.collectionView dataSource:split];
	self.dataSource.cellReuseIdentifier = @"cell";
}

#pragma mark - DCTCollectionViewDataSourceDelegate

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {

	NSAssert([cell isKindOfClass:[CollectionViewCell class]], @"Cell should be a CollectionViewCell");

	CollectionViewCell *collectionViewCell = (CollectionViewCell *)cell;
	NSString *object = [self.dataSource objectAtIndexPath:indexPath];
	collectionViewCell.label.text = object;
}

@end
