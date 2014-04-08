//
//  UAFilterableResultsController+UITableViewDataSource.m
//  Kestrel
//
//  Created by Rob Amos on 19/10/2013.
//  Copyright (c) 2013 Desto. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "UAFilterableResultsController.h"

// If we import the header it still doesn't believe that we implement the protocol and these
// methods are available.
@interface UAFilterableResultsController (UITableViewDataSourceTests) <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView;
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

SPEC_BEGIN(UAFilterableResultsController_UITableViewDataSource)

describe(@"UAFilterableResultsController's UITableViewDataSource support", ^
{
    context(@"when testing one dimensional arrays with flat numeric data", ^{
        
        __block UAFilterableResultsController *controller;
        __block id mockDelegate;
        beforeEach(^{
            
            mockDelegate = [KWMock nullMockForProtocol:@protocol(UAFilterableResultsControllerDelegate)];
            controller = [[UAFilterableResultsController alloc] initWithPrimaryKeyPath:nil delegate:mockDelegate];
            [controller setData:@[ @1, @2, @3, @4 ]];
        });
        afterEach(^{
            
            controller = nil;
            mockDelegate = nil;
        });
        
        it(@"should return one section.", ^{
            
            [[theValue([controller numberOfSectionsInTableView:nil]) should] equal:theValue(1)];
        });
        
        it(@"should return four rows in the section.", ^{
            
            [[theValue([controller tableView:nil numberOfRowsInSection:0]) should] equal:theValue(4)];
        });
           
        it(@"should ask our delegate for the cell, and return it.", ^{
            
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TestCell"];
            NSNumber *value = [[controller data] objectAtIndex:2];

            [[mockDelegate should] receive:@selector(filterableResultsController:cellForRowWithObject:atIndexPath:) andReturn:cell withArguments:controller, value, [NSIndexPath indexPathForRow:2 inSection:0]];
            [[[controller tableView:nil cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] should] equal:cell];
        });

        it(@"should ask our delegate for the section header title, and return it.", ^{
            
            NSString *header = @"Test Header";
            [[mockDelegate should] receive:@selector(filterableResultsController:titleForHeaderInSection:) andReturn:header withArguments:controller, theValue(0)];
            [[[controller tableView:nil titleForHeaderInSection:0] should] equal:header];
        });
        
        it(@"should ask our delegate for the section footer title, and return it.", ^{
            
            NSString *footer = @"Test Footer";
            [[mockDelegate should] receive:@selector(filterableResultsController:titleForFooterInSection:) andReturn:footer withArguments:controller, theValue(0)];
            [[[controller tableView:nil titleForFooterInSection:0] should] equal:footer];
        });
    });

    context(@"when testing one dimensional arrays with dictionary data sets", ^{

        __block UAFilterableResultsController *controller;
        __block id mockDelegate;
        beforeEach(^{

            mockDelegate = [KWMock nullMockForProtocol:@protocol(UAFilterableResultsControllerDelegate)];
            controller = [[UAFilterableResultsController alloc] initWithPrimaryKeyPath:nil delegate:mockDelegate];
            [controller setData:@[ @{ @"firstName": @"Test", @"lastName": @"User" }, @{ @"firstName": @"John", @"lastName": @"Citizen" }, @{ @"firstName": @"Jane", @"lastName": @"Citizen" } ]];
        });
        afterEach(^{
            
            controller = nil;
            mockDelegate = nil;
        });
        
        it(@"should return one section.", ^{

            [[theValue([controller numberOfSectionsInTableView:nil]) should] equal:theValue(1)];
        });
        
        it(@"should return four rows in the section.", ^{

            [[theValue([controller tableView:nil numberOfRowsInSection:0]) should] equal:theValue(3)];
        });
        
        it(@"should ask our delegate for the cell, and return it.", ^{
            
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TestCell"];
            NSDictionary *value = [[controller data] objectAtIndex:2];

            [[mockDelegate should] receive:@selector(filterableResultsController:cellForRowWithObject:atIndexPath:) andReturn:cell withArguments:controller, value, [NSIndexPath indexPathForRow:2 inSection:0]];
            [[[controller tableView:nil cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] should] equal:cell];
        });
        
        it(@"should ask our delegate for the section header title, and return it.", ^{

            NSString *header = @"Test Header";
            [[mockDelegate should] receive:@selector(filterableResultsController:titleForHeaderInSection:) andReturn:header withArguments:controller, theValue(0)];
            [[[controller tableView:nil titleForHeaderInSection:0] should] equal:header];
        });
        
        it(@"should ask our delegate for the section footer title, and return it.", ^{

            NSString *footer = @"Test Footer";
            [[mockDelegate should] receive:@selector(filterableResultsController:titleForFooterInSection:) andReturn:footer withArguments:controller, theValue(0)];
            [[[controller tableView:nil titleForFooterInSection:0] should] equal:footer];
        });
    });

    context(@"when testing two dimensional arrays with two sections of numeric data", ^{
        
        __block UAFilterableResultsController *controller;
        __block id mockDelegate;
        beforeEach(^{
            
            mockDelegate = [KWMock nullMockForProtocol:@protocol(UAFilterableResultsControllerDelegate)];
            controller = [[UAFilterableResultsController alloc] initWithPrimaryKeyPath:nil delegate:mockDelegate];
            [controller setData:@[ @[ @1, @2, @3, @4 ], @[ @5, @6, @7, @8, @9 ] ]];
        });
        afterEach(^{
            
            controller = nil;
            mockDelegate = nil;
        });
        
        it(@"should return two sections.", ^{
            
            [[theValue([controller numberOfSectionsInTableView:nil]) should] equal:theValue(2)];
        });
        
        it(@"should return four rows in the first, five in the second.", ^{
            
            [[theValue([controller tableView:nil numberOfRowsInSection:0]) should] equal:theValue(4)];
            [[theValue([controller tableView:nil numberOfRowsInSection:1]) should] equal:theValue(5)];
        });
        
        it(@"should ask our delegate for the cell, and return it.", ^{
            
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TestCell"];

            NSNumber *value1 = [[[controller data] objectAtIndex:0] objectAtIndex:2];
            [[mockDelegate should] receive:@selector(filterableResultsController:cellForRowWithObject:atIndexPath:) andReturn:cell withArguments:controller, value1, [NSIndexPath indexPathForRow:2 inSection:0]];
            [[[controller tableView:nil cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] should] equal:cell];

            NSNumber *value2 = [[[controller data] objectAtIndex:1] objectAtIndex:3];
            [[mockDelegate should] receive:@selector(filterableResultsController:cellForRowWithObject:atIndexPath:) andReturn:cell withArguments:controller, value2, [NSIndexPath indexPathForRow:3 inSection:1]];
            [[[controller tableView:nil cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:1]] should] equal:cell];
        });
        
        it(@"should ask our delegate for the section header title, and return it.", ^{
            
            NSString *header1 = @"Test Header 1";
            [[mockDelegate should] receive:@selector(filterableResultsController:titleForHeaderInSection:) andReturn:header1 withArguments:controller, theValue(0)];
            [[[controller tableView:nil titleForHeaderInSection:0] should] equal:header1];

            NSString *header2 = @"Test Header 2";
            [[mockDelegate should] receive:@selector(filterableResultsController:titleForHeaderInSection:) andReturn:header2 withArguments:controller, theValue(1)];
            [[[controller tableView:nil titleForHeaderInSection:1] should] equal:header2];
        });
        
        it(@"should ask our delegate for the section footer title, and return it.", ^{
            
            NSString *footer1 = @"Test Footer 1";
            [[mockDelegate should] receive:@selector(filterableResultsController:titleForFooterInSection:) andReturn:footer1 withArguments:controller, theValue(0)];
            [[[controller tableView:nil titleForFooterInSection:0] should] equal:footer1];

            NSString *footer2 = @"Test Footer 2";
            [[mockDelegate should] receive:@selector(filterableResultsController:titleForFooterInSection:) andReturn:footer2 withArguments:controller, theValue(1)];
            [[[controller tableView:nil titleForFooterInSection:1] should] equal:footer2];
        });
    });
    
    context(@"when testing two dimensional arrays with two sections of dictionary data", ^{
        
        __block UAFilterableResultsController *controller;
        __block id mockDelegate;
        beforeEach(^{
            
            mockDelegate = [KWMock nullMockForProtocol:@protocol(UAFilterableResultsControllerDelegate)];
            controller = [[UAFilterableResultsController alloc] initWithPrimaryKeyPath:nil delegate:mockDelegate];
            [controller setData:@[ @[ @{ @"firstName": @"Test", @"lastName": @"User" } ], @[ @{ @"firstName": @"John", @"lastName": @"Citizen" }, @{ @"firstName": @"Jane", @"lastName": @"Citizen" } ] ]];
        });
        afterEach(^{
            
            controller = nil;
            mockDelegate = nil;
        });
        
        it(@"should return two sections.", ^{
            
            [[theValue([controller numberOfSectionsInTableView:nil]) should] equal:theValue(2)];
        });
        
        it(@"should return one row in the first section, two rows in the second.", ^{
            
            [[theValue([controller tableView:nil numberOfRowsInSection:0]) should] equal:theValue(1)];
            [[theValue([controller tableView:nil numberOfRowsInSection:1]) should] equal:theValue(2)];
        });
        
        it(@"should ask our delegate for the cell, and return it.", ^{
            
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TestCell"];

            NSNumber *value1 = [[[controller data] objectAtIndex:0] objectAtIndex:0];
            [[mockDelegate should] receive:@selector(filterableResultsController:cellForRowWithObject:atIndexPath:) andReturn:cell withArguments:controller, value1, [NSIndexPath indexPathForRow:0 inSection:0]];
            [[[controller tableView:nil cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should] equal:cell];
            
            NSNumber *value2 = [[[controller data] objectAtIndex:1] objectAtIndex:1];
            [[mockDelegate should] receive:@selector(filterableResultsController:cellForRowWithObject:atIndexPath:) andReturn:cell withArguments:controller, value2, [NSIndexPath indexPathForRow:1 inSection:1]];
            [[[controller tableView:nil cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]] should] equal:cell];
        });
        
        it(@"should ask our delegate for the section header title, and return it.", ^{
            
            NSString *header1 = @"Test Header 1";
            [[mockDelegate should] receive:@selector(filterableResultsController:titleForHeaderInSection:) andReturn:header1 withArguments:controller, theValue(0)];
            [[[controller tableView:nil titleForHeaderInSection:0] should] equal:header1];
            
            NSString *header2 = @"Test Header 2";
            [[mockDelegate should] receive:@selector(filterableResultsController:titleForHeaderInSection:) andReturn:header2 withArguments:controller, theValue(1)];
            [[[controller tableView:nil titleForHeaderInSection:1] should] equal:header2];
        });
        
        it(@"should ask our delegate for the section footer title, and return it.", ^{
            
            NSString *footer1 = @"Test Footer 1";
            [[mockDelegate should] receive:@selector(filterableResultsController:titleForFooterInSection:) andReturn:footer1 withArguments:controller, theValue(0)];
            [[[controller tableView:nil titleForFooterInSection:0] should] equal:footer1];
            
            NSString *footer2 = @"Test Footer 2";
            [[mockDelegate should] receive:@selector(filterableResultsController:titleForFooterInSection:) andReturn:footer2 withArguments:controller, theValue(1)];
            [[[controller tableView:nil titleForFooterInSection:1] should] equal:footer2];
        });
    });

    context(@"when testing two dimensional arrays with three sections of numeric data", ^{
        
        __block UAFilterableResultsController *controller;
        __block id mockDelegate;
        beforeEach(^{
            
            mockDelegate = [KWMock nullMockForProtocol:@protocol(UAFilterableResultsControllerDelegate)];
            controller = [[UAFilterableResultsController alloc] initWithPrimaryKeyPath:nil delegate:mockDelegate];
            [controller setData:@[ @[ @1, @2, @3, @4 ], @[ @5, @6, @7, @8, @9 ], @[ @10, @11 ] ]];
        });
        afterEach(^{
            
            controller = nil;
            mockDelegate = nil;
        });
        
        it(@"should return three sections.", ^{
            
            [[theValue([controller numberOfSectionsInTableView:nil]) should] equal:theValue(3)];
        });
        
        it(@"should return four rows in the first, five in the second, two in the third", ^{
            
            [[theValue([controller tableView:nil numberOfRowsInSection:0]) should] equal:theValue(4)];
            [[theValue([controller tableView:nil numberOfRowsInSection:1]) should] equal:theValue(5)];
            [[theValue([controller tableView:nil numberOfRowsInSection:2]) should] equal:theValue(2)];
        });
        
        it(@"should ask our delegate for the cells, and return them.", ^{
            
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TestCell"];
            
            NSNumber *value1 = [[[controller data] objectAtIndex:0] objectAtIndex:2];
            [[mockDelegate should] receive:@selector(filterableResultsController:cellForRowWithObject:atIndexPath:) andReturn:cell withArguments:controller, value1, [NSIndexPath indexPathForRow:2 inSection:0]];
            [[[controller tableView:nil cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]] should] equal:cell];
            
            NSNumber *value2 = [[[controller data] objectAtIndex:1] objectAtIndex:3];
            [[mockDelegate should] receive:@selector(filterableResultsController:cellForRowWithObject:atIndexPath:) andReturn:cell withArguments:controller, value2, [NSIndexPath indexPathForRow:3 inSection:1]];
            [[[controller tableView:nil cellForRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:1]] should] equal:cell];

            NSNumber *value3 = [[[controller data] objectAtIndex:2] objectAtIndex:1];
            [[mockDelegate should] receive:@selector(filterableResultsController:cellForRowWithObject:atIndexPath:) andReturn:cell withArguments:controller, value3, [NSIndexPath indexPathForRow:1 inSection:2]];
            [[[controller tableView:nil cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]] should] equal:cell];
        });
        
        it(@"should ask our delegate for the section header title, and return it.", ^{
            
            NSString *header1 = @"Test Header 1";
            [[mockDelegate should] receive:@selector(filterableResultsController:titleForHeaderInSection:) andReturn:header1 withArguments:controller, theValue(0)];
            [[[controller tableView:nil titleForHeaderInSection:0] should] equal:header1];
            
            NSString *header2 = @"Test Header 2";
            [[mockDelegate should] receive:@selector(filterableResultsController:titleForHeaderInSection:) andReturn:header2 withArguments:controller, theValue(1)];
            [[[controller tableView:nil titleForHeaderInSection:1] should] equal:header2];

            NSString *header3 = @"Test Header 3";
            [[mockDelegate should] receive:@selector(filterableResultsController:titleForHeaderInSection:) andReturn:header3 withArguments:controller, theValue(2)];
            [[[controller tableView:nil titleForHeaderInSection:2] should] equal:header3];
        });
        
        it(@"should ask our delegate for the section footer title, and return it.", ^{
            
            NSString *footer1 = @"Test Footer 1";
            [[mockDelegate should] receive:@selector(filterableResultsController:titleForFooterInSection:) andReturn:footer1 withArguments:controller, theValue(0)];
            [[[controller tableView:nil titleForFooterInSection:0] should] equal:footer1];
            
            NSString *footer2 = @"Test Footer 2";
            [[mockDelegate should] receive:@selector(filterableResultsController:titleForFooterInSection:) andReturn:footer2 withArguments:controller, theValue(1)];
            [[[controller tableView:nil titleForFooterInSection:1] should] equal:footer2];

            NSString *footer3 = @"Test Footer 3";
            [[mockDelegate should] receive:@selector(filterableResultsController:titleForFooterInSection:) andReturn:footer3 withArguments:controller, theValue(2)];
            [[[controller tableView:nil titleForFooterInSection:2] should] equal:footer3];
        });
    });
    
    context(@"when testing two dimensional arrays with three sections of dictionary data", ^{
        
        __block UAFilterableResultsController *controller;
        __block id mockDelegate;
        beforeEach(^{
            
            mockDelegate = [KWMock nullMockForProtocol:@protocol(UAFilterableResultsControllerDelegate)];
            controller = [[UAFilterableResultsController alloc] initWithPrimaryKeyPath:nil delegate:mockDelegate];
            [controller setData:@[
                @[ @{ @"firstName": @"Test", @"lastName": @"User" } ],
                @[ @{ @"firstName": @"John", @"lastName": @"Citizen" }, @{ @"firstName": @"Jane", @"lastName": @"Citizen" } ],
                @[ @{ @"firstName": @"Another", @"lastName": @"Tester" }, @{ @"firstName": @"NotAnother", @"lastName": @"TestUser" } ]
            ]];
        });
        afterEach(^{
            
            controller = nil;
            mockDelegate = nil;
        });
        
        it(@"should return three sections.", ^{
            
            [[theValue([controller numberOfSectionsInTableView:nil]) should] equal:theValue(3)];
        });
        
        it(@"should return one row in the first section, two rows in the second, two in the third.", ^{
            
            [[theValue([controller tableView:nil numberOfRowsInSection:0]) should] equal:theValue(1)];
            [[theValue([controller tableView:nil numberOfRowsInSection:1]) should] equal:theValue(2)];
            [[theValue([controller tableView:nil numberOfRowsInSection:2]) should] equal:theValue(2)];
        });
        
        it(@"should ask our delegate for the cells, and return them.", ^{
            
            UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"TestCell"];
            
            NSNumber *value1 = [[[controller data] objectAtIndex:0] objectAtIndex:0];
            [[mockDelegate should] receive:@selector(filterableResultsController:cellForRowWithObject:atIndexPath:) andReturn:cell withArguments:controller, value1, [NSIndexPath indexPathForRow:0 inSection:0]];
            [[[controller tableView:nil cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]] should] equal:cell];
            
            NSNumber *value2 = [[[controller data] objectAtIndex:1] objectAtIndex:1];
            [[mockDelegate should] receive:@selector(filterableResultsController:cellForRowWithObject:atIndexPath:) andReturn:cell withArguments:controller, value2, [NSIndexPath indexPathForRow:1 inSection:1]];
            [[[controller tableView:nil cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]] should] equal:cell];

            NSNumber *value3 = [[[controller data] objectAtIndex:2] objectAtIndex:1];
            [[mockDelegate should] receive:@selector(filterableResultsController:cellForRowWithObject:atIndexPath:) andReturn:cell withArguments:controller, value3, [NSIndexPath indexPathForRow:1 inSection:2]];
            [[[controller tableView:nil cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:2]] should] equal:cell];
        });
        
        it(@"should ask our delegate for the section header title, and return it.", ^{
            
            NSString *header1 = @"Test Header 1";
            [[mockDelegate should] receive:@selector(filterableResultsController:titleForHeaderInSection:) andReturn:header1 withArguments:controller, theValue(0)];
            [[[controller tableView:nil titleForHeaderInSection:0] should] equal:header1];
            
            NSString *header2 = @"Test Header 2";
            [[mockDelegate should] receive:@selector(filterableResultsController:titleForHeaderInSection:) andReturn:header2 withArguments:controller, theValue(1)];
            [[[controller tableView:nil titleForHeaderInSection:1] should] equal:header2];

            NSString *header3 = @"Test Header 3";
            [[mockDelegate should] receive:@selector(filterableResultsController:titleForHeaderInSection:) andReturn:header3 withArguments:controller, theValue(2)];
            [[[controller tableView:nil titleForHeaderInSection:2] should] equal:header3];
        });
        
        it(@"should ask our delegate for the section footer title, and return it.", ^{
            
            NSString *footer1 = @"Test Footer 1";
            [[mockDelegate should] receive:@selector(filterableResultsController:titleForFooterInSection:) andReturn:footer1 withArguments:controller, theValue(0)];
            [[[controller tableView:nil titleForFooterInSection:0] should] equal:footer1];
            
            NSString *footer2 = @"Test Footer 2";
            [[mockDelegate should] receive:@selector(filterableResultsController:titleForFooterInSection:) andReturn:footer2 withArguments:controller, theValue(1)];
            [[[controller tableView:nil titleForFooterInSection:1] should] equal:footer2];
            
            NSString *footer3 = @"Test Footer 3";
            [[mockDelegate should] receive:@selector(filterableResultsController:titleForFooterInSection:) andReturn:footer3 withArguments:controller, theValue(2)];
            [[[controller tableView:nil titleForFooterInSection:2] should] equal:footer3];
        });
    });
});


SPEC_END

