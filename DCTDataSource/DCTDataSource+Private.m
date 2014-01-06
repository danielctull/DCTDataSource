//
//  DCTDataSource+Private.m
//  DCTDataSource
//
//  Created by Daniel Tull on 06.01.2014.
//  Copyright (c) 2014 Daniel Tull. All rights reserved.
//

#import "DCTDataSource+Private.h"

@implementation DCTDataSource (Private)

- (id)userInfoValueForKey:(NSString *)key indexPath:(NSIndexPath *)indexPath {
	return [self userInfoValueForKey:key];
}

@end
