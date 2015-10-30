
@import Foundation;
#import "DCTParentDataSource.h"

@interface DCTTransitionDataSource : DCTParentDataSource

- (void)setChildDataSource:(DCTDataSource *)childDataSource animated:(BOOL)animated;
@property (nonatomic) DCTDataSource *childDataSource;

@end
