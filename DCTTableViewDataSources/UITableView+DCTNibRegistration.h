//
//  UITableView+DCTNibRegistration.h
//  DCTTableViewDataSources
//
//  Created by Daniel Tull on 28.11.2011.
//  Copyright (c) 2011 Daniel Tull. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (DCTNibRegistration)

/// @name Nib Registration

/** Dequeues a cell.
 
 This will initially try to dequeue a cell with dequeueReusableCellWithIdentifier:
 and failing that will try to load from its internally registered nibs.
 
 @param identifier The reuse identifier.
 
 @see dct_registerNib:forCellReuseIdentifier:
 */
- (id)dct_dequeueReusableCellWithIdentifier:(NSString *)identifier;

/** Registers a nib for the given resuse identifier.
 
 This uses the iOS 5 method registerNib:forCellReuseIdentifier: when running on 
 iOS 5 and uses a custom registration method when running on iOS 4.
 
 @param nib The nib for the cell.
 @param identifier The reuse identifier.
 
 @see dct_dequeueReusableCellWithIdentifier:
 */
- (void)dct_registerNib:(UINib *)nib forCellReuseIdentifier:(NSString *)identifier;

@end
