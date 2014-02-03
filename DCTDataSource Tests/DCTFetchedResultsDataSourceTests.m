//
//  DCTFetchedResultsDataSourceTests.m
//  DCTDataSource
//
//  Created by Daniel Tull on 03.02.2014.
//  Copyright (c) 2014 Daniel Tull. All rights reserved.
//

@import XCTest;
@import CoreData;
#import "DCTTestDataSource.h"
#import "Event.h"


@interface DCTFetchedResultsDataSourceTests : XCTestCase
@end

@implementation DCTFetchedResultsDataSourceTests

- (void)testSectionInsert {

	NSFetchedResultsController *fetchedResultsController = [self newFetchedResultsController];
	NSManagedObjectContext *managedObjectContext = fetchedResultsController.managedObjectContext;
	DCTFetchedResultsDataSource *fetchedResultsDataSource = [[DCTFetchedResultsDataSource alloc] initWithFetchedResultsController:fetchedResultsController];
	DCTTestDataSource *testDataSource = [[DCTTestDataSource alloc] initWithDataSource:fetchedResultsDataSource];

	Event *event = [Event insertInManagedObjectContext:managedObjectContext];
	event.name = @"B";
	[managedObjectContext save:NULL];


	DCTDataSourceUpdate *update = [testDataSource.updates firstObject];
	XCTAssertNotNil(update, @"There should be an update.");
	XCTAssertEqual(testDataSource.updates.count, 1, @"udates contains: %@", testDataSource.updates);


	XCTAssertEqual(update.type, DCTDataSourceUpdateTypeSectionInsert, @"update.type is %@, should be DCTDataSourceUpdateTypeSectionInsert", @(update.type));

	//XCTAssertEqual(update.section, 0, @"Section should be 0.");

	NSUInteger indexes[] = {0,0};
	NSIndexPath *indexPath = [NSIndexPath indexPathWithIndexes:indexes length:2];
	id testObject = [fetchedResultsDataSource objectAtIndexPath:indexPath];
	XCTAssertEqualObjects(event, testObject, @"The object coming out should be the object that went in.");



}



- (NSFetchedResultsController *)newFetchedResultsController {
	NSFetchRequest *request = [[NSFetchRequest alloc] initWithEntityName:[Event entityName]];
	request.sortDescriptors = @[
		[NSSortDescriptor sortDescriptorWithKey:EventAttributes.name ascending:YES],
		[NSSortDescriptor sortDescriptorWithKey:EventAttributes.date ascending:YES]
	];
	return  [[NSFetchedResultsController alloc] initWithFetchRequest:request
												managedObjectContext:[self newContext]
												  sectionNameKeyPath:EventAttributes.name
														   cacheName:nil];
}


- (NSManagedObjectContext *)newContext {
	NSBundle *bundle = [NSBundle bundleForClass:[self class]];
	NSURL *URL = [bundle URLForResource:@"TestModel" withExtension:@"momd"];
	NSManagedObjectModel *managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:URL];
	NSPersistentStoreCoordinator *persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel];
	[persistentStoreCoordinator addPersistentStoreWithType:NSInMemoryStoreType
											 configuration:nil
													   URL:nil
												   options:nil
													 error:NULL];

	NSManagedObjectContext *context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
	context.persistentStoreCoordinator = persistentStoreCoordinator;
	return context;
}



@end
