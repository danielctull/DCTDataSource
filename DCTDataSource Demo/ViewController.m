//
//  ViewController.m
//  DCTDataSource
//
//  Created by Daniel Tull on 06.01.2014.
//  Copyright (c) 2014 Daniel Tull. All rights reserved.
//

#import "ViewController.h"
#import <DCTDataSource/DCTDataSource.h>
#import "CollectionViewCell.h"

@interface ViewController () <DCTCollectionViewDataSourceDelegate>
@property (nonatomic) DCTCollectionViewDataSource *dataSource;
@property (nonatomic) DCTSplitDataSource *split;
@property (nonatomic) DCTArrayDataSource *list;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	DCTObjectDataSource *objectDS = [[DCTObjectDataSource alloc] initWithObject:@"zero"];

	self.list = [[DCTArrayDataSource alloc] initWithArray:@[ @"one", @"two", @"three", @"four", @"five", @"six", @"seven", @"eight", @"nine", @"ten" ]];
	[self.list setUserInfoValue:@"cell2" forKey:DCTCollectionViewDataSourceUserInfoKeys.cellReuseIdentifier];

	self.split = [[DCTSplitDataSource alloc] initWithType:DCTSplitDataSourceTypeRow];
	[self.split addChildDataSource:objectDS];
	//[self.split addChildDataSource:self.list];
	//[split addChildDataSource:objectDS3];

	self.dataSource = [[DCTCollectionViewDataSource alloc] initWithCollectionView:self.collectionView dataSource:self.split];
	self.dataSource.cellReuseIdentifier = @"cell";
}

- (void)toggle {

	if ([self.split.childDataSources containsObject:self.list])
		[self.split removeChildDataSource:self.list];
	else
		[self.split addChildDataSource:self.list];
}

#pragma mark - DCTCollectionViewDataSourceDelegate

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {

	NSAssert([cell isKindOfClass:[CollectionViewCell class]], @"Cell should be a CollectionViewCell");

	CollectionViewCell *collectionViewCell = (CollectionViewCell *)cell;
	NSString *object = [self.dataSource objectAtIndexPath:indexPath];
	collectionViewCell.label.text = object;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
	id object = [self.dataSource objectAtIndexPath:indexPath];

	if ([object isKindOfClass:[NSString class]] && [object isEqualToString:@"zero"])
		[self toggle];
}

@end
