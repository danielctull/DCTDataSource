//
//  DCTPickerViewDataSource.m
//  DCTDataSource
//
//  Created by Daniel Tull on 25.07.2013.
//  Copyright (c) 2013 Daniel Tull. All rights reserved.
//

#import "DCTPickerViewDataSource.h"

@interface DCTPickerViewDataSource () <UIPickerViewDataSource>
@end

@implementation DCTPickerViewDataSource

- (id)initWithPickerView:(UIPickerView *)pickerView dataSource:(DCTDataSource *)dataSource {
	self = [self init];
	if (!self) return nil;
	_pickerView = pickerView;
	_dataSource = dataSource;
	pickerView.dataSource = self;
	return self;
}

- (void)performUpdate:(DCTDataSourceUpdate *)update {
	[self.pickerView reloadComponent:update.section];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return [self numberOfSections];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
	return [self numberOfItemsInSection:component];
}

@end
