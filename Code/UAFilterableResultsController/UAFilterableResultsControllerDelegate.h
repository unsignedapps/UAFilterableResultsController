//
//  UAFilterableDataSourceDelegate.h
//  Kestrel
//
//  Created by Rob Amos on 16/10/2013.
//  Copyright (c) 2013 Desto. All rights reserved.
//

@import UIKit;

typedef NS_ENUM(NSUInteger, UAFilterableResultsChangeType)
{
    // This change type should result in a row, item or section being inserted.
    UAFilterableResultsChangeInsert = 1,
    
    // This change type should result in a row, item or section being removed.
    UAFilterableResultsChangeDelete = 2,

    // This change type should result in a row or item being moved.
    UAFilterableResultsChangeMove = 3,
    
    // This change type should result in a row or item being updated.
    UAFilterableResultsChangeUpdate = 4
};

@class UAFilter, UAFilterableResultsController;

@protocol UAFilterableResultsControllerDelegate <NSObject>

/** @name Supplying Cells and Other Views **/

/**
 * Asks the delegate for a cell to insert at the specified index path.
 *
 * @param   controller              The UAFilterableResultsController requesting the cell.
 * @param   object                  The object in the data stack that should be used to configure the cell.
 * @param   indexPath               The index path that the cell will be displayed at.
 * @returns                         A UITableViewCell or UICollectionViewCell, depending on which you're working with. You cannot return nil lest you want UITableView or UICollectionView to be angry.
**/
- (id)filterableResultsController:(UAFilterableResultsController *)controller cellForItemWithObject:(id)object atIndexPath:(NSIndexPath *)indexPath;

@optional

/**
 * Asks the delegate for the header title for the section at the specified index.
 *
 * @param   controller              The UAFilterableResultsController requesting the title.
 * @param   section                 An index indentifying the section in table or collection view that this header is for.
 * @returns                         A string to use as the title of the specified section.
**/
- (NSString *)filterableResultsController:(UAFilterableResultsController *)controller titleForHeaderInSection:(NSInteger)section;

/**
 * Asks the delegate for the footer title for the section at the specified index.
 *
 * @param   controller              The UAFilterableResultsController requesting the title.
 * @param   section                 An index indentifying the section in table or collection view that this footer is for.
 * @returns                         A string to use as the title of the specified section.
**/
- (NSString *)filterableResultsController:(UAFilterableResultsController *)controller titleForFooterInSection:(NSInteger)section;

/**
 * Asks the delegate for the reusable view to be used as a supplementary element.
 *
 * @param   controller              The UAFilterableResultsController requesting the view.
 * @param   kind                    The kind of supplementary view to provide. The value of this string is defined by the layout (like say UICollectionElementKindSectionHeader or UICollectionElementKindSectionFooter).
 * @param   indexPath               The location in the Collection View that the supplementary view will be displayed at.
 * @returns                         A configured UICollectionReusableView object. See the UICollectionViewDataSource documentation for more.
**/
- (UICollectionReusableView *)filterableResultsController:(UAFilterableResultsController *)controller viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath;

/**
 * Informs your delegate that the specified table view has requested data from the filterable results controller, but the data stack is empty.
 *
 * This is a convenience method, as we're typically acting as the data source there is no simple way for your UITableViewController subclass to know
 * when the UITableView has requested data and there is none on the stack. This is called whenever -numberOfSectionsInTableView: is going to return zero.
 *
 * @param   controller              The UAFilterableResultsController that has no data.
 * @param   tableView               The UITableView that is loading (or re-loading) the table.
**/
- (void)filterableResultsController:(UAFilterableResultsController *)controller hasNoDataForLoadingTableView:(UITableView *)tableView;

/**
 * Informs your delegate that the specified collection view has requested data from the filterable results controller, but the data stack is empty.
 *
 * This is a convenience method, as we're typically acting as the data source there is no simple way for your UICollectionViewController subclass to know
 * when the UICollectionView has requested data and there is none on the stack. This is called whenever -numberOfSectionsInCollectionView: is going to return zero.
 *
 * @param   controller              The UAFilterableResultsController that has no data.
 * @param   collectionView          The UICollectionView that is loading (or re-loading).
**/
- (void)filterableResultsController:(UAFilterableResultsController *)controller hasNoDataForLoadingCollectionView:(UICollectionView *)collectionView;


/** @name Table and Collection View Changes **/

/**
 * Informs the delegate that the filterable results controller is about to change the structure of the data stack.
 *
 * @param   controller              The UAFilterableResultsController about to make the changes.
**/
- (void)filterableResultsControllerWillChangeContent:(UAFilterableResultsController *)controller;

/**
 * Informs the delegate that the filterable results controller is changing the object at the specified index path.
 *
 * @param   controller              The UAFilterableResultsController making the change.
 * @param   anObject                The object in the data stack that has changed.
 * @param   indexPath               The index path of the changed object (nil for insertions).
 * @param   type                    The change type. See UAFilterableResultsChangeType.
 * @param   newIndexPath            The destination path for the object when inserting or moving (nil for deletions and updates).
**/
- (void)filterableResultsController:(UAFilterableResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(UAFilterableResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath;

/**
 * Informs the delegate that the filterable results controller is changing a section at the specified index.
 *
 * @param   controller              The UAFilterableResultsController making the change.
 * @param   sectionIndex            The section that changed.
 * @param   type                    The type of change, either UAFilterableResultsChangeInsert or UAFilterableResultsChangeDelete.
**/
- (void)filterableResultsController:(UAFilterableResultsController *)controller didChangeSectionAtIndex:(NSInteger)sectionIndex forChangeType:(UAFilterableResultsChangeType)type;

/**
 * Informs the delegate that the filterable results controller has finished making changes and they should be committed to the table or collection view.
 *
 * @param   controller              The UAFilterableResultsController that made the changes.
**/
- (void)filterableResultsControllerDidChangeContent:(UAFilterableResultsController *)controller;


/**
 * Informs the delegate that it should reload its table or collection view.
 *
 * This is typically called when moving to or from an empty data stack. For performance reasons it is recommended that
 * you call -reloadData on your UITableView or UICollectionView at these times, however you can animate the changes if you
 * prefer.
 *
 * The UAFilterableResultsController will either call this method on your delegate, or else the individual change methods but not both
 * so you don't need to worry about mixing individual changes with a reload.
 *
 * @param   controller              The UAFilterableResultsController that wants you to reload, man.
**/
- (void)filterableResultsControllerShouldReload:(UAFilterableResultsController *)controller;

@end
