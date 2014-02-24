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
@property (nonatomic) DCTSplitDataSource *split1;
@property (nonatomic) DCTSplitDataSource *split2;
@property (nonatomic) DCTArrayDataSource *list1;
@property (nonatomic) DCTArrayDataSource *list2;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	DCTObjectDataSource *objectDS1 = [[DCTObjectDataSource alloc] initWithObject:@"zero"];

	self.list1 = [[DCTArrayDataSource alloc] initWithArray:@[ @"one", @"two", @"three", @"four", @"five", @"six", @"seven", @"eight", @"nine", @"ten" ]];
	[self.list1 setUserInfoValue:@"cell2" forKey:DCTCollectionViewDataSourceUserInfoKeys.cellReuseIdentifier];

	DCTObjectDataSource *objectDS2 = [[DCTObjectDataSource alloc] initWithObject:@"eleven"];

	self.list2 = [[DCTArrayDataSource alloc] initWithArray:@[ @"twelve", @"thirteen", @"fourteen", @"fifteen", @"sixteen", @"seventeen", @"eighteen", @"nineteen", @"twenty" ]];

	[self.list2 setUserInfoValue:@"cell2" forKey:DCTCollectionViewDataSourceUserInfoKeys.cellReuseIdentifier];

	self.split1 = [[DCTSplitDataSource alloc] initWithType:DCTSplitDataSourceTypeRow];
	[self.split1 addChildDataSource:objectDS1];

	self.split2 = [[DCTSplitDataSource alloc] initWithType:DCTSplitDataSourceTypeRow];
	[self.split2 addChildDataSource:objectDS2];

	DCTSplitDataSource *split = [[DCTSplitDataSource alloc] initWithType:DCTSplitDataSourceTypeSection];
	[split addChildDataSource:self.split1];
	[split addChildDataSource:self.split2];

	self.dataSource = [[DCTCollectionViewDataSource alloc] initWithCollectionView:self.collectionView dataSource:split];
	self.dataSource.cellReuseIdentifier = @"cell";
}

- (void)toggleList1 {

	if ([self.split1.childDataSources containsObject:self.list1])
		[self.split1 removeChildDataSource:self.list1];
	else
		[self.split1 addChildDataSource:self.list1];
}

- (void)toggleList2 {

	if ([self.split2.childDataSources containsObject:self.list2])
		[self.split2 removeChildDataSource:self.list2];
	else
		[self.split2 addChildDataSource:self.list2];
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

	if (![object isKindOfClass:[NSString class]]) return;

	if ([object isEqualToString:@"zero"])
		[self toggleList1];
	else if ([object isEqualToString:@"eleven"])
		[self toggleList2];
}

@end
