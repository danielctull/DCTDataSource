//
//  DCTTableViewDataSources.h
//  DCTTableViewDataSources
//
//  Created by Daniel Tull on 09.11.2011.
//  Copyright (c) 2011 Daniel Tull. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <Availability.h>

#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_4_3
#warning "This library uses ARC which is only available in iOS SDK 4.3 and later."
#endif

#if !defined dct_weak && __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_5_0

#define dct_weak weak
#define __dct_weak __weak
#define dct_nil(x)
#define DCTTableViewDataSourceTableViewRowAnimationAutomatic UITableViewRowAnimationAutomatic

#elif !defined dct_weak && __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_4_3

#define dct_weak unsafe_unretained
#define __dct_weak __unsafe_unretained
#define dct_nil(x) x = nil
#define DCTTableViewDataSourceTableViewRowAnimationAutomatic UITableViewRowAnimationFade

#endif


#ifndef dcttableviewdatasources
#define dcttableviewdatasources_1_0     10000
#define dcttableviewdatasources_1_0_1   10001
#define dcttableviewdatasources_1_0_2   10002
#define dcttableviewdatasources         dcttableviewdatasources_1_0_2
#endif
