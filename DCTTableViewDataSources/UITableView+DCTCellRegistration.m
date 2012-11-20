//
//  UITableView+DCTCellRegistration.m
//  DCTTableViewDataSources
//
//  Created by Daniel Tull on 28.11.2011.
//  Copyright (c) 2011 Daniel Tull. All rights reserved.
//

#import "UITableView+DCTCellRegistration.h"
#import <objc/runtime.h>

@implementation UITableView (DCTCellRegistration)

#pragma mark - UITableView (DCTNibRegistration)

- (id)dct_dequeueReusableCellWithIdentifier:(NSString *)identifier {
	
	id cell = nil;
	
	@try {
		cell = [self dequeueReusableCellWithIdentifier:identifier];
	}
	@finally {
		
		if (cell) return cell;
		
		UINib *nib = [self.dct_nibs objectForKey:identifier];
		if (nib) {
			NSArray *items = [nib instantiateWithOwner:nil options:nil];
		
			for (id object in items)
				if ([object isKindOfClass:[UITableViewCell class]])
					return object;
		}

		NSString *cellClassString = [self.dct_classes objectForKey:identifier];
		if (cellClassString) {
			Class cellClass = NSClassFromString(cellClassString);
			UITableViewCell *cell = [[cellClass alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
			if (cell) return cell;
		}

		return [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
	}
}

- (void)dct_registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)identifier {
	[self.dct_nibs setObject:nib forKey:identifier];	
}

- (void)dct_registerClass:(Class)cellClass forCellReuseIdentifier:(NSString *)identifier {
	[self.dct_classes setObject:NSStringFromClass(cellClass) forKey:identifier];
}

#pragma mark - Internal

- (NSMutableDictionary *)dct_classes {
	NSMutableDictionary *dictionary = objc_getAssociatedObject(self, _cmd);
	if (!dictionary) {
		dictionary = [[NSMutableDictionary alloc] initWithCapacity:1];
		objc_setAssociatedObject(self, _cmd, dictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return dictionary;
}

- (NSMutableDictionary *)dct_nibs {
	NSMutableDictionary *dictionary = objc_getAssociatedObject(self, _cmd);
	if (!dictionary) {
		dictionary = [[NSMutableDictionary alloc] initWithCapacity:1];
		objc_setAssociatedObject(self, _cmd, dictionary, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
	}
	return dictionary;	
}

@end
