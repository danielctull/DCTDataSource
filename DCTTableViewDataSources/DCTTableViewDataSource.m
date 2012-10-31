//
//  DCTTableViewDataSource.m
//  DCTTableViewDataSources
//
//  Created by Daniel Tull on 30/10/2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTTableViewDataSource.h"
#import "UITableView+DCTNibRegistration.h"
#import "DCTTableViewCell.h"

@implementation DCTTableViewDataSource

- (id)initWithTableView:(UITableView *)tableView dataSource:(DCTDataSource *)dataSource {
	self = [super init];
	if (!self) return nil;
	_dataSource = dataSource;
	_tableView = tableView;
	_tableView.dataSource = self;

	[_tableView registerClass:[DCTTableViewCell class] forCellReuseIdentifier:@"DCTTableViewCell"];
	_cellReuseIdentifierHandler = ^NSString *(NSIndexPath *indexPath, id object) {
		return @"DCTTableViewCell";
	};

	return self;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	return [self.dataSource numberOfSections];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return [self.dataSource numberOfItemsInSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	NSString *cellIdentifier = [self _cellReuseIdentifierAtIndexPath:indexPath];
    UITableViewCell *cell = [tv dct_dequeueReusableCellWithIdentifier:cellIdentifier];

	if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
											 reuseIdentifier:cellIdentifier];

	id object = [self.dataSource objectAtIndexPath:indexPath];

	if (self.cellConfigurer != NULL) self.cellConfigurer(cell, indexPath, object);

	return cell;
}

- (NSString *)_cellReuseIdentifierAtIndexPath:(NSIndexPath *)indexPath {
	id object = [self.dataSource objectAtIndexPath:indexPath];
	return self.cellReuseIdentifierHandler(indexPath, object);
}

@end
