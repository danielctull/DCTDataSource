//
//  NSIndexPath+DCTDataSource.h
//  DCTDataSource
//
//  Created by Daniel Tull on 17.02.2015.
//  Copyright (c) 2015 Daniel Tull. All rights reserved.
//

@import Foundation;

@interface NSIndexPath (DCTDataSource)

+ (instancetype)dctDataSource_indexPathForRow:(NSInteger)row inSection:(NSInteger)section;

@property(nonatomic,readonly) NSInteger dctDataSource_section;
@property(nonatomic,readonly) NSInteger dctDataSource_row;

@end
