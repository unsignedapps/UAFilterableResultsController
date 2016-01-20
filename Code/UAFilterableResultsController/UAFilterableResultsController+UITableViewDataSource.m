//
//  UAFilterableResultsController+UITableViewDataSource.m
//  Kestrel
//
//  Created by Rob Amos on 23/01/2014.
//  Copyright (c) 2014 Desto. All rights reserved.
//

#import "UAFilterableResultsController+UITableViewDataSource.h"

#pragma mark Private Methods

#import "UAFilterableResultsController+Private.h"




@implementation UAFilterableResultsController (UITableViewDataSource)

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // The table is never loaded until we have data
    if (self.UAData == nil) {
        return 0;
    }
    
    // we have data!
    self.tableViewHasLoaded = YES;
    
    NSArray *data = self.filteredData ?: self.UAData;
    
    // let the delegate know if we're about to display no rows
    if (data.count == 0) {
        id<UAFilterableResultsControllerDelegate> delegate = self.delegate;
        if (delegate != nil && [delegate respondsToSelector:@selector(filterableResultsController:hasNoDataForLoadingTableView:)]) {
            [delegate filterableResultsController:self hasNoDataForLoadingTableView:tableView];
        }
    }
    
    return [self isArrayTwoDimensional:data] ? (NSInteger)[data count] : 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray *data = self.filteredData ?: self.UAData;
    if ([self isArrayTwoDimensional:data]) {
        NSArray * rows = data[section];
        return (NSInteger)rows.count;
    }
    else {
        return (NSInteger)data.count;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    id<UAFilterableResultsControllerDelegate> delegate = self.delegate;
    if (delegate != nil && [delegate respondsToSelector:@selector(filterableResultsController:titleForHeaderInSection:)]) {
        return [delegate filterableResultsController:self titleForHeaderInSection:section];
    }
    
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    id<UAFilterableResultsControllerDelegate> delegate = self.delegate;
    if (delegate != nil && [delegate respondsToSelector:@selector(filterableResultsController:titleForFooterInSection:)]) {
        return [delegate filterableResultsController:self titleForFooterInSection:section];
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    id<UAFilterableResultsControllerDelegate> delegate = self.delegate;
    NSAssert(delegate != nil, @"Filterable Results Controller delegate cannot be nil.");
    
    // we need to find the object in the correct 2D Array
    NSArray *data = self.filteredData ?: self.UAData;
    id object = nil;
    if ([self isArrayTwoDimensional:data]) {
        NSArray *section = data[indexPath.section];
        object = section[indexPath.row];
        
        // 1D Array
    } else {
        object = data[indexPath.row];
    }
    
    return [delegate filterableResultsController:self cellForItemWithObject:object atIndexPath:indexPath];
}

@end
