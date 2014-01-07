/*
 DCTArrayTableViewDataSource.m
 DCTTableViewDataSources
 
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
#import "UITableView+DCTTableViewDataSources.h"

@implementation DCTArrayDataSource {
	__strong NSMutableArray *_array;
}

- (void)setArray:(NSArray *)array {
	
	[self beginUpdates];
	
	[_array enumerateObjectsUsingBlock:^(id obj, NSUInteger i, BOOL *stop) {
		DCTDataSourceUpdate *update = [DCTDataSourceUpdate updateWithType:DCTDataSourceUpdateTypeItemDelete indexPath:[NSIndexPath indexPathForRow:i inSection:0]];
		[self performUpdate:update];
	}];
		
	
	_array = [array mutableCopy];
	
	[_array enumerateObjectsUsingBlock:^(id obj, NSUInteger i, BOOL *stop) {
		DCTDataSourceUpdate *update = [DCTDataSourceUpdate updateWithType:DCTDataSourceUpdateTypeItemInsert indexPath:[NSIndexPath indexPathForRow:i inSection:0]];
		[self performUpdate:update];
	}];
	
	[self endUpdates];
}

- (NSArray *)array {
	return [_array copy];
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
	return [self.array count];
}

#pragma mark - DCTEditableDataSource

- (BOOL)canEditObjectAtIndexPath:(NSIndexPath *)indexPath {
	return self.editable;
}

- (BOOL)canMoveObjectAtIndexPath:(NSIndexPath *)indexPath {
	return self.reorderable;
}

- (id)generateObject {
	return self.objectGenerator();
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
	return [self.array objectAtIndex:indexPath.row];
}

- (void)insertObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
	[_array insertObject:object atIndex:indexPath.row];
}

- (void)removeObjectAtIndexPath:(NSIndexPath *)indexPath {
	[_array removeObjectAtIndex:indexPath.row];
}

- (void)moveObjectAtIndexPath:(NSIndexPath *)oldIndexPath toIndexPath:(NSIndexPath *)newIndexPath {
	id object = [self objectAtIndexPath:oldIndexPath];
	[self removeObjectAtIndexPath:oldIndexPath];
	[self insertObject:object atIndexPath:newIndexPath];
}

@end
