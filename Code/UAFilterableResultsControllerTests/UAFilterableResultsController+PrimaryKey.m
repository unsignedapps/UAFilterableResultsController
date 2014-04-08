//
//  UAFilterableResultsController+PrimaryKey.m
//  Kestrel
//
//  Created by Rob Amos on 21/10/2013.
//  Copyright (c) 2013 Desto. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "UAFilterableResultsController.h"

@interface UAFilterableResultsController (TestingMethods)

- (BOOL)isObject:(id)object equalToObject:(id)object usingKeyPath:(NSString *)keyPath;

@end

SPEC_BEGIN(UAFilterableResultsController_PrimaryKey)

describe(@"UAFilterableResultsController: Basic Data and Retrieval Setting", ^
{
    context(@"when testing straight out equality", ^
    {
        __block UAFilterableResultsController *controller;
        beforeEach(^{
            
            controller = [[UAFilterableResultsController alloc] initWithPrimaryKeyPath:nil delegate:nil];
        });
        afterEach(^{
            
            controller = nil;
        });
        
        it(@"should return equal for objects that have the same primary key.", ^{

            NSDictionary *obj1 = @{ @"id": @"1", @"firstName": @"Test", @"lastName": @"User" };
            [[theValue([controller isObject:obj1 equalToObject:@{ @"id": @"1" } usingKeyPath:@"id"]) should] beYes];

            NSDictionary *obj2 = @{ @"id": @"2", @"firstName": @"John", @"lastName": @"Citizen" };
            NSDictionary *obj2a = @{ @"id": @"2", @"firstName": @"John" };
            [[theValue([controller isObject:obj2 equalToObject:obj2a usingKeyPath:@"id"]) should] beYes];

            NSDictionary *obj3 = @{ @"id": @"3", @"firstName": @"Jane", @"lastName": @"Citizen" };
            NSDictionary *objc3a = @{ @"id": @"3", @"firstName": @"John", @"lastName": @"Citizen" };
            [[theValue([controller isObject:obj3 equalToObject:objc3a usingKeyPath:@"id"]) should] beYes];
        });

        it(@"should return not equal for objects that have differing primary keys.", ^{
            
            NSDictionary *obj1 = @{ @"id": @"1", @"firstName": @"Test", @"lastName": @"User" };
            [[theValue([controller isObject:obj1 equalToObject:@{ @"id": @"a" } usingKeyPath:@"id"]) should] beNo];
            
            NSDictionary *obj2 = @{ @"id": @"2", @"firstName": @"John", @"lastName": @"Citizen" };
            NSDictionary *obj2a = @{ @"id": @"b", @"firstName": @"John" };
            [[theValue([controller isObject:obj2 equalToObject:obj2a usingKeyPath:@"id"]) should] beNo];
            
            NSDictionary *obj3 = @{ @"id": @"3", @"firstName": @"Jane", @"lastName": @"Citizen" };
            NSDictionary *objc3a = @{ @"id": @"c", @"firstName": @"John", @"lastName": @"Citizen" };
            [[theValue([controller isObject:obj3 equalToObject:objc3a usingKeyPath:@"id"]) should] beNo];
        });
    });

    context(@"when testing one dimensional dictionary data", ^{
        
        __block UAFilterableResultsController *controller;
        beforeEach(^{
            
            controller = [[UAFilterableResultsController alloc] initWithPrimaryKeyPath:@"id" delegate:nil];
            [controller setData:@[ @{ @"id": @"1", @"firstName": @"Test", @"lastName": @"User" }, @{ @"id": @"2", @"firstName": @"John", @"lastName": @"Citizen" }, @{ @"id": @"3", @"firstName": @"Jane", @"lastName": @"Citizen" } ]];
        });
        afterEach(^{
            
            controller = nil;
        });
        
        it(@"should return the correct index paths using the primary key.", ^{
            
            NSIndexPath *indexPath1 = [controller indexPathOfObject:@{ @"id": @"1" }];
            [[theValue(indexPath1.section) should] equal:0 withDelta:0];
            [[theValue(indexPath1.row) should] equal:0 withDelta:0];
            
            NSIndexPath *indexPath2 = [controller indexPathOfObject:@{ @"id": @"2" }];
            [[theValue(indexPath2.section) should] equal:0 withDelta:0];
            [[theValue(indexPath2.row) should] equal:1 withDelta:0];
            
            NSIndexPath *indexPath3 = [controller indexPathOfObject:@{ @"id": @"3" }];
            [[theValue(indexPath3.section) should] equal:0 withDelta:0];
            [[theValue(indexPath3.row) should] equal:2 withDelta:0];
        });
    });
    
    context(@"when testing two dimensional dictionary data", ^{
        
        __block UAFilterableResultsController *controller;
        beforeEach(^{
            
            controller = [[UAFilterableResultsController alloc] initWithPrimaryKeyPath:@"id" delegate:nil];
            [controller setData:@[
                                  @[ @{ @"id": @"1", @"firstName": @"Test", @"lastName": @"User" } ],
                                  @[ @{ @"id": @"2", @"firstName": @"John", @"lastName": @"Citizen" }, @{ @"id": @"3", @"firstName": @"Jane", @"lastName": @"Citizen" } ],
                                  @[ @{ @"id": @"4", @"firstName": @"Another", @"lastName": @"Tester" }, @{ @"id": @"5", @"firstName": @"NotAnother", @"lastName": @"TestUser" } ]
                                  ]];
        });
        afterEach(^{
            
            controller = nil;
        });
        
        it(@"should return the correct index paths.", ^{
            
            NSIndexPath *indexPath1 = [controller indexPathOfObject:@{ @"id": @"1" }];
            [[theValue(indexPath1.section) should] equal:0 withDelta:0];
            [[theValue(indexPath1.row) should] equal:0 withDelta:0];
            
            NSIndexPath *indexPath2 = [controller indexPathOfObject:@{ @"id": @"2" }];
            [[theValue(indexPath2.section) should] equal:1 withDelta:0];
            [[theValue(indexPath2.row) should] equal:0 withDelta:0];
            
            NSIndexPath *indexPath3 = [controller indexPathOfObject:@{ @"id": @"3" }];
            [[theValue(indexPath3.section) should] equal:1 withDelta:0];
            [[theValue(indexPath3.row) should] equal:1 withDelta:0];
            
            NSIndexPath *indexPath4 = [controller indexPathOfObject:@{ @"id": @"4" }];
            [[theValue(indexPath4.section) should] equal:2 withDelta:0];
            [[theValue(indexPath4.row) should] equal:0 withDelta:0];
            
            NSIndexPath *indexPath5 = [controller indexPathOfObject:@{ @"id": @"5" }];
            [[theValue(indexPath5.section) should] equal:2 withDelta:0];
            [[theValue(indexPath5.row) should] equal:1 withDelta:0];
        });
    });
});

SPEC_END