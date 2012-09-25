//
//  UITableView+DCTNibRegistration.m
//  DCTTableViewDataSources
//
//  Created by Daniel Tull on 28.11.2011.
//  Copyright (c) 2011 Daniel Tull. All rights reserved.
//

#import "UITableView+DCTNibRegistration.h"
#import <objc/runtime.h>

@interface UITableView ()
@property (nonatomic, readonly) NSMutableDictionary *dctInternal_nibs;
@end

@implementation UITableView (DCTNibRegistration)

#pragma mark - UITableView (DCTNibRegistration)

- (id)dct_dequeueReusableCellWithIdentifier:(NSString *)identifier {
	
	id cell = nil;
	
	@try {
		cell = [self dequeueReusableCellWithIdentifier:identifier];
	}
	@finally {
		
		if (cell) return cell;
		
		UINib *nib = [self.dctInternal_nibs objectForKey:identifier];
		NSArray *items = [nib instantiateWithOwner:nil options:nil];
		
		for (id object in items)
			if ([object isKindOfClass:[UITableViewCell class]])
				return object;
		
		return nil;
	}
}

- (void)dct_registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)identifier {
	[self.dctInternal_nibs setObject:nib forKey:identifier];	
}

#pragma mark - Internal

- (NSMutableDictionary *)dctInternal_nibs {
	NSMutableDictionary *dictionary = objc_getAssociatedObject(self, _cmd);
	if (!dictionary) {
		dictionary = [[NSMutableDictionary alloc] initWithCapacity:1];
		objc_setAssociatedObject(self, _cmd, dictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return dictionary;	
}

@end
