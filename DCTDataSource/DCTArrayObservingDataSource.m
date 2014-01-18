/*
 DCTArrayObservingDataSource.m
 DCTDataSource
 
 Created by Daniel Tull on 24.04.2012.
 
 
 
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

@import UIKit;
#import "DCTArrayObservingDataSource.h"

void* DCTArrayObservingDataSourceObservingContext = &DCTArrayObservingDataSourceObservingContext;

@interface DCTArrayObservingDataSource ()
@property (nonatomic) NSArray *array;
@end

@implementation DCTArrayObservingDataSource

- (void)dealloc {
	[_object removeObserver:self 
				 forKeyPath:_keyPath
					context:DCTArrayObservingDataSourceObservingContext];
}

- (id)initWithObject:(id)object arrayKeyPath:(NSString *)keyPath {
	self = [self init];
	if (!self) return nil;
	
	_object = object;
	_keyPath = keyPath;
	_array = [_object valueForKeyPath:_keyPath];
	
	[_object addObserver:self 
			  forKeyPath:keyPath
				 options:NSKeyValueObservingOptionNew
				 context:DCTArrayObservingDataSourceObservingContext];
	
	return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
	
	if (context != DCTArrayObservingDataSourceObservingContext)
		return [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
		
	self.array = [_object valueForKeyPath:_keyPath];
	
	NSKeyValueChange changeType = [[change objectForKey:NSKeyValueChangeKindKey] unsignedIntegerValue];
	NSIndexSet *indexSet = [change objectForKey:NSKeyValueChangeIndexesKey];
	
	[self beginUpdates];
	
	[indexSet enumerateIndexesUsingBlock:^(NSUInteger i, BOOL *stop) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];

		DCTDataSourceUpdate *update;

		if (changeType == NSKeyValueChangeInsertion)
			update = [DCTDataSourceUpdate insertUpdateWithNewIndexPath:indexPath];
		else if (changeType == NSKeyValueChangeRemoval)
			update = [DCTDataSourceUpdate deleteUpdateWithOldIndexPath:indexPath];
		else if (changeType == NSKeyValueChangeReplacement)
			update = [DCTDataSourceUpdate reloadUpdateWithIndexPath:indexPath];

		if (update) [self performUpdate:update];
	}];
	
	[self endUpdates];
}

#pragma mark - DCTDataSource

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
	return [self.array objectAtIndex:indexPath.row];
}

- (NSInteger)numberOfSections {
	return 1;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
	return [self.array count];
}

@end
