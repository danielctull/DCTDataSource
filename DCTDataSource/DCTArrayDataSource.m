/*
 DCTArrayDataSource.m
 DCTDataSource
 
 Created by Daniel Tull on 26.12.2011.
 
 
 
 Copyright (c) 2011 Daniel Tull. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 
 * Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 * Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation
 and/or other materials provided with the distribution.
 
 * Neither the name of the author nor the names of its contributors may be used
 to endorse or promote products derived from this software without specific
 prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#import "DCTArrayDataSource.h"
#import "UITableView+DCTDataSource.h"

@interface DCTArrayDataSource ()
@property (nonatomic, copy) NSArray *filteredArray;
@end

@implementation DCTArrayDataSource

- (instancetype)initWithArray:(NSArray *)array {
	self = [self init];
	if (!self) return nil;
	_array = [array copy];
	_filteredArray = _array;
	return self;
}

- (NSInteger)numberOfSections {
	return 1;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
	return [self.filteredArray count];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
	return [self.filteredArray objectAtIndex:indexPath.row];
}

- (void)setPredicate:(NSPredicate *)predicate {
	_predicate = [predicate copy];
	self.filteredArray = [self.array filteredArrayUsingPredicate:_predicate];
}

- (void)setFilteredArray:(NSArray *)filteredArray {

	NSArray *oldArray = _filteredArray;
	NSArray *newArray = [filteredArray copy];
	_filteredArray = newArray;

	[self beginUpdates];

	NSUInteger oldCount = [oldArray count];
	NSUInteger newCount = [newArray count];
	NSUInteger count = MAX(oldCount, newCount);

	for (NSUInteger i = 0; i < count; i++) {

		if (i < oldCount) {
			id object = [oldArray objectAtIndex:i];
			if (![newArray containsObject:object]) {
				NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
				DCTDataSourceUpdate *update = [DCTDataSourceUpdate deleteUpdateWithOldIndexPath:indexPath];
				[self performUpdate:update];
				continue;
			}
		}

		if (i < newCount) {
			id object = [newArray objectAtIndex:i];
			if (![oldArray containsObject:object]) {
				NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
				DCTDataSourceUpdate *update = [DCTDataSourceUpdate insertUpdateWithNewIndexPath:indexPath];
				[self performUpdate:update];
			}
		}
	}

	[self endUpdates];
}

@end
