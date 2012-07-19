//
//  DCTTableViewDataSources.m
//  DCTTableViewDataSources
//
//  Created by Daniel Tull on 19.07.2012.
//  Copyright (c) 2012 Daniel Tull. All rights reserved.
//

#import "DCTTableViewDataSources.h"

static NSBundle *_bundle = nil;

@implementation DCTTableViewDataSources

+ (NSBundle *)bundle {
	
	static dispatch_once_t bundleToken;
	dispatch_once(&bundleToken, ^{
		NSDirectoryEnumerator *enumerator = [[NSFileManager new] enumeratorAtURL:[[NSBundle mainBundle] bundleURL]
													  includingPropertiesForKeys:nil
																		 options:NSDirectoryEnumerationSkipsHiddenFiles
																	errorHandler:NULL];
		
		for (NSURL *URL in enumerator)
			if ([[URL lastPathComponent] isEqualToString:@"Fourgy.bundle"])
				_bundle = [NSBundle bundleWithURL:URL];
	});
	
	return _bundle;
}

@end
