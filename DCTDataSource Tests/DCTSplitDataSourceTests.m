//
//  DCTSplitDataSourceTests.m
//  DCTDataSource
//
//  Created by Daniel Tull on 02/02/2014.
//  Copyright (c) 2014 Daniel Tull. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "DCTTestDataSource.h"

@interface DCTSplitDataSourceTests : XCTestCase
@end

@implementation DCTSplitDataSourceTests

- (void)testInsertSection {

	DCTSplitDataSource *splitDataSource = [[DCTSplitDataSource alloc] initWithType:DCTSplitDataSourceTypeSection];
	DCTTestDataSource *testDataSource = [[DCTTestDataSource alloc] initWithDataSource:splitDataSource];

	id object = @"object";
	DCTObjectDataSource *object1DataSource = [[DCTObjectDataSource alloc] initWithObject:object];
	[splitDataSource addChildDataSource:object1DataSource];

	DCTDataSourceUpdate *update = [testDataSource.updates firstObject];

	XCTAssertNotNil(update, @"There should be an update.");

	XCTAssertEqual(update.type, DCTDataSourceUpdateTypeSectionInsert, @"update.type is %@, should be DCTDataSourceUpdateTypeSectionInsert", @(update.type));

	//XCTAssertEqual(update.section, 0, @"Section should be 0.");

	NSUInteger indexes[] = {0,0};
	NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
	id testObject = [splitDataSource objectAtIndexPath:indexPath];
	XCTAssertEqualObjects(object, testObject, @"The object coming out should be the object that went in.");

	
}

@end
