/*
 DCTParentTableViewDataSource.m
 DCTTableViewDataSources
 
 Created by Daniel Tull on 20.08.2011.
 
 
 
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

#import "DCTParentDataSource.h"

@implementation DCTParentDataSource

#pragma mark - DCTTableViewDataSource

- (void)reloadData {
	[self.childTableViewDataSources makeObjectsPerformSelector:@selector(reloadData)];
}

- (NSInteger)numberOfSections {
	return [[self.childDataSources firstObject] numberOfSections];
}

- (NSInteger)numberOfItemsInSection:(NSInteger)section {
	DCTDataSource * ds = [self childDataSourceForSection:section];
	section = [self convertSection:section toChildTableViewDataSource:ds];
	return [ds numberOfItemsInSection:section];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
	DCTDataSource * ds = [self childDataSourceForIndexPath:indexPath];
	indexPath = [self convertIndexPath:indexPath toChildTableViewDataSource:ds];
	return [ds objectAtIndexPath:indexPath];
}

- (id)userInfoValueForKey:(NSString *)key indexPath:(NSIndexPath *)indexPath {
	DCTDataSource *ds = [self childDataSourceForIndexPath:indexPath];
	indexPath = [self convertIndexPath:indexPath toChildTableViewDataSource:ds];
	id value = [ds userInfoValueForKey:key indexPath:indexPath];
	if (!value) value = [self userInfoValueForKey:key];
	return value;
}

#pragma mark - DCTParentTableViewDataSource

- (NSArray *)childTableViewDataSources {
	return nil;
}

- (NSIndexPath *)convertIndexPath:(NSIndexPath *)indexPath fromChildTableViewDataSource:(DCTDataSource *)dataSource {
	NSAssert([self.childDataSources containsObject:dataSource], @"dataSource should be in the childTableViewDataSources");
	return indexPath;
}

- (NSIndexPath *)convertIndexPath:(NSIndexPath *)indexPath toChildTableViewDataSource:(DCTDataSource *)dataSource {
	NSAssert([self.childDataSources containsObject:dataSource], @"dataSource should be in the childTableViewDataSources");
	return indexPath;
}

- (NSInteger)convertSection:(NSInteger)section fromChildTableViewDataSource:(DCTDataSource *)dataSource {
	NSAssert([self.childDataSources containsObject:dataSource], @"dataSource should be in the childTableViewDataSources");
	return section;
}

- (NSInteger)convertSection:(NSInteger)section toChildTableViewDataSource:(DCTDataSource *)dataSource {	
	NSAssert([self.childDataSources containsObject:dataSource], @"dataSource should be in the childTableViewDataSources");
	return section;
}

- (DCTDataSource *)childDataSourceForSection:(NSInteger)section {
	return [self.childDataSources lastObject];
}

- (DCTDataSource *)childDataSourceForIndexPath:(NSIndexPath *)indexPath {
	return [self.childDataSources lastObject];
}

@end
