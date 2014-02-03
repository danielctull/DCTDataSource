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
	event.date = [NSDate new];
	[managedObjectContext save:NULL];

	XCTAssertEqual(testDataSource.updates.count, (NSUInteger)1, @"%@", testDataSource.updates);
	DCTDataSourceUpdate *update = [testDataSource.updates lastObject];
	[testDataSource clearUpdates];

	XCTAssertNotNil(update, @"There should be an update.");
	XCTAssertEqual(update.type, DCTDataSourceUpdateTypeSectionInsert, @"%@", update);
	XCTAssertEqual(update.section, (NSInteger)0, @"%@", update);

	NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:0];
	id testObject = [fetchedResultsDataSource objectAtIndexPath:indexPath];
	XCTAssertEqualObjects(event, testObject, @"%@ != %@", event, testObject);



	Event *event2 = [Event insertInManagedObjectContext:managedObjectContext];
	event2.name = @"B";
	event2.date = [NSDate new];
	[managedObjectContext save:NULL];

	XCTAssertEqual(testDataSource.updates.count, (NSUInteger)1, @"%@", testDataSource.updates);
	DCTDataSourceUpdate *update2 = [testDataSource.updates lastObject];
	[testDataSource clearUpdates];

	XCTAssertNotNil(update2, @"There should be an update.");
	XCTAssertEqual(update2.type, DCTDataSourceUpdateTypeItemInsert, @"%@", update2);
	XCTAssertEqual(update2.newIndexPath.section, (NSInteger)0, @"%@", update2);
	XCTAssertEqual(update2.newIndexPath.item, (NSInteger)1, @"%@", update2);

	NSIndexPath *indexPath2 = [NSIndexPath indexPathForItem:1 inSection:0];
	id testObject2 = [fetchedResultsDataSource objectAtIndexPath:indexPath2];
	XCTAssertEqualObjects(event2, testObject2, @"%@ != %@", event2, testObject2);

	event.name = @"C";
	[managedObjectContext save:NULL];

	XCTAssertEqual(testDataSource.updates.count, (NSUInteger)2, @"%@", testDataSource.updates);
	DCTDataSourceUpdate *insertNewSectionUpdate = testDataSource.updates[0];
	DCTDataSourceUpdate *deleteOldIndexPathUpdate = testDataSource.updates[1];
	[testDataSource clearUpdates];

	XCTAssertEqual(insertNewSectionUpdate.type, DCTDataSourceUpdateTypeSectionInsert, @"%@", insertNewSectionUpdate);
	XCTAssertEqual(insertNewSectionUpdate.section, (NSInteger)1, @"%@", insertNewSectionUpdate);

	XCTAssertEqual(deleteOldIndexPathUpdate.type, DCTDataSourceUpdateTypeItemDelete, @"%@", deleteOldIndexPathUpdate);
	XCTAssertEqual(deleteOldIndexPathUpdate.newIndexPath.section, (NSInteger)0, @"%@", deleteOldIndexPathUpdate);
	XCTAssertEqual(deleteOldIndexPathUpdate.newIndexPath.item, (NSInteger)0, @"%@", deleteOldIndexPathUpdate);

	NSIndexPath *movedIndexPath = [NSIndexPath indexPathForItem:0 inSection:1];
	id testObject3 = [fetchedResultsDataSource objectAtIndexPath:movedIndexPath];
	XCTAssertEqualObjects(event, testObject3, @"%@ != %@", event, testObject3);
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
