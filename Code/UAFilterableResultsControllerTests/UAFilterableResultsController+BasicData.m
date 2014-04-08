//
//  UAFilterableResultsController+BasicData.m
//  Kestrel
//
//  Created by Rob Amos on 21/10/2013.
//  Copyright (c) 2013 Desto. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "UAFilterableResultsController.h"

SPEC_BEGIN(UAFilterableResultsController_BasicData)

describe(@"UAFilterableResultsController: Basic Data and Retrieval Setting", ^
{
    context(@"when testing one dimensional numeric data", ^{

        __block UAFilterableResultsController *controller;
        beforeEach(^{

            controller = [[UAFilterableResultsController alloc] initWithPrimaryKeyPath:nil delegate:nil];
            [controller setData:@[ @1, @2, @3, @4, @5, @6 ]];
        });
        afterEach(^{

            controller = nil;
        });
        
        
        it(@"should return it without modification.", ^{
            
            [[[[controller data] objectAtIndex:0] should] equal:@1];
            [[[[controller data] objectAtIndex:1] should] equal:@2];
            [[[[controller data] objectAtIndex:2] should] equal:@3];
            [[[[controller data] objectAtIndex:3] should] equal:@4];
            [[[[controller data] objectAtIndex:4] should] equal:@5];
            [[[[controller data] objectAtIndex:5] should] equal:@6];
        });
        
        it(@"should return the same array via -allObjects", ^
        {
            NSArray *objects = [controller allObjects];
            [[objects should] haveCountOf:6];
            [[[objects objectAtIndex:0] should] equal:@1];
            [[[objects objectAtIndex:1] should] equal:@2];
            [[[objects objectAtIndex:2] should] equal:@3];
            [[[objects objectAtIndex:3] should] equal:@4];
            [[[objects objectAtIndex:4] should] equal:@5];
            [[[objects objectAtIndex:5] should] equal:@6];
        });
        
        it(@"should return the objects via -objectAtIndexPath:", ^{

            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should] equal:@1];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should] equal:@2];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] should] equal:@3];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]] should] equal:@4];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:0]] should] equal:@5];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:0]] should] equal:@6];
        });
        
        it(@"should return the correct index paths", ^{

            NSIndexPath *indexPath1 = [controller indexPathOfObject:@1];
            [[theValue(indexPath1.section) should] equal:0 withDelta:0];
            [[theValue(indexPath1.row) should] equal:0 withDelta:0];
            
            NSIndexPath *indexPath2 = [controller indexPathOfObject:@2];
            [[theValue(indexPath2.section) should] equal:0 withDelta:0];
            [[theValue(indexPath2.row) should] equal:1 withDelta:0];
            
            NSIndexPath *indexPath3 = [controller indexPathOfObject:@3];
            [[theValue(indexPath3.section) should] equal:0 withDelta:0];
            [[theValue(indexPath3.row) should] equal:2 withDelta:0];
            
            NSIndexPath *indexPath4 = [controller indexPathOfObject:@4];
            [[theValue(indexPath4.section) should] equal:0 withDelta:0];
            [[theValue(indexPath4.row) should] equal:3 withDelta:0];
            
            NSIndexPath *indexPath5 = [controller indexPathOfObject:@5];
            [[theValue(indexPath5.section) should] equal:0 withDelta:0];
            [[theValue(indexPath5.row) should] equal:4 withDelta:0];
            
            NSIndexPath *indexPath6 = [controller indexPathOfObject:@6];
            [[theValue(indexPath6.section) should] equal:0 withDelta:0];
            [[theValue(indexPath6.row) should] equal:5 withDelta:0];
        });
    });

    context(@"when testing one dimensional dictionary data", ^{
        
        __block UAFilterableResultsController *controller;
        beforeEach(^{
            
            controller = [[UAFilterableResultsController alloc] initWithPrimaryKeyPath:nil delegate:nil];
            [controller setData:@[ @{ @"firstName": @"Test", @"lastName": @"User" }, @{ @"firstName": @"John", @"lastName": @"Citizen" }, @{ @"firstName": @"Jane", @"lastName": @"Citizen" } ]];
        });
        afterEach(^{
            
            controller = nil;
        });
    
        it(@"should return it without modification.", ^{

            NSDictionary *person1 = [[controller data] objectAtIndex:0];
            [[[person1 objectForKey:@"firstName"] should] equal:@"Test"];
            [[[person1 objectForKey:@"lastName"] should] equal:@"User"];

            NSDictionary *person2 = [[controller data] objectAtIndex:1];
            [[[person2 objectForKey:@"firstName"] should] equal:@"John"];
            [[[person2 objectForKey:@"lastName"] should] equal:@"Citizen"];

            NSDictionary *person3 = [[controller data] objectAtIndex:2];
            [[[person3 objectForKey:@"firstName"] should] equal:@"Jane"];
            [[[person3 objectForKey:@"lastName"] should] equal:@"Citizen"];
        });

        it(@"should return the same array via -allObjects.", ^{
            
            NSArray *objects = [controller allObjects];
            [[objects should] haveCountOf:3];

            NSDictionary *person1 = [objects objectAtIndex:0];
            [[[person1 objectForKey:@"firstName"] should] equal:@"Test"];
            [[[person1 objectForKey:@"lastName"] should] equal:@"User"];
            
            NSDictionary *person2 = [objects objectAtIndex:1];
            [[[person2 objectForKey:@"firstName"] should] equal:@"John"];
            [[[person2 objectForKey:@"lastName"] should] equal:@"Citizen"];
            
            NSDictionary *person3 = [objects objectAtIndex:2];
            [[[person3 objectForKey:@"firstName"] should] equal:@"Jane"];
            [[[person3 objectForKey:@"lastName"] should] equal:@"Citizen"];
        });

        it(@"should return the objects via -objectAtIndexPath:", ^{
            
            NSDictionary *person1 = [controller objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            [[[person1 objectForKey:@"firstName"] should] equal:@"Test"];
            [[[person1 objectForKey:@"lastName"] should] equal:@"User"];
            
            NSDictionary *person2 = [controller objectAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
            [[[person2 objectForKey:@"firstName"] should] equal:@"John"];
            [[[person2 objectForKey:@"lastName"] should] equal:@"Citizen"];
            
            NSDictionary *person3 = [controller objectAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
            [[[person3 objectForKey:@"firstName"] should] equal:@"Jane"];
            [[[person3 objectForKey:@"lastName"] should] equal:@"Citizen"];
        });
        
        it(@"should return the correct index paths.", ^{

            NSIndexPath *indexPath1 = [controller indexPathOfObject:[controller.data objectAtIndex:0]];
            [[theValue(indexPath1.section) should] equal:0 withDelta:0];
            [[theValue(indexPath1.row) should] equal:0 withDelta:0];
            
            NSIndexPath *indexPath2 = [controller indexPathOfObject:[controller.data objectAtIndex:1]];
            [[theValue(indexPath2.section) should] equal:0 withDelta:0];
            [[theValue(indexPath2.row) should] equal:1 withDelta:0];
            
            NSIndexPath *indexPath3 = [controller indexPathOfObject:[controller.data objectAtIndex:2]];
            [[theValue(indexPath3.section) should] equal:0 withDelta:0];
            [[theValue(indexPath3.row) should] equal:2 withDelta:0];
        });
    });

    context(@"when testing two dimensional numeric data", ^{
        
        __block UAFilterableResultsController *controller;
        beforeEach(^{
            
            controller = [[UAFilterableResultsController alloc] initWithPrimaryKeyPath:nil delegate:nil];
            [controller setData:@[ @[ @1, @2, @3, @4 ], @[ @5, @6, @7, @8, @9 ] ]];
        });
        afterEach(^{
            
            controller = nil;
        });
        
        
        it(@"should return it without modification.", ^{
            
            NSArray *array1 = [controller.data objectAtIndex:0];
            [[array1 should] haveCountOf:4];
            [[[array1 objectAtIndex:0] should] equal:@1];
            [[[array1 objectAtIndex:1] should] equal:@2];
            [[[array1 objectAtIndex:2] should] equal:@3];
            [[[array1 objectAtIndex:3] should] equal:@4];

            NSArray *array2 = [controller.data objectAtIndex:1];
            [[array2 should] haveCountOf:5];
            [[[array2 objectAtIndex:0] should] equal:@5];
            [[[array2 objectAtIndex:1] should] equal:@6];
            [[[array2 objectAtIndex:2] should] equal:@7];
            [[[array2 objectAtIndex:3] should] equal:@8];
            [[[array2 objectAtIndex:4] should] equal:@9];
        });
        
        it(@"should return the flattened array via -allObjects", ^
           {
               NSArray *objects = [controller allObjects];
               [[objects should] haveCountOf:9];
               [[[objects objectAtIndex:0] should] equal:@1];
               [[[objects objectAtIndex:1] should] equal:@2];
               [[[objects objectAtIndex:2] should] equal:@3];
               [[[objects objectAtIndex:3] should] equal:@4];
               [[[objects objectAtIndex:4] should] equal:@5];
               [[[objects objectAtIndex:5] should] equal:@6];
               [[[objects objectAtIndex:6] should] equal:@7];
               [[[objects objectAtIndex:7] should] equal:@8];
               [[[objects objectAtIndex:8] should] equal:@9];
           });
        
        it(@"should return the objects via -objectAtIndexPath:", ^{
            
            // Section 1
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should] equal:@1];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]] should] equal:@2];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] should] equal:@3];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0]] should] equal:@4];

            // Section 2
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]] should] equal:@5];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]] should] equal:@6];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]] should] equal:@7];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:1]] should] equal:@8];
            [[[controller objectAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:1]] should] equal:@9];
        });
        
        it(@"should return the correct index paths", ^{
            
            NSIndexPath *indexPath1 = [controller indexPathOfObject:@1];
            [[theValue(indexPath1.section) should] equal:0 withDelta:0];
            [[theValue(indexPath1.row) should] equal:0 withDelta:0];
            
            NSIndexPath *indexPath2 = [controller indexPathOfObject:@2];
            [[theValue(indexPath2.section) should] equal:0 withDelta:0];
            [[theValue(indexPath2.row) should] equal:1 withDelta:0];
            
            NSIndexPath *indexPath3 = [controller indexPathOfObject:@3];
            [[theValue(indexPath3.section) should] equal:0 withDelta:0];
            [[theValue(indexPath3.row) should] equal:2 withDelta:0];
            
            NSIndexPath *indexPath4 = [controller indexPathOfObject:@4];
            [[theValue(indexPath4.section) should] equal:0 withDelta:0];
            [[theValue(indexPath4.row) should] equal:3 withDelta:0];
            
            NSIndexPath *indexPath5 = [controller indexPathOfObject:@5];
            [[theValue(indexPath5.section) should] equal:1 withDelta:0];
            [[theValue(indexPath5.row) should] equal:0 withDelta:0];
            
            NSIndexPath *indexPath6 = [controller indexPathOfObject:@6];
            [[theValue(indexPath6.section) should] equal:1 withDelta:0];
            [[theValue(indexPath6.row) should] equal:1 withDelta:0];
            
            NSIndexPath *indexPath7 = [controller indexPathOfObject:@7];
            [[theValue(indexPath7.section) should] equal:1 withDelta:0];
            [[theValue(indexPath7.row) should] equal:2 withDelta:0];
            
            NSIndexPath *indexPath8 = [controller indexPathOfObject:@8];
            [[theValue(indexPath8.section) should] equal:1 withDelta:0];
            [[theValue(indexPath8.row) should] equal:3 withDelta:0];
            
            NSIndexPath *indexPath9 = [controller indexPathOfObject:@9];
            [[theValue(indexPath9.section) should] equal:1 withDelta:0];
            [[theValue(indexPath9.row) should] equal:4 withDelta:0];
        });
    });

    context(@"when testing two dimensional dictionary data", ^{
        
        __block UAFilterableResultsController *controller;
        beforeEach(^{
            
            controller = [[UAFilterableResultsController alloc] initWithPrimaryKeyPath:nil delegate:nil];
            [controller setData:@[
                                  @[ @{ @"firstName": @"Test", @"lastName": @"User" } ],
                                  @[ @{ @"firstName": @"John", @"lastName": @"Citizen" }, @{ @"firstName": @"Jane", @"lastName": @"Citizen" } ],
                                  @[ @{ @"firstName": @"Another", @"lastName": @"Tester" }, @{ @"firstName": @"NotAnother", @"lastName": @"TestUser" } ]
            ]];
        });
        afterEach(^{
            
            controller = nil;
        });
        
        it(@"should return it without modification.", ^{
            
            NSArray *array1 = [[controller data] objectAtIndex:0];
            [[array1 should] haveCountOf:1];
            
            NSDictionary *person1 = [array1 objectAtIndex:0];
            [[[person1 objectForKey:@"firstName"] should] equal:@"Test"];
            [[[person1 objectForKey:@"lastName"] should] equal:@"User"];
            
            NSArray *array2 = [[controller data] objectAtIndex:1];
            [[array2 should] haveCountOf:2];

            NSDictionary *person2 = [array2 objectAtIndex:0];
            [[[person2 objectForKey:@"firstName"] should] equal:@"John"];
            [[[person2 objectForKey:@"lastName"] should] equal:@"Citizen"];
            
            NSDictionary *person3 = [array2 objectAtIndex:1];
            [[[person3 objectForKey:@"firstName"] should] equal:@"Jane"];
            [[[person3 objectForKey:@"lastName"] should] equal:@"Citizen"];

            NSArray *array3 = [[controller data] objectAtIndex:2];
            [[array3 should] haveCountOf:2];
            
            NSDictionary *person4 = [array3 objectAtIndex:0];
            [[[person4 objectForKey:@"firstName"] should] equal:@"Another"];
            [[[person4 objectForKey:@"lastName"] should] equal:@"Tester"];
            
            NSDictionary *person5 = [array3 objectAtIndex:1];
            [[[person5 objectForKey:@"firstName"] should] equal:@"NotAnother"];
            [[[person5 objectForKey:@"lastName"] should] equal:@"TestUser"];
        });
        
        it(@"should return the flattened array via -allObjects.", ^{
            
            NSArray *objects = [controller allObjects];
            [[objects should] haveCountOf:5];
            
            NSDictionary *person1 = [objects objectAtIndex:0];
            [[[person1 objectForKey:@"firstName"] should] equal:@"Test"];
            [[[person1 objectForKey:@"lastName"] should] equal:@"User"];
            
            NSDictionary *person2 = [objects objectAtIndex:1];
            [[[person2 objectForKey:@"firstName"] should] equal:@"John"];
            [[[person2 objectForKey:@"lastName"] should] equal:@"Citizen"];
            
            NSDictionary *person3 = [objects objectAtIndex:2];
            [[[person3 objectForKey:@"firstName"] should] equal:@"Jane"];
            [[[person3 objectForKey:@"lastName"] should] equal:@"Citizen"];
            
            NSDictionary *person4 = [objects objectAtIndex:3];
            [[[person4 objectForKey:@"firstName"] should] equal:@"Another"];
            [[[person4 objectForKey:@"lastName"] should] equal:@"Tester"];
            
            NSDictionary *person5 = [objects objectAtIndex:4];
            [[[person5 objectForKey:@"firstName"] should] equal:@"NotAnother"];
            [[[person5 objectForKey:@"lastName"] should] equal:@"TestUser"];
        });
        
        it(@"should return the objects via -objectAtIndexPath:", ^{
            
            NSDictionary *person1 = [controller objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
            [[[person1 objectForKey:@"firstName"] should] equal:@"Test"];
            [[[person1 objectForKey:@"lastName"] should] equal:@"User"];
            
            NSDictionary *person2 = [controller objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
            [[[person2 objectForKey:@"firstName"] should] equal:@"John"];
            [[[person2 objectForKey:@"lastName"] should] equal:@"Citizen"];
            
            NSDictionary *person3 = [controller objectAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
            [[[person3 objectForKey:@"firstName"] should] equal:@"Jane"];
            [[[person3 objectForKey:@"lastName"] should] equal:@"Citizen"];
            
            NSDictionary *person4 = [controller objectAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:2]];
            [[[person4 objectForKey:@"firstName"] should] equal:@"Another"];
            [[[person4 objectForKey:@"lastName"] should] equal:@"Tester"];
            
            NSDictionary *person5 = [controller objectAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]];
            [[[person5 objectForKey:@"firstName"] should] equal:@"NotAnother"];
            [[[person5 objectForKey:@"lastName"] should] equal:@"TestUser"];
        });
        
        it(@"should return the correct index paths.", ^{
            
            NSArray *objects = [controller allObjects];
            NSIndexPath *indexPath1 = [controller indexPathOfObject:[objects objectAtIndex:0]];
            [[theValue(indexPath1.section) should] equal:0 withDelta:0];
            [[theValue(indexPath1.row) should] equal:0 withDelta:0];
            
            NSIndexPath *indexPath2 = [controller indexPathOfObject:[objects objectAtIndex:1]];
            [[theValue(indexPath2.section) should] equal:1 withDelta:0];
            [[theValue(indexPath2.row) should] equal:0 withDelta:0];
            
            NSIndexPath *indexPath3 = [controller indexPathOfObject:[objects objectAtIndex:2]];
            [[theValue(indexPath3.section) should] equal:1 withDelta:0];
            [[theValue(indexPath3.row) should] equal:1 withDelta:0];
            
            NSIndexPath *indexPath4 = [controller indexPathOfObject:[objects objectAtIndex:3]];
            [[theValue(indexPath4.section) should] equal:2 withDelta:0];
            [[theValue(indexPath4.row) should] equal:0 withDelta:0];
            
            NSIndexPath *indexPath5 = [controller indexPathOfObject:[objects objectAtIndex:4]];
            [[theValue(indexPath5.section) should] equal:2 withDelta:0];
            [[theValue(indexPath5.row) should] equal:1 withDelta:0];
        });
    });
});

SPEC_END