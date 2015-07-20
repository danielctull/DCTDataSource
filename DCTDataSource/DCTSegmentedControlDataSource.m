
#import "DCTSegmentedControlDataSource.h"

@interface DCTSegmentedControlDataSource ()
@property (nonatomic) id selectedObject;
@end

@implementation DCTSegmentedControlDataSource


- (void)dealloc {
	[_segmentedControl removeTarget:self action:@selector(selectionDidChange:) forControlEvents:UIControlEventValueChanged];
}

- (id)initWithSegmentedControl:(UISegmentedControl *)segmentedControl dataSource:(DCTDataSource *)dataSource {
	self = [super init];
	if (!self) return nil;
	_segmentedControl = segmentedControl;
	_dataSource = dataSource;
	_dataSource.parent = self;
	[_segmentedControl removeAllSegments];
	[_segmentedControl addTarget:self action:@selector(selectionDidChange:) forControlEvents:UIControlEventValueChanged];
	[self reloadData];
	return self;
}

- (void)setDelegate:(id<DCTSegmentedControlDataSourceDelegate>)delegate {
	_delegate = delegate;
	[self reloadData];
}

- (NSArray *)childDataSources {
	return @[self.dataSource];
}

- (void)selectionDidChange:(id)sender {
	NSIndexPath *indexPath = self.selectedIndexPath;
	self.selectedObject = indexPath	? [self objectAtIndexPath:indexPath] : nil;
}

- (NSIndexPath *)selectedIndexPath {

	NSInteger selectedSegmentIndex = self.segmentedControl.selectedSegmentIndex;
	if (selectedSegmentIndex == UISegmentedControlNoSegment) {
		return nil;
	}

	return [NSIndexPath indexPathForItem:selectedSegmentIndex inSection:0];
}

- (void)reloadData {
	[self.segmentedControl removeAllSegments];

	NSInteger numberOfItems = [self numberOfItemsInSection:0];
	for (NSInteger item = 0; item < numberOfItems; item++) {
		NSIndexPath *indexPath = [NSIndexPath indexPathForItem:item inSection:0];

		UIImage *image = [self imageForIndexPath:indexPath];
		if (image) {
			[self.segmentedControl insertSegmentWithImage:image atIndex:indexPath.item animated:NO];
			continue;
		}

		NSString *title = [self titleForIndexPath:indexPath];
		if (title) {
			[self.segmentedControl insertSegmentWithTitle:title atIndex:indexPath.item animated:NO];
			continue;
		}

		// We're out of sync so remove all the segments and bail.
		[self.segmentedControl removeAllSegments];
		return;
	}

	BOOL (^selectIndexPath)(NSIndexPath *)  = ^(NSIndexPath *indexPath) {
		if (indexPath) {
			NSUInteger segment = indexPath.item;
			if (self.segmentedControl.numberOfSegments > segment) {
				self.segmentedControl.selectedSegmentIndex = segment;
				return YES;
			}
		}

		return NO;
	};

	if (self.selectedObject) {
		NSIndexPath *indexPath = [self indexPathOfObject:self.selectedObject];
		selectIndexPath(indexPath);
	} else {
		NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
		if (selectIndexPath(indexPath)) {
			[self.segmentedControl sendActionsForControlEvents:UIControlEventValueChanged];
		}
	}

	if ([self.delegate respondsToSelector:@selector(numberOfItemsDidChangeInSegmentedControlDataSource:)]) {
		[self.delegate numberOfItemsDidChangeInSegmentedControlDataSource:self];
	}
}

- (void)performUpdate:(DCTDataSourceUpdate *)update {
	[self reloadData];
}

- (NSString *)titleForIndexPath:(NSIndexPath *)indexPath {
	if ([self.delegate respondsToSelector:@selector(segmentedControlDataSource:titleForItemAtIndexPath:)]) {
		return [self.delegate segmentedControlDataSource:self titleForItemAtIndexPath:indexPath];
	}

	return nil;
}

- (UIImage *)imageForIndexPath:(NSIndexPath *)indexPath {
	if ([self.delegate respondsToSelector:@selector(segmentedControlDataSource:imageForItemAtIndexPath:)]) {
		return [self.delegate segmentedControlDataSource:self imageForItemAtIndexPath:indexPath];
	}

	return nil;
}

@end
