
@import UIKit;
#import "DCTParentDataSource.h"

@protocol DCTSegmentedControlDataSourceDelegate;

@interface DCTSegmentedControlDataSource : DCTParentDataSource

- (id)initWithSegmentedControl:(UISegmentedControl *)segmentedControl dataSource:(DCTDataSource *)dataSource;
@property (nonatomic, readonly) UISegmentedControl *segmentedControl;
@property (nonatomic, readonly) DCTDataSource *dataSource;
@property (nonatomic) id<DCTSegmentedControlDataSourceDelegate> delegate;

@property (nonatomic, readonly) NSIndexPath *selectedIndexPath;

@end



@protocol DCTSegmentedControlDataSourceDelegate <NSObject>

@optional

- (NSString *)segmentedControlDataSource:(DCTSegmentedControlDataSource *)segmentedControlDataSource
				 titleForItemAtIndexPath:(NSIndexPath *)indexPath;

- (UIImage *)segmentedControlDataSource:(DCTSegmentedControlDataSource *)segmentedControlDataSource
				imageForItemAtIndexPath:(NSIndexPath *)indexPath;

- (void)numberOfItemsDidChangeInSegmentedControlDataSource:(DCTSegmentedControlDataSource *)segmentedControlDataSource;

@end
