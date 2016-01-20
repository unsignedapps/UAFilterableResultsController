//
//  UAFilterableResultsController+ArrayDifferences.m
//  UAFilterableResultsController
//
//  Created by Rob Amos on 10/04/2014.
//  Copyright (c) 2014 Unsigned Apps. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "UAFilterableResultsController.h"

#import "UAFilterableResultsController+Private.h"



SPEC_BEGIN(UAFilterableResultsController_ArrayDifferences)

describe(@"UAFilterableResultsController: Array Differences", ^{

    context(@"When not using a Primary Key", ^{
        __block UAFilterableResultsController *controller;
        __block id delegateMock;
        beforeEach(^{
            
            delegateMock = [KWMock nullMockForProtocol:@protocol(UAFilterableResultsControllerDelegate)];
            controller = [[UAFilterableResultsController alloc] initWithDelegate:delegateMock];
            
            // pretend the table view has loaded, otherwise no delegate messages are sent
            [controller setTableViewHasLoaded:YES];
        });
        afterEach(^{
            
            controller = nil;
        });
        
        it(@"should calculate the addition of an object", ^{
            
            // set initial data
            [controller setData:@[ @"Item 1" ]];
            
            // capture arguments
            KWCaptureSpy *spy0 = [delegateMock captureArgument:@selector(filterableResultsController:didChangeObject:atIndexPath:forChangeType:newIndexPath:) atIndex:0];
            KWCaptureSpy *spy1 = [delegateMock captureArgument:@selector(filterableResultsController:didChangeObject:atIndexPath:forChangeType:newIndexPath:) atIndex:1];
            KWCaptureSpy *spy2 = [delegateMock captureArgument:@selector(filterableResultsController:didChangeObject:atIndexPath:forChangeType:newIndexPath:) atIndex:2];
            KWCaptureSpy *spy3 = [delegateMock captureArgument:@selector(filterableResultsController:didChangeObject:atIndexPath:forChangeType:newIndexPath:) atIndex:3];
            KWCaptureSpy *spy4 = [delegateMock captureArgument:@selector(filterableResultsController:didChangeObject:atIndexPath:forChangeType:newIndexPath:) atIndex:4];

            [[delegateMock should] receive:@selector(filterableResultsController:didChangeObject:atIndexPath:forChangeType:newIndexPath:)];

            [controller addObject:@"Item 2"];

            // verify those values
            [[spy0.argument should] equal:controller];
            [[spy1.argument should] equal:@"Item 2"];
            [[spy2.argument should] beNil];
            [[spy3.argument should] equal:theValue(UAFilterableResultsChangeInsert)];
            [[spy4.argument should] equal:[NSIndexPath indexPathForRow:1 inSection:0]];
        });
        
        it(@"should calculate the removal of an object", ^{
            
            // set initial data
            [controller setData:@[ @"Item 1", @"Item 2" ]];
            
            // capture arguments
            KWCaptureSpy *spy0 = [delegateMock captureArgument:@selector(filterableResultsController:didChangeObject:atIndexPath:forChangeType:newIndexPath:) atIndex:0];
            KWCaptureSpy *spy1 = [delegateMock captureArgument:@selector(filterableResultsController:didChangeObject:atIndexPath:forChangeType:newIndexPath:) atIndex:1];
            KWCaptureSpy *spy2 = [delegateMock captureArgument:@selector(filterableResultsController:didChangeObject:atIndexPath:forChangeType:newIndexPath:) atIndex:2];
            KWCaptureSpy *spy3 = [delegateMock captureArgument:@selector(filterableResultsController:didChangeObject:atIndexPath:forChangeType:newIndexPath:) atIndex:3];
            KWCaptureSpy *spy4 = [delegateMock captureArgument:@selector(filterableResultsController:didChangeObject:atIndexPath:forChangeType:newIndexPath:) atIndex:4];
            
            [[delegateMock should] receive:@selector(filterableResultsController:didChangeObject:atIndexPath:forChangeType:newIndexPath:)];
            
            [controller removeObject:@"Item 1"];
            
            // verify those values
            [[spy0.argument should] equal:controller];
            [[spy1.argument should] equal:@"Item 1"];
            [[spy2.argument should] equal:[NSIndexPath indexPathForRow:0 inSection:0]];
            [[spy3.argument should] equal:theValue(UAFilterableResultsChangeDelete)];
            [[spy4.argument should] beNil];
        });
    });

    context(@"When using primary keys", ^{
        __block UAFilterableResultsController *controller;
        __block id delegateMock;
        beforeEach(^{
            
            delegateMock = [KWMock nullMockForProtocol:@protocol(UAFilterableResultsControllerDelegate)];
            controller = [[UAFilterableResultsController alloc] initWithPrimaryKeyPath:@"id" delegate:delegateMock];
            
            // pretend the table view has loaded, otherwise no delegate messages are sent
            [controller setTableViewHasLoaded:YES];
        });
        afterEach(^{
            
            controller = nil;
        });
        
        it(@"should calculate the addition of an object", ^{
            
            // set initial data
            NSDictionary *obj1 = @{ @"id": @"1", @"firstName": @"Test", @"lastName": @"User" };
            NSDictionary *obj2 = @{ @"id": @"2", @"firstName": @"John", @"lastName": @"Citizen" };
            NSDictionary *obj3 = @{ @"id": @"3", @"firstName": @"Jane", @"lastName": @"Citizen" };
            [controller setData:@[ obj1, obj2 ]];
            
            // capture arguments
            KWCaptureSpy *spy0 = [delegateMock captureArgument:@selector(filterableResultsController:didChangeObject:atIndexPath:forChangeType:newIndexPath:) atIndex:0];
            KWCaptureSpy *spy1 = [delegateMock captureArgument:@selector(filterableResultsController:didChangeObject:atIndexPath:forChangeType:newIndexPath:) atIndex:1];
            KWCaptureSpy *spy2 = [delegateMock captureArgument:@selector(filterableResultsController:didChangeObject:atIndexPath:forChangeType:newIndexPath:) atIndex:2];
            KWCaptureSpy *spy3 = [delegateMock captureArgument:@selector(filterableResultsController:didChangeObject:atIndexPath:forChangeType:newIndexPath:) atIndex:3];
            KWCaptureSpy *spy4 = [delegateMock captureArgument:@selector(filterableResultsController:didChangeObject:atIndexPath:forChangeType:newIndexPath:) atIndex:4];
            
            [[delegateMock should] receive:@selector(filterableResultsController:didChangeObject:atIndexPath:forChangeType:newIndexPath:)];
            
            [controller addObject:obj3];
            
            // verify those values
            [[spy0.argument should] equal:controller];
            [[spy1.argument should] equal:obj3];
            [[spy2.argument should] beNil];
            [[spy3.argument should] equal:theValue(UAFilterableResultsChangeInsert)];
            [[spy4.argument should] equal:[NSIndexPath indexPathForRow:2 inSection:0]];
        });
        
        it(@"should calculate the removal of an object", ^{
            
            // set initial data
            NSDictionary *obj1 = @{ @"id": @"1", @"firstName": @"Test", @"lastName": @"User" };
            NSDictionary *obj2 = @{ @"id": @"2", @"firstName": @"John", @"lastName": @"Citizen" };
            NSDictionary *obj3 = @{ @"id": @"3", @"firstName": @"Jane", @"lastName": @"Citizen" };
            [controller setData:@[ obj1, obj2, obj3 ]];
            
            [delegateMock stub:@selector(filterableResultsController:didChangeObject:atIndexPath:forChangeType:newIndexPath:)
                     withBlock:^id(NSArray *params)
            {
                [[params[0] should] equal:controller];
                [[params[1] should] equal:obj2];
                [[params[2] should] equal:[NSIndexPath indexPathForRow:1 inSection:0]];
                [[params[3] should] equal:theValue(UAFilterableResultsChangeDelete)];
                [[params[4] should] equal:[NSNull null]];
                return nil;
            }];
            
            [[delegateMock should] receive:@selector(filterableResultsController:didChangeObject:atIndexPath:forChangeType:newIndexPath:)];
            [controller removeObject:obj2];
        });

        it(@"should calculate the addition of an object by merging", ^{
            
            // set initial data
            NSDictionary *obj1 = @{ @"id": @"1", @"firstName": @"Test", @"lastName": @"User" };
            NSDictionary *obj2 = @{ @"id": @"2", @"firstName": @"John", @"lastName": @"Citizen" };
            NSDictionary *obj3 = @{ @"id": @"3", @"firstName": @"Jane", @"lastName": @"Citizen" };
            [controller setData:@[ obj1, obj3 ]];
            
            __block NSUInteger calls = 0;
            [delegateMock stub:@selector(filterableResultsController:didChangeObject:atIndexPath:forChangeType:newIndexPath:)
                     withBlock:^id(NSArray *params)
            {
                if (calls == 0)
                {
                    [[params[0] should] equal:controller];
                    [[params[1] should] equal:obj1];
                    [[params[2] should] equal:[NSIndexPath indexPathForRow:0 inSection:0]];
                    [[params[3] should] equal:theValue(UAFilterableResultsChangeUpdate)];
                    [[params[4] should] equal:[NSNull null]];

                } else if (calls == 1)
                {
                    [[params[0] should] equal:controller];
                    [[params[1] should] equal:obj2];
                    [[params[2] should] equal:[NSNull null]];
                    [[params[3] should] equal:theValue(UAFilterableResultsChangeInsert)];
                    [[params[4] should] equal:[NSIndexPath indexPathForRow:1 inSection:0]];
                    
                } else if (calls == 2)
                {
                    [[params[0] should] equal:controller];
                    [[params[1] should] equal:obj3];
                    [[params[2] should] equal:[NSIndexPath indexPathForRow:1 inSection:0]];
                    [[params[3] should] equal:theValue(UAFilterableResultsChangeUpdate)];
                    [[params[4] should] equal:[NSNull null]];
                    
                }
                calls++;
                return nil;
            }];
            
            [[delegateMock should] receive:@selector(filterableResultsController:didChangeObject:atIndexPath:forChangeType:newIndexPath:) withCount:3];
            [controller setData:@[ obj1, obj2, obj3 ]];
        });

        it(@"should calculate the removal of an object by merging", ^{
            
            // set initial data
            NSDictionary *obj1 = @{ @"id": @"1", @"firstName": @"Test", @"lastName": @"User" };
            NSDictionary *obj2 = @{ @"id": @"2", @"firstName": @"John", @"lastName": @"Citizen" };
            NSDictionary *obj3 = @{ @"id": @"3", @"firstName": @"Jane", @"lastName": @"Citizen" };
            [controller setData:@[ obj1, obj2, obj3 ]];
            
            __block NSUInteger calls = 0;
            [delegateMock stub:@selector(filterableResultsController:didChangeObject:atIndexPath:forChangeType:newIndexPath:)
                     withBlock:^id(NSArray *params)
            {
                if (calls == 0)
                {
                    [[params[0] should] equal:controller];
                    [[params[1] should] equal:obj2];
                    [[params[2] should] equal:[NSIndexPath indexPathForRow:1 inSection:0]];
                    [[params[3] should] equal:theValue(UAFilterableResultsChangeDelete)];
                    [[params[4] should] equal:[NSNull null]];

                } else if (calls == 1)
                {
                    [[params[0] should] equal:controller];
                    [[params[1] should] equal:obj1];
                    [[params[2] should] equal:[NSIndexPath indexPathForRow:0 inSection:0]];
                    [[params[3] should] equal:theValue(UAFilterableResultsChangeUpdate)];
                    [[params[4] should] equal:[NSNull null]];

                } else if (calls == 2)
                {
                    [[params[0] should] equal:controller];
                    [[params[1] should] equal:obj3];
                    [[params[2] should] equal:[NSIndexPath indexPathForRow:2 inSection:0]];
                    [[params[3] should] equal:theValue(UAFilterableResultsChangeUpdate)];
                    [[params[4] should] equal:[NSNull null]];

                }
                calls++;
                return nil;
            }];
            
            [[delegateMock should] receive:@selector(filterableResultsController:didChangeObject:atIndexPath:forChangeType:newIndexPath:) withCount:3];
            [controller setData:@[ obj1, obj3 ]];
        });
    });
});

SPEC_END