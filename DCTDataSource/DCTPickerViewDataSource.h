//
//  DCTPickerViewDataSource.h
//  DCTDataSource
//
//  Created by Daniel Tull on 25.07.2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import "DCTParentDataSource.h"

@interface DCTPickerViewDataSource : DCTParentDataSource

- (id)initWithPickerView:(UIPickerView *)pickerView dataSource:(DCTDataSource *)dataSource;
@property (nonatomic, readonly) UIPickerView *pickerView;
@property (nonatomic, readonly) DCTDataSource *dataSource;

@end
