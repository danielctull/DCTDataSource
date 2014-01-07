/*
 DCTCollapsableSectionTableViewDataSource.m
 DCTTableViewDataSources
 
 Created by Daniel Tull on 30.06.2011.
 
 
 
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

#import "DCTCollapsableDataSource.h"
#import "DCTTableViewDataSources.h"
#import "UITableView+DCTTableViewDataSources.h"
#import "_DCTCollapsableSectionTableViewDataSourceHeaderTableViewCell.h"
@import QuartzCore;

@implementation DCTCollapsableSectionTableViewDataSourceHeader {
	__strong NSString *title;
	BOOL open;
	BOOL empty;
}
@synthesize title;
@synthesize open;
@synthesize empty;
- (id)initWithTitle:(NSString *)aTitle open:(BOOL)isOpen empty:(BOOL)isEmpty {
	
	if (!(self = [super init])) return nil;
	
	title = [aTitle copy];
	open = isOpen;
	empty = isEmpty;
	
	return self;
}
@end



@interface DCTCollapsableDataSource ()

- (IBAction)dctInternal_titleTapped:(UITapGestureRecognizer *)sender;
- (void)dctInternal_setOpened;
- (void)dctInternal_setClosed;

- (void)dctInternal_headerCheck;
- (BOOL)dctInternal_childDataSourceCurrentlyHasCells;

- (void)dctInternal_setSplitChild:(DCTDataSource *)dataSource;

@property (nonatomic, readonly) NSIndexPath *dctInternal_headerTableViewIndexPath;
@property (nonatomic, readonly) UITableViewCell *dctInternal_headerCell;

@end

@implementation DCTCollapsableSectionTableViewDataSource {
	BOOL childDataSourceHasCells;
	BOOL canReloadHeaderCell;
	
	BOOL tableViewHasLoaded;
	
	__strong DCTSplitDataSource *splitDataSource;
	__strong DCTObjectDataSource *headerDataSource;
}

@synthesize childDataSource;
@synthesize title;
@synthesize open;

#pragma mark - NSObject

- (id)initWithChildDataSource:(DCTDataSource *)dataSource {
	self = [self init];
	if (!self) return nil;
	_childDataSource = dataSource;
	return self;
}

- (id)init {
	self = [super init];
	if (!self) return nil;
	
	splitDataSource = [[DCTSplitDataSource alloc] init];
	splitDataSource.type = DCTSplitDataSourceTypeRow;
	splitDataSource.parent = self;
	
	headerDataSource = [[DCTObjectDataSource alloc] init];
	headerDataSource.cellReuseIdentifierHandler = ^(NSIndexPath *indexPath, id object) {
		return @"DCTCollapsableSectionTableViewDataSourceHeaderTableViewCell";
	};
	
	[splitDataSource addChildDataSource:headerDataSource];
	
	return self;
}

#pragma mark - DCTCollapsableSectionTableViewDataSource

- (DCTDataSource *)childDataSource {
	
	if (!childDataSource)
		[self loadChildDataSource];
	
	return childDataSource;	
}

- (void)setChildDataSource:(DCTDataSource *)ds {
	
	if (childDataSource == ds) return;
	
	childDataSource = ds;
	
	if (self.open && ds)
		[self dctInternal_setSplitChild:ds];
	else {
		ds.parent = self; // This makes it ask us if it should update, to which we'll respond no when it's not showing.
		ds.tableView = nil;
	}
	[self dctInternal_headerCheck];
}

- (void)loadChildDataSource {}

#pragma mark - DCTTableViewDataSource

- (void)setTableView:(UITableView *)tableView {
	[super setTableView:tableView];
	[tableView registerClass:[_DCTCollapsableSectionTableViewDataSourceHeaderTableViewCell class]
	  forCellReuseIdentifier:NSStringFromClass([_DCTCollapsableSectionTableViewDataSourceHeaderTableViewCell class])];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.row == 0) 
		return [[DCTCollapsableSectionTableViewDataSourceHeader alloc] initWithTitle:self.title open:self.open empty:![self dctInternal_childDataSourceCurrentlyHasCells]];
	
	return [super objectAtIndexPath:indexPath];
}


- (void)performRowUpdate:(DCTDataSourceUpdateType)update
			   indexPath:(NSIndexPath *)indexPath
			   animation:(UITableViewRowAnimation)animation {
	
	if (!self.open) [super performRowUpdate:update indexPath:indexPath animation:animation];
}

- (void)performSectionUpdate:(DCTDataSourceUpdateType)update
				sectionIndex:(NSInteger)index
				   animation:(UITableViewRowAnimation)animation {
	
	if (self.open) [super performSectionUpdate:update sectionIndex:index animation:animation];
}

#pragma mark - DCTParentTableViewDataSource

- (NSArray *)childDataSources {
	return [NSArray arrayWithObject:splitDataSource];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tv cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	self.tableView = tv;
	tableViewHasLoaded = YES;
	
	if (indexPath.row == 0)
		headerDataSource.object = [self objectAtIndexPath:indexPath];
	
	UITableViewCell *cell = [super tableView:tv cellForRowAtIndexPath:indexPath];
	
	if (indexPath.row == 0) {
		
		UITapGestureRecognizer *gr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dctInternal_titleTapped:)]; 
		[cell addGestureRecognizer:gr];
		gr.delaysTouchesBegan = NO;
		gr.delaysTouchesEnded = NO;
		
		if ([self dctInternal_childDataSourceCurrentlyHasCells]) {
			
			NSString *disclosurePath = [[DCTTableViewDataSources bundle] pathForResource:@"DisclosureIndicator" ofType:@"png"];
			NSString *highlightedDisclosurePath = [[DCTTableViewDataSources bundle] pathForResource:@"DisclosureIndicatorHighlighted" ofType:@"png"];
			
			UIImage *image = [UIImage imageWithContentsOfFile:disclosurePath];
			UIImageView *iv = [[UIImageView alloc] initWithImage:image];
			iv.highlightedImage = [UIImage imageWithContentsOfFile:highlightedDisclosurePath];
			cell.accessoryView = iv;
			cell.accessoryView.layer.transform = CATransform3DMakeRotation(self.open ? (CGFloat)M_PI : 0.0f, 0.0f, 0.0f, 1.0f);
		} else {
			cell.accessoryView = nil;
			cell.accessoryType = UITableViewCellAccessoryNone;
		}	
	}
	
	return cell;
}

#pragma mark - Internal

- (IBAction)dctInternal_titleTapped:(UITapGestureRecognizer *)sender {
	self.open = !self.open;
}

- (void)dctInternal_setSplitChild:(DCTDataSource *)dataSource {
	NSArray *children = splitDataSource.childDataSources;
	if ([children count] > 1) [splitDataSource removeChildDataSource:[children lastObject]];
	
	[splitDataSource addChildDataSource:self.childDataSource];
}

- (void)dctInternal_setOpened {
	
	[self dctInternal_setSplitChild:self.childDataSource];
	
	if (!tableViewHasLoaded) return;
	
	UITableView *tv = self.tableView;
	
	__block CGFloat totalCellHeight = self.dctInternal_headerCell.bounds.size.height;
	CGFloat tableViewHeight = tv.bounds.size.height;
	
	// If it's grouped we need room for the space between sections.
	if (tv.style == UITableViewStyleGrouped)
		tableViewHeight -= 20.0f;
	
	id<UITableViewDelegate> delegate = tv.delegate;
	CGFloat rowHeight = tv.rowHeight;
	
	NSMutableArray *tableViewIndexPaths = [NSMutableArray new];
	
	[self.childDataSource enumerateIndexPathsUsingBlock:^(NSIndexPath *indexPath, BOOL *stop) {
		
		CGFloat height = rowHeight;
		
		if ([delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
			indexPath = [self.tableView dct_convertIndexPath:indexPath fromChildDataSource:self.childDataSource];
			height = [delegate tableView:tv heightForRowAtIndexPath:indexPath];
		}
		
		[tableViewIndexPaths addObject:indexPath];
		totalCellHeight += height;
		
		if (totalCellHeight > tableViewHeight)
			*stop = YES;
	}];
	
	if ([tableViewIndexPaths count] == 0) return;
	
	NSIndexPath *headerIndexPath = self.dctInternal_headerTableViewIndexPath;
	
	if (totalCellHeight < tableViewHeight) {
		[self.tableView scrollToRowAtIndexPath:[tableViewIndexPaths lastObject] atScrollPosition:UITableViewScrollPositionNone animated:YES];
		[self.tableView scrollToRowAtIndexPath:headerIndexPath atScrollPosition:UITableViewScrollPositionNone animated:YES];
	} else {
		[self.tableView scrollToRowAtIndexPath:headerIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
	}
}

- (void)dctInternal_setClosed {
	
	NSArray *children = splitDataSource.childDataSources;
	if ([children count] == 1) return;
	
	[splitDataSource removeChildDataSource:self.childDataSource];
	self.childDataSource.parent = self; // This makes it ask us if it should update, to which we'll respond no when it's not showing.
	self.childDataSource.tableView = nil;
	
	[self.tableView scrollToRowAtIndexPath:self.dctInternal_headerTableViewIndexPath
						  atScrollPosition:UITableViewScrollPositionNone
								  animated:YES];
}

- (void)setOpen:(BOOL)aBool {
	
	if (open == aBool) return;
	
	open = aBool;
	
	if (aBool)
		[self dctInternal_setOpened];
	else 
		[self dctInternal_setClosed];
	
	UIView *accessoryView = self.dctInternal_headerCell.accessoryView;
	
	if (!accessoryView) return;
	
	[UIView beginAnimations:@"some" context:nil];
	[UIView setAnimationDuration:0.33];
	accessoryView.layer.transform = CATransform3DMakeRotation(aBool ? (CGFloat)M_PI : 0.0f, 0.0f, 0.0f, 1.0f);
	[UIView commitAnimations];
}

- (void)setTitleCellReuseIdentifier:(NSString *)titleCellReuseIdentifier {
	
	if ([titleCellReuseIdentifier isEqualToString:_titleCellReuseIdentifier]) return;
	
	NSString *titleCellReuseIdentifierCopy = [titleCellReuseIdentifier copy];
	_titleCellReuseIdentifier = titleCellReuseIdentifierCopy;
	headerDataSource.cellReuseIdentifierHandler = ^(NSIndexPath *indexPath, id object) {
		return titleCellReuseIdentifierCopy;
	};
}

- (void)dctInternal_headerCheck {
	
	if (!canReloadHeaderCell) return;
	
	if (childDataSourceHasCells == [self dctInternal_childDataSourceCurrentlyHasCells]) return;
	
	childDataSourceHasCells = !childDataSourceHasCells;
	
	NSIndexPath *headerIndexPath = self.dctInternal_headerTableViewIndexPath;
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:headerIndexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (BOOL)dctInternal_childDataSourceCurrentlyHasCells {
	return ([self.childDataSource tableView:self.tableView numberOfRowsInSection:0] > 0);
}



#pragma mark - Header Cell

- (NSIndexPath *)dctInternal_headerTableViewIndexPath {
	NSIndexPath *headerIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	return [self.tableView dct_convertIndexPath:headerIndexPath fromChildDataSource:self];
}

- (UITableViewCell *)dctInternal_headerCell {
	return [self.tableView cellForRowAtIndexPath:self.dctInternal_headerTableViewIndexPath];
}

@end
