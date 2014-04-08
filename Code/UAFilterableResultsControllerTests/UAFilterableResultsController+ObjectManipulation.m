//
//  UAFilterableResultsController+ObjectManipulation.m
//  Kestrel
//
//  Created by Rob Amos on 21/10/2013.
//  Copyright (c) 2013 Desto. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "UAFilterableResultsController.h"

SPEC_BEGIN(UAFilterableResultsController_ObjectManipulation)

describe(@"UAFilterableResultsController: Object Manipulation", ^
{
    context(@"when testing one dimensional arrays of numeric data", ^{

        __block UAFilterableResultsController *controller;
        beforeEach(^{

            controller = [[UAFilterableResultsController alloc] initWithPrimaryKeyPath:nil delegate:nil];
            [controller setData:@[ @1, @2, @3, @4 ]];
        });
        afterEach(^{

            controller = nil;
        });

        it(@"should add a single object using -addObject:", ^{

            // verify current state
            [[controller.data should] haveCountOf:4];
            
            // add the object
            [controller addObject:@5];
            
            // verify the new data
            [[controller.data should] haveCountOf:5];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]] should] equal:@5];
            
            NSIndexPath *indexPath = [controller indexPathOfObject:@5];
            [[theValue(indexPath.section) should] equal:0 withDelta:0];
            [[theValue(indexPath.row) should] equal:4 withDelta:0];
        });
        
        it(@"should a single object using -addObject:inSection:", ^{

            // verify current state
            [[controller.data should] haveCountOf:4];
            
            // add objects
            [controller addObject:@5 inSection:0];

            // verify the new data
            [[controller.data should] haveCountOf:5];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]] should] equal:@5];
            
            NSIndexPath *indexPath = [controller indexPathOfObject:@5];
            [[theValue(indexPath.section) should] equal:0 withDelta:0];
            [[theValue(indexPath.row) should] equal:4 withDelta:0];
        });

        it(@"should add a remove object using -removeObject:", ^{
            
            // verify current state
            [[controller.data should] haveCountOf:4];
            
            // remove the object
            [controller removeObject:@2];
            
            // verify the new data
            [[controller.data should] haveCountOf:3];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should] equal:@1];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should] equal:@3];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] should] equal:@4];
        });
        
        it(@"should a remove object using -removeObject:atIndexPath:", ^{
            
            // verify current state
            [[controller.data should] haveCountOf:4];
            
            // remove the object
            [controller removeObjectAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            
            // verify the new data
            [[controller.data should] haveCountOf:3];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should] equal:@1];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should] equal:@3];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] should] equal:@4];
        });
        
        it(@"should replace an object using -replaceObject:withObject:", ^{

            // verify current state
            [[controller.data should] haveCountOf:4];
            
            // replace the object
            [controller replaceObject:@2 withObject:@5];
            
            // verify the new data
            [[controller.data should] haveCountOf:4];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should] equal:@1];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should] equal:@5];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] should] equal:@3];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]] should] equal:@4];
        });

        it(@"should replace an object using -replaceObjectAtIndexPath:withObject:", ^{
            
            // verify current state
            [[controller.data should] haveCountOf:4];
            
            // replace the object
            [controller replaceObjectAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] withObject:@5];
            
            // verify the new data
            [[controller.data should] haveCountOf:4];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should] equal:@1];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should] equal:@2];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] should] equal:@5];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]] should] equal:@4];
        });

        it(@"should replace objects using -replaceObjects:", ^{
            
            // verify current state
            [[controller.data should] haveCountOf:4];
            
            // replace the object
            [controller replaceObjects:@[ @2, @3 ]];
            
            // verify the new data - no changes because we're replacing a number with the same number (no primary keys)
            [[controller.data should] haveCountOf:4];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should] equal:@1];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should] equal:@2];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] should] equal:@3];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]] should] equal:@4];
        });
    });

    context(@"when testing one dimensional arrays of dictionary data", ^{
        
        __block UAFilterableResultsController *controller;
        beforeEach(^{
            
            controller = [[UAFilterableResultsController alloc] initWithPrimaryKeyPath:nil delegate:nil];
            [controller setData:@[ @{ @"id": @"1", @"firstName": @"Test", @"lastName": @"User" }, @{ @"id": @"2", @"firstName": @"John", @"lastName": @"Citizen" }, @{ @"id": @"3", @"firstName": @"Jane", @"lastName": @"Citizen" } ]];
        });
        afterEach(^{
            
            controller = nil;
        });
        
        it(@"should add a single object using -addObject:", ^{
            
            // verify current state
            [[controller.data should] haveCountOf:3];
            
            // add the object
            NSDictionary *data = @{ @"id": @"4", @"firstName": @"Another", @"lastName": @"TestUser" };
            [controller addObject:data];
            
            // verify the new data
            [[controller.data should] haveCountOf:4];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]] should] equal:data];
            
            NSIndexPath *indexPath = [controller indexPathOfObject:data];
            [[theValue(indexPath.section) should] equal:0 withDelta:0];
            [[theValue(indexPath.row) should] equal:3 withDelta:0];
        });
        
        it(@"should a single object using -addObject:inSection:", ^{
            
            // verify current state
            [[controller.data should] haveCountOf:3];
            
            // add objects
            NSDictionary *data = @{ @"id": @"4", @"firstName": @"Another", @"lastName": @"TestUser" };
            [controller addObject:data inSection:0];
            
            // verify the new data
            [[controller.data should] haveCountOf:4];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]] should] equal:data];
            
            NSIndexPath *indexPath = [controller indexPathOfObject:data];
            [[theValue(indexPath.section) should] equal:0 withDelta:0];
            [[theValue(indexPath.row) should] equal:3 withDelta:0];
        });
        
        it(@"should remove object using -removeObject:", ^{
            
            // verify current state
            [[controller.data should] haveCountOf:3];

            NSDictionary *obj1 = [controller.data objectAtIndex:0];
            NSDictionary *obj2 = [controller.data objectAtIndex:1];
            NSDictionary *obj3 = [controller.data objectAtIndex:2];

            // remove the object
            [controller removeObject:obj2];
            
            // verify the new data
            [[controller.data should] haveCountOf:2];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should] equal:obj1];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should] equal:obj3];
        });
        
        it(@"should a remove object using -removeObject:atIndexPath:", ^{
            
            // verify current state
            [[controller.data should] haveCountOf:3];
            
            NSDictionary *obj1 = [controller.data objectAtIndex:0];
            NSDictionary *obj3 = [controller.data objectAtIndex:2];
            
            // remove the object
            [controller removeObjectAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            
            // verify the new data
            [[controller.data should] haveCountOf:2];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should] equal:obj1];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should] equal:obj3];
        });
        
        it(@"should replace an object using -replaceObject:withObject:", ^{
            
            // verify current state
            [[controller.data should] haveCountOf:3];
            
            // replace the object
            NSDictionary *obj1 = [controller.data objectAtIndex:0];
            NSDictionary *obj2 = [controller.data objectAtIndex:1];
            NSDictionary *obj3 = [controller.data objectAtIndex:2];

            [controller replaceObject:obj2 withObject:obj1];

            // verify the new data
            [[controller.data should] haveCountOf:3];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should] equal:obj1];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should] equal:obj1];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] should] equal:obj3];
        });
        
        it(@"should replace an object using -replaceObjectAtIndexPath:withObject:", ^{
            
            // verify current state
            [[controller.data should] haveCountOf:3];

            NSDictionary *obj1 = [controller.data objectAtIndex:0];
            NSDictionary *obj2 = [controller.data objectAtIndex:1];

            // replace the object
            [controller replaceObjectAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] withObject:obj1];
            
            // verify the new data
            [[controller.data should] haveCountOf:3];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should] equal:obj1];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should] equal:obj2];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] should] equal:obj1];
        });
        
        it(@"should replace objects using -replaceObjects:", ^{
            
            // verify current state
            [[controller.data should] haveCountOf:3];

            NSDictionary *obj1 = [controller.data objectAtIndex:0];
            NSDictionary *obj2 = [controller.data objectAtIndex:1];
            NSDictionary *obj3 = [controller.data objectAtIndex:2];

            // replace the object
            [controller replaceObjects:@[ obj1, obj2 ]];
            
            // verify the new data - no changes because we're replacing an object with the same object (no primary keys)
            [[controller.data should] haveCountOf:3];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should] equal:obj1];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should] equal:obj2];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] should] equal:obj3];
        });
    });


    context(@"when testing two dimensional arrays of numeric data", ^{
        
        __block UAFilterableResultsController *controller;
        beforeEach(^{
            
            controller = [[UAFilterableResultsController alloc] initWithPrimaryKeyPath:nil delegate:nil];
            [controller setData:@[ @[ @1, @2, @3, @4 ], @[ @5, @6, @7, @8, @9 ]]];
        });
        afterEach(^{
            
            controller = nil;
        });
        
        it(@"should add a single object using -addObject:", ^{
            
            // verify current state
            [[[controller.data objectAtIndex:0] should] haveCountOf:4];
            [[[controller.data objectAtIndex:1] should] haveCountOf:5];
            
            // add the object
            [controller addObject:@10];
            
            // verify the new data
            [[[controller.data objectAtIndex:0] should] haveCountOf:4];
            [[[controller.data objectAtIndex:1] should] haveCountOf:6];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:1]] should] equal:@10];
            
            NSIndexPath *indexPath = [controller indexPathOfObject:@10];
            [[theValue(indexPath.section) should] equal:1 withDelta:0];
            [[theValue(indexPath.row) should] equal:5 withDelta:0];
        });
        
        it(@"should a single object using -addObject:inSection:", ^{
            
            // verify current state
            [[[controller.data objectAtIndex:0] should] haveCountOf:4];
            [[[controller.data objectAtIndex:1] should] haveCountOf:5];
            
            // add objects
            [controller addObject:@10 inSection:0];
            [controller addObject:@11 inSection:1];
            
            // verify the new data
            [[[controller.data objectAtIndex:0] should] haveCountOf:5];
            [[[controller.data objectAtIndex:1] should] haveCountOf:6];

            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]] should] equal:@10];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:1]] should] equal:@11];
            
            NSIndexPath *indexPath1 = [controller indexPathOfObject:@10];
            [[theValue(indexPath1.section) should] equal:0 withDelta:0];
            [[theValue(indexPath1.row) should] equal:4 withDelta:0];

            NSIndexPath *indexPath2 = [controller indexPathOfObject:@11];
            [[theValue(indexPath2.section) should] equal:1 withDelta:0];
            [[theValue(indexPath2.row) should] equal:5 withDelta:0];
        });
        
        it(@"should add a remove object using -removeObject:", ^{
            
            // verify current state
            [[[controller.data objectAtIndex:0] should] haveCountOf:4];
            [[[controller.data objectAtIndex:1] should] haveCountOf:5];

            // remove the object
            [controller removeObject:@2];
            [controller removeObject:@7];
            
            // verify the new data
            [[[controller.data objectAtIndex:0] should] haveCountOf:3];
            [[[controller.data objectAtIndex:1] should] haveCountOf:4];

            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should] equal:@1];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should] equal:@3];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] should] equal:@4];

            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] should] equal:@5];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]] should] equal:@6];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]] should] equal:@8];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:1]] should] equal:@9];
        });
        
        it(@"should a remove object using -removeObject:atIndexPath:", ^{
            
            // verify current state
            [[[controller.data objectAtIndex:0] should] haveCountOf:4];
            [[[controller.data objectAtIndex:1] should] haveCountOf:5];
            
            // remove the object
            [controller removeObjectAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            [controller removeObjectAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
            
            // verify the new data
            [[[controller.data objectAtIndex:0] should] haveCountOf:3];
            [[[controller.data objectAtIndex:1] should] haveCountOf:4];

            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should] equal:@1];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should] equal:@3];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] should] equal:@4];
            
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] should] equal:@5];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]] should] equal:@7];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]] should] equal:@8];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:1]] should] equal:@9];
        });
        
        it(@"should replace an object using -replaceObject:withObject:", ^{
            
            // verify current state
            [[[controller.data objectAtIndex:0] should] haveCountOf:4];
            [[[controller.data objectAtIndex:1] should] haveCountOf:5];
            
            // replace the object
            [controller replaceObject:@2 withObject:@10];
            [controller replaceObject:@7 withObject:@11];
            
            // verify the new data
            [[[controller.data objectAtIndex:0] should] haveCountOf:4];
            [[[controller.data objectAtIndex:1] should] haveCountOf:5];
            
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should] equal:@1];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should] equal:@10];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] should] equal:@3];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]] should] equal:@4];
            
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] should] equal:@5];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]] should] equal:@6];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]] should] equal:@11];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:1]] should] equal:@8];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:1]] should] equal:@9];
        });
        
        it(@"should replace an object using -replaceObjectAtIndexPath:withObject:", ^{
            
            // verify current state
            [[[controller.data objectAtIndex:0] should] haveCountOf:4];
            [[[controller.data objectAtIndex:1] should] haveCountOf:5];
            
            // replace the object
            [controller replaceObjectAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] withObject:@10];
            [controller replaceObjectAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:1] withObject:@11];
            
            // verify the new data
            [[[controller.data objectAtIndex:0] should] haveCountOf:4];
            [[[controller.data objectAtIndex:1] should] haveCountOf:5];

            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should] equal:@1];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should] equal:@2];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] should] equal:@10];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]] should] equal:@4];
            
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] should] equal:@5];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]] should] equal:@6];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]] should] equal:@7];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:1]] should] equal:@11];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:1]] should] equal:@9];
        });
        
        it(@"should replace objects using -replaceObjects:", ^{
            
            // verify current state
            [[[controller.data objectAtIndex:0] should] haveCountOf:4];
            [[[controller.data objectAtIndex:1] should] haveCountOf:5];
            
            // replace the object
            [controller replaceObjects:@[ @2, @7 ]];
            
            // verify the new data - no changes because we're replacing a number with the same number (no primary keys)
            [[[controller.data objectAtIndex:0] should] haveCountOf:4];
            [[[controller.data objectAtIndex:1] should] haveCountOf:5];

            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should] equal:@1];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should] equal:@2];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] should] equal:@3];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]] should] equal:@4];
            
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] should] equal:@5];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]] should] equal:@6];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]] should] equal:@7];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:1]] should] equal:@8];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:1]] should] equal:@9];
        });
    });
});

SPEC_END