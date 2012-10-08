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

#import "DCTCollapsableSectionTableViewDataSource.h"
#import "DCTTableViewDataSources.h"
#import "UITableView+DCTTableViewDataSources.h"
#import "_DCTCollapsableSectionTableViewDataSourceHeaderTableViewCell.h"
#import <QuartzCore/QuartzCore.h>

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



@interface DCTCollapsableSectionTableViewDataSource ()

- (IBAction)dctInternal_titleTapped:(UITapGestureRecognizer *)sender;
- (void)dctInternal_setOpened;
- (void)dctInternal_setClosed;

- (void)dctInternal_headerCheck;
- (BOOL)dctInternal_childTableViewDataSourceCurrentlyHasCells;

- (void)dctInternal_setSplitChild:(DCTTableViewDataSource *)dataSource;

@property (nonatomic, readonly) NSIndexPath *dctInternal_headerTableViewIndexPath;
@property (nonatomic, readonly) UITableViewCell *dctInternal_headerCell;

@end

@implementation DCTCollapsableSectionTableViewDataSource {
	BOOL childTableViewDataSourceHasCells;
	BOOL canReloadHeaderCell;
	
	BOOL tableViewHasLoaded;
	
	__strong DCTSplitTableViewDataSource *splitDataSource;
	__strong DCTObjectTableViewDataSource *headerDataSource;
}

@synthesize childTableViewDataSource;
@synthesize title;
@synthesize open;

#pragma mark - NSObject

- (id)init {
	
	if (!(self = [super init])) return nil;
	
	splitDataSource = [[DCTSplitTableViewDataSource alloc] init];
	splitDataSource.type = DCTSplitTableViewDataSourceTypeRow;
	splitDataSource.parent = self;
	
	headerDataSource = [[DCTObjectTableViewDataSource alloc] init];
	headerDataSource.cellReuseIdentifierHandler = ^(NSIndexPath *indexPath, id object) {
		return @"DCTCollapsableSectionTableViewDataSourceHeaderTableViewCell";
	};
	
	[splitDataSource addChildTableViewDataSource:headerDataSource];
	
	return self;
}

#pragma mark - DCTCollapsableSectionTableViewDataSource

- (DCTTableViewDataSource *)childTableViewDataSource {
	
	if (!childTableViewDataSource)
		[self loadChildTableViewDataSource];
	
	return childTableViewDataSource;	
}

- (void)setChildTableViewDataSource:(DCTTableViewDataSource *)ds {
	
	if (childTableViewDataSource == ds) return;
	
	childTableViewDataSource = ds;
	
	if (self.open && ds)
		[self dctInternal_setSplitChild:ds];
	else {
		ds.parent = self; // This makes it ask us if it should update, to which we'll respond no when it's not showing.
		ds.tableView = nil;
	}
	[self dctInternal_headerCheck];
}

- (void)loadChildTableViewDataSource {}

#pragma mark - DCTTableViewDataSource

- (void)setTableView:(UITableView *)tableView {
	[super setTableView:tableView];
	[tableView registerClass:[_DCTCollapsableSectionTableViewDataSourceHeaderTableViewCell class]
	  forCellReuseIdentifier:NSStringFromClass([_DCTCollapsableSectionTableViewDataSourceHeaderTableViewCell class])];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath {
	
	if (indexPath.row == 0) 
		return [[DCTCollapsableSectionTableViewDataSourceHeader alloc] initWithTitle:self.title open:self.open empty:![self dctInternal_childTableViewDataSourceCurrentlyHasCells]];
	
	return [super objectAtIndexPath:indexPath];
}


- (void)performRowUpdate:(DCTTableViewDataSourceUpdateType)update
			   indexPath:(NSIndexPath *)indexPath
			   animation:(UITableViewRowAnimation)animation {
	
	if (!self.open) [super performRowUpdate:update indexPath:indexPath animation:animation];
}

- (void)performSectionUpdate:(DCTTableViewDataSourceUpdateType)update
				sectionIndex:(NSInteger)index
				   animation:(UITableViewRowAnimation)animation {
	
	if (self.open) [super performSectionUpdate:update sectionIndex:index animation:animation];
}

#pragma mark - DCTParentTableViewDataSource

- (NSArray *)childTableViewDataSources {
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
		
		if ([self dctInternal_childTableViewDataSourceCurrentlyHasCells]) {
			
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

- (void)dctInternal_setSplitChild:(DCTTableViewDataSource *)dataSource {
	NSArray *children = splitDataSource.childTableViewDataSources;
	if ([children count] > 1) [splitDataSource removeChildTableViewDataSource:[children lastObject]];
	
	[splitDataSource addChildTableViewDataSource:self.childTableViewDataSource];
}

- (void)dctInternal_setOpened {
	
	[self dctInternal_setSplitChild:self.childTableViewDataSource];
	
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
	
	[self.childTableViewDataSource enumerateIndexPathsUsingBlock:^(NSIndexPath *indexPath, BOOL *stop) {
		
		CGFloat height = rowHeight;
		
		if ([delegate respondsToSelector:@selector(tableView:heightForRowAtIndexPath:)]) {
			indexPath = [self.tableView dct_convertIndexPath:indexPath fromChildTableViewDataSource:self.childTableViewDataSource];
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
	
	NSArray *children = splitDataSource.childTableViewDataSources;
	if ([children count] == 1) return;
	
	[splitDataSource removeChildTableViewDataSource:self.childTableViewDataSource];
	self.childTableViewDataSource.parent = self; // This makes it ask us if it should update, to which we'll respond no when it's not showing.
	self.childTableViewDataSource.tableView = nil;
	
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
	
	if (childTableViewDataSourceHasCells == [self dctInternal_childTableViewDataSourceCurrentlyHasCells]) return;
	
	childTableViewDataSourceHasCells = !childTableViewDataSourceHasCells;
	
	NSIndexPath *headerIndexPath = self.dctInternal_headerTableViewIndexPath;
	[self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:headerIndexPath] withRowAnimation:UITableViewRowAnimationFade];
}

- (BOOL)dctInternal_childTableViewDataSourceCurrentlyHasCells {
	return ([self.childTableViewDataSource tableView:self.tableView numberOfRowsInSection:0] > 0);
}



#pragma mark - Header Cell

- (NSIndexPath *)dctInternal_headerTableViewIndexPath {
	NSIndexPath *headerIndexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	return [self.tableView dct_convertIndexPath:headerIndexPath fromChildTableViewDataSource:self];
}

- (UITableViewCell *)dctInternal_headerCell {
	return [self.tableView cellForRowAtIndexPath:self.dctInternal_headerTableViewIndexPath];
}

@end
