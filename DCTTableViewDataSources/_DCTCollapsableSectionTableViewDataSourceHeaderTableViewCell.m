//
//  _DCTCollapsableSectionTableViewDataSourceHeaderTableViewCell.m
//  DCTTableViewDataSources
//
//  Created by Daniel Tull on 08.10.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "_DCTCollapsableSectionTableViewDataSourceHeaderTableViewCell.h"
#import "DCTCollapsableSectionTableViewDataSource.h"

@implementation _DCTCollapsableSectionTableViewDataSourceHeaderTableViewCell

- (void)configureWithObject:(DCTCollapsableSectionTableViewDataSourceHeader *)object {
	
	self.textLabel.text = object.title;
	
	if (object.empty) {
		self.textLabel.textColor = [UIColor lightGrayColor];
		self.selectionStyle = UITableViewCellSelectionStyleNone;
	} else {
		self.textLabel.textColor = [UIColor blackColor];
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
}

@end
