/*
 DCTTableViewDataSource.h
 DCTDataSource
 
 Created by Daniel Tull on 20.05.2011.
 
 
 
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

#import "DCTDataSource.h"

@interface DCTDataSource ()
@property (nonatomic) NSMutableArray *updates;
@property (nonatomic) NSMutableDictionary *userInfo;
@end

@implementation DCTDataSource

#pragma mark - DCTTableViewDataSource

- (void)reloadData {
	[self.parent reloadData];
}

- (NSInteger)numberOfSections {
	return 0;
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
	return 0;
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
	return indexPath;
}

- (NSIndexPath *)indexPathOfObject:(id)object {
	return nil;
}

- (NSMutableDictionary *)userInfo {

	if (!_userInfo) _userInfo = [NSMutableDictionary new];

	return _userInfo;
}

- (void)setUserInfoValue:(id)value forKey:(NSString *)key {
	[self.userInfo setObject:value forKey:key];
}

- (id)userInfoValueForKey:(NSString *)key {
	return [self.userInfo objectForKey:key];
}

- (id)userInfoValueForKey:(NSString *)key indexPath:(NSIndexPath *)indexPath {
	return [self userInfoValueForKey:key];
}

#pragma mark - Updating the table view

- (void)beginUpdates {
	[self.parent beginUpdates];
}

- (void)performUpdate:(DCTDataSourceUpdate *)update {

	NSIndexPath *oldIndexPath = update.oldIndexPath ? [self.parent convertIndexPath:update.oldIndexPath fromChildDataSource:self] : nil;
	NSIndexPath *newIndexPath = update.newIndexPath ? [self.parent convertIndexPath:update.newIndexPath fromChildDataSource:self] : nil;
	
	DCTDataSourceUpdate *parentUpdate = [[DCTDataSourceUpdate alloc] initWithType:update.type oldIndexPath:oldIndexPath newIndexPath:newIndexPath];
	[self.parent performUpdate:parentUpdate];
}

- (void)endUpdates {
	[self.parent endUpdates];
}

- (void)enumerateIndexPathsUsingBlock:(void(^)(NSIndexPath *, BOOL *stop))enumerator {

	NSInteger sectionCount = [self numberOfSections];

	for (NSInteger section = 0; section < sectionCount; section++) {

		NSInteger itemCount = [self numberOfItemsInSection:section];

		for (NSInteger item = 0; item < itemCount; item++) {
			NSIndexPath *indexPath = [NSIndexPath dctDataSource_indexPathForRow:item inSection:section];
			BOOL stop = NO;
			enumerator(indexPath, &stop);
			if (stop) return;
		}
	}
}

@end
