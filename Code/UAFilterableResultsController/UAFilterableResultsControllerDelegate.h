//
//  DSFilterableDataSourceDelegate.h
//  Kestrel
//
//  Created by Rob Amos on 16/10/2013.
//  Copyright (c) 2013 Desto. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger
{
    DSFilterableResultsChangeInsert = 1,
    DSFilterableResultsChangeDelete = 2,
    DSFilterableResultsChangeMove = 3,
    DSFilterableResultsChangeUpdate = 4
    
} DSFilterableResultsChangeType;

@class UAFilter, UAFilterableResultsController;

@protocol UAFilterableResultsControllerDelegate <NSObject>

- (id)filterableResultsController:(UAFilterableResultsController *)controller cellForRowWithObject:(id)object atIndexPath:(NSIndexPath *)indexPath;

@optional

- (BOOL)filterableResultsController:(UAFilterableResultsController *)controller shouldApplyFilter:(UAFilter *)filter;
- (void)filterableResultsController:(UAFilterableResultsController *)controller didApplyFilter:(UAFilter *)filter;

- (void)filterableResultsControllerWillChangeContent:(UAFilterableResultsController *)controller;
- (void)filterableResultsController:(UAFilterableResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(DSFilterableResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath;
- (void)filterableResultsController:(UAFilterableResultsController *)controller didChangeSectionAtIndex:(NSInteger)sectionIndex forChangeType:(DSFilterableResultsChangeType)type;
- (void)filterableResultsControllerDidChangeContent:(UAFilterableResultsController *)controller;

- (NSString *)filterableResultsController:(UAFilterableResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName;
- (NSString *)filterableResultsController:(UAFilterableResultsController *)controller titleForHeaderInSection:(NSInteger)section;
- (NSString *)filterableResultsController:(UAFilterableResultsController *)controller titleForFooterInSection:(NSInteger)section;
- (UICollectionReusableView *)filterableResultsController:(UAFilterableResultsController *)controller viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;

- (void)filterableResultsController:(UAFilterableResultsController *)controller hasNoDataForLoadingTableView:(UITableView *)tableView;

- (void)filterableResultsController:(UAFilterableResultsController *)controller hasNoDataForLoadingCollectionView:(UICollectionView *)collectionView;
- (void)filterableResultsControllerShouldReload:(UAFilterableResultsController *)controller;

@end
