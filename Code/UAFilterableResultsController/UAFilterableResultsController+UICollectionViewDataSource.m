//
//  UAFilterableResultsController+UICollectionViewDataSource.m
//  Kestrel
//
//  Created by Rob Amos on 24/01/2014.
//  Copyright (c) 2014 Desto. All rights reserved.
//

#import "UAFilterableResultsController+UICollectionViewDataSource.h"

@interface UAFilterableResultsController (UAFilterableResultsControllerInternalMethods)

- (NSMutableArray *)UAData;
- (NSMutableArray *)filteredData;
- (BOOL)isArrayTwoDimensional:(NSArray *)array;

- (BOOL)tableViewHasLoaded;
- (void)setTableViewHasLoaded:(BOOL)tableViewHasLoaded;

@end

@implementation UAFilterableResultsController (UICollectionViewDataSource)

#pragma mark - UITableViewDataSource Methods

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    // The table is never loaded until we have data
    if (self.UAData == nil)
        return 0;
    
    // we have data!
    [self setTableViewHasLoaded:YES];
    
    NSArray *data = self.filteredData ?: self.UAData;
    
    // let the delegate know if we're about to display no rows
    if ([data count] == 0)
    {
        id<UAFilterableResultsControllerDelegate> delegate = self.delegate;
        if (delegate != nil && [delegate respondsToSelector:@selector(filterableResultsController:hasNoDataForLoadingCollectionView:)])
            [delegate filterableResultsController:self hasNoDataForLoadingCollectionView:collectionView];
    }
    
    return [self isArrayTwoDimensional:data] ? (NSInteger)[data count] : 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSArray *data = self.filteredData ?: self.UAData;
    if ([self isArrayTwoDimensional:data])
        return (NSInteger)[[data objectAtIndex:(NSUInteger)section] count];
    else
        return (NSInteger)[data count];
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    id<UAFilterableResultsControllerDelegate> delegate = self.delegate;
    NSAssert(delegate != nil, @"Filterable Results Controller delegate cannot be nil.");
    NSAssert([delegate respondsToSelector:@selector(filterableResultsController:viewForSupplementaryElementOfKind:atIndexPath:)],
             @"Your delegate must implement -filterableResultsController:viewForSupplementaryElementOfKind:atIndexPath: if you have a header, footer or other supplementary view with a size greater than CGSizeZero.");
    return [delegate filterableResultsController:self viewForSupplementaryElementOfKind:kind atIndexPath:indexPath];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    id<UAFilterableResultsControllerDelegate> delegate = self.delegate;
    NSAssert(delegate != nil, @"Filterable Results Controller delegate cannot be nil.");
    
    // we need to find the object in the correct 2D Array
    NSArray *data = self.filteredData ?: self.UAData;
    id object = nil;
    if ([self isArrayTwoDimensional:data])
    {
        NSArray *section = [data objectAtIndex:(NSUInteger)indexPath.section];
        object = [section objectAtIndex:(NSUInteger)indexPath.row];
        
        // 1D Array
    } else
        object = [data objectAtIndex:(NSUInteger)indexPath.row];
    
    return [delegate filterableResultsController:self cellForItemWithObject:object atIndexPath:indexPath];
}
@end
