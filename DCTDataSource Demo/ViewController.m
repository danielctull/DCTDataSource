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

@interface ViewController ()
@property (nonatomic) DCTCollectionViewDataSource *dataSource;
@end

@implementation ViewController

- (void)viewDidLoad {
	[super viewDidLoad];

	DCTObjectDataSource *objectDS = [DCTObjectDataSource new];
	objectDS.object = @"hello";
	[objectDS setUserInfoValue:@"cell" forKey:DCTCollectionViewDataSourceUserInfoKeys.cellReuseIdentifier];

	DCTArrayDataSource *objectDS2 = [DCTArrayDataSource new];
	objectDS2.array = @[ @"hello", @"two", @"three", @"four" ];
	[objectDS2 setUserInfoValue:@"cell2" forKey:DCTCollectionViewDataSourceUserInfoKeys.cellReuseIdentifier];

	DCTSplitDataSource *split = [[DCTSplitDataSource alloc] initWithType:DCTSplitDataSourceTypeRow];
	[split addChildDataSource:objectDS];
	[split addChildDataSource:objectDS2];

	self.dataSource = [[DCTCollectionViewDataSource alloc] initWithCollectionView:self.collectionView dataSource:split];
}

@end
