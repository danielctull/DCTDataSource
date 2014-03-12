//
//  DCTPickerViewDataSource.h
//  DCTDataSource
//
//  Created by Daniel Tull on 25.07.2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

@import UIKit;
#import "DCTParentDataSource.h"

/**
 *  A class to adapt a DCTDataSource to a UIPickerView.
 */
@interface DCTPickerViewDataSource : DCTParentDataSource <UIPickerViewDataSource>

- (id)initWithPickerView:(UIPickerView *)pickerView dataSource:(DCTDataSource *)dataSource;
@property (nonatomic, readonly) UIPickerView *pickerView;
@property (nonatomic, readonly) DCTDataSource *dataSource;

@end
