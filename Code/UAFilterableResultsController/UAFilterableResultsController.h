//
//  UAFilterableDataSource.h
//  Kestrel
//
//  Created by Rob Amos on 16/10/2013.
//  Copyright (c) 2013 Desto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UAFilterableResultsControllerDelegate.h"
#import "UAFilter.h"

/**
 * UAFilterableResultsController
 *
 * It acts as a UITableViewDataSource for a UITableView, or UICollectionViewDataSource for a UICollectionView.
 * You can supply a single or two dimensional NSArray as the data. Then assign an instance of this class as your
 * table or collection view's data source.
 *
 * It will instruct the table to layout sections and rows based on your supplied data.
 *
 * You can manipulate the data arrays and the UITableViewController/UICollectionViewController will be notified of the changes
 * via your supplied delegate, in a manner akin to NSFetchedResultsController.
 *
 * You can also provide non-destructive filters to the data using NSPredicates. The UITableView
 * is notified of the filtered changes via your delegate, allowing you to animate the application or
 * removal of the filters.
 *
 * Additionally, if you specify the primaryKeyPath, UAFilterableResultsController will attempt to complete operations
 * by comparing the value at the specified key path, instead of using raw isEqual:.
**/
@interface UAFilterableResultsController : NSObject

/** @name Initialisation **/

/**
 * A Key Path to the property or method that supplies the primary key for your data.
 *
 * When merging objects in, UAFilterableResultsController will use this key path to determine
 * equality between the two objects, that is, they are considered equal if the value returned
 * by this kay path matches. Set this to nil to rely purely on isEqual:.
**/
@property (nonatomic, strong) NSString *primaryKeyPath;

/**
 * Your delegate method.
 *
 * You must supply a delegate which implements the <UAFilterableResultsControllerDelegate> protocol whenever
 * you want to use the UAFilterableResultsController as a data source for a table or collection view.
 *
 * This delegate is notified of changes to the data similarly to NSFetchedResultsController. It is also
 * asked for UITableViewDataSource/UICollectionViewDataSource methods that we are unable to provide, such as
 * filterableResultsController:cellForItemWithObject:atIndexPath:.
**/
@property (nonatomic, weak) id<UAFilterableResultsControllerDelegate> delegate;

/**
 * Initialises the UAFilterableResultsController with a key path to determine the primary key, and a delegate.
 *
 * @param   primaryKeyPath          The key path applied to each object to determine it's primary key. See -primaryKeyPath for more information.
 * @param   delegate                An object that implements <UAFilterableResultsControllerDelegate>.
 * @returns                         Initialised UAFilterableResultsController object.
**/
- (id)initWithPrimaryKeyPath:(NSString *)primaryKeyPath delegate:(id<UAFilterableResultsControllerDelegate>)delegate;

/**
 * Initialises the UAFilterableResultsController with a delegate.
 *
 * @param   delegate                An object that implements <UAFilterableResultsControllerDelegate>.
 * @returns                         Initialised UAFilterableResultsController object.
**/
- (id)initWithDelegate:(id<UAFilterableResultsControllerDelegate>)delegate;


/** @name Manipulating Objects **/

/**
 * Replaces the entire data array with the supplied data.
 *
 * Changes between the existing data and the new data will be tracked.
 *
 * Your delegate (if set) will be notified to:
 *  - if there is a nil existing data set, to reload the table or collection view;
 *  - otherwise, of any individual changes, allowing you to animate them as required.
 *
 * Any filters that have been applied to the existing data will be re-applied to the new data.
 *
 * @param   data                    A one or two dimensional array of data objects.
**/
- (void)setData:(NSArray *)data;

/**
 * Returns the data arrays as are they currently used without any applied filters.
**/
- (NSArray *)data;

/**
 * Returns all of the objects in the data arrays as a flattened one dimensional array.
**/
- (NSArray *)allObjects;

/**
 * Adds an object to the data arrays.
 *
 * If you are using two dimensional arrays the object will be added to the last existing section, for one dimensional
 * arrays it will be added to the end of the array.
 *
 * The delegate will be notified of the addition of the object, allowing you to animate the changes to your table or collection view.
 *
 * @param   object                  An object to be added to the arrays.
**/
- (void)addObject:(id)object;

/**
 * Adds an object to the specified section.
 *
 * If you are using two dimensional arrays the object is added to the section as specified. For one dimensional arrays
 * the section value is ignored.
 *
 * The delegate will be notified of the addition of the object, allowing you to animate the changes to your table or collection view.
 *
 * @param   object                  An object to be added to the arrays.
**/
- (void)addObject:(id)object inSection:(NSInteger)sectionIndex;

/**
 * Removes an object from the array.
 *
 * Nothing happens if the object cannot be found.
 *
 * The delegate will be notified of the removal of the object, allowing you to animate the changes to your table or collection view.
 *
 * @param   object                  An object to be removed from the arrays.
**/
- (void)removeObject:(id)object;

/**
 * Removes an object with the primary key.
 *
 * Nothing happens if the object cannot be found or there is no private keys.
 *
 * The delegate will be notified of the removal of the object, allowing you to animate the changes to your table or collection view.
 *
 * @param   primaryKey                  A primary key.
**/
- (void)removeObjectWithPrimaryKey:(NSString *)primaryKey;

/**
 * Removes the object at the specified index paths from the array.
 *
 * If you are using two dimensional arrays the object will be removed exactly as specified. For one dimensional arrays
 * the section value will be ignored and the object at the specified row will be removed.
 *
 * The delegate will be notified of the removal of the object, allowing you to animate the changes to your table or collection view.
 *
 * @param   indexPath               An NSIndexPath to the object you want to be removed.
**/
- (void)removeObjectAtIndexPath:(NSIndexPath *)indexPath;

/**
 * Replaces the specified object with an updated version.
 *
 * If the specified object cannot be found in the arrays nothing will happen. The -primaryKeyPath will
 * be used to locate an existing object with the same primary key.
 *
 * The delegate will be notified of the replacement of the object, allowing you to animate the changes to your table or collection view.
 *
 * @param   anObject                The object to be replaced.
 **/
- (void)replaceObject:(id)anObject;

/**
 * Replaces the specified object with the new object.
 *
 * If the specified object cannot be found in the arrays nothing will happen. If supplied, the -primaryKeyPath will
 * be used to locate an existing object with the same primary key, otherwise isEqual: will used to determine equality.
 *
 * The delegate will be notified of the replacement of the object, allowing you to animate the changes to your table or collection view.
 *
 * @param   anObject                The object to be replaced.
 * @param   anotherObject           The object to replace it with.
**/
- (void)replaceObject:(id)anObject withObject:(id)anotherObject;

/**
 * Replaces the object at the specified index path with the new object.
 *
 * If supplied, the -primaryKeyPath will be used to locate an existing object with the same primary key, otherwise isEqual:
 * will be used to determine equality.
 *
 * The delegate will be notified of the replacement of the object, allowing you to animate the changes to your table or collection view.
 *
 * @param   indexPath               An NSIndexPath to the object you want to be replaced.
 * @param   newObject               The object to replace it with.
**/
- (void)replaceObjectAtIndexPath:(NSIndexPath *)indexPath withObject:(id)newObject;

/**
 * Replaces the existing matching objects in the array with the supplied objects.
 *
 * If supplied, the -primaryKeyPath will be used to locate an existing object with the same primary key, otherwise isEqual:
 * will be used to determine equality.
 *
 * This method is particularly useful for merging in changes to known objects from an external data source that have since
 * changed. The existing objects with the same primary key will be replaced with the ones in this array.
 *
 * Objects in the supplied array that cannot be found in the existing data arrays will be ignored. (Use -mergeObjects:
 * if you want new objects to be added instead.)
 *
 * The delegate will be notified of the replacement of the objects, allowing you to animate the changes to your table or collection view.
 *
 * @param   arrayOfObjects          An NSArray of objects.
**/
- (void)replaceObjects:(NSArray *)arrayOfObjects;

/**
 * Merges the existing matching objects in the array with the supplied objects.
 *
 * If supplied, the -primaryKeyPath will be used to locate an existing object with the same primary key, otherwise isEqual:
 * will be used to determine equality.
 *
 * This method is particularly useful for merging in changes to known objects from an external data source that have since
 * changed. The existing objects with the same primary key will be replaced with the ones in this array.
 *
 * Objects in the supplied array that cannot be found in the existing data arrays will be added to the end of the arrays.
 * (Use -replaceObjects: if you want new objects to be ignored instead.)
 *
 * The delegate will be notified of the replacement of the objects, allowing you to animate the changes to your table or collection view.
 *
 * @param   arrayOfObjects          An NSArray of objects.
**/
- (void)mergeObjects:(NSArray *)arrayOfObjects;

/**
 * Merges the existing matching objects in the array with the supplied objects.
 *
 * If supplied, the -primaryKeyPath will be used to locate an existing object with the same primary key, otherwise isEqual:
 * will be used to determine equality.
 *
 * This method is particularly useful for merging in changes to known objects from an external data source that have since
 * changed. The existing objects with the same primary key will be replaced with the ones in this array.
 *
 * Objects will be sorted using the supplied comparator during the merge, so new objects will be added in the appropriate
 * place in the sorted array. (Use -replaceObjects: if you want new objects to be ignored instead.)
 *
 * The delegate will be notified of the changes to the objects, allowing you to animate the changes to your table or collection view.
 *
 * @param   arrayOfObjects          An NSArray of objects.
 * @param   comparator              A NSComparator object used to sort the objects.
**/
- (void)mergeObjects:(NSArray *)arrayOfObjects sortComparator:(NSComparator)comparator;


/** @name Finding Objects **/

/**
 * Returns the object at the specified index path.
 *
 * This uses the raw data and not the filtered data, and so the index path here may be different from that supplied to your
 * table or collection views if you are using filters.
 *
 * If you're using one dimensional arrays the section value will be ignored and the object at the specified row
 * will be returned. For two dimensional arrays the object will be returned from the index path as specified.
 *
 * @param   indexPath               The NSIndexPath to the object that you want to find.
 * @returns                         The specified object. Triggers an out of bounds exception if the index path is not valid.
**/
- (id)objectAtIndexPath:(NSIndexPath *)indexPath;

/**
 * Returns the object at the specified index path of the filtered data.
 *
 * This uses the filtered data, not the raw data, and should reflect the index path as supplied to your table or collection views.
 *
 * If you're using one dimensional arrays the section value will be ignored and the object at the specified row
 * will be returned. For two dimensional arrays the object will be returned from the index path as specified.
 *
 * @param   indexPath               The NSIndexPath to the object that you want to find.
 * @returns                         The specified object. Triggers an out of bounds exception if the index path is not valid.
**/
- (id)filteredObjectAtIndexPath:(NSIndexPath *)indexPath;

/**
 * Returns the object that has the specified primary key.
 *
 * Searches the raw data arrays (not the filtered data) for the object whose -valueAtKeyPath: matches the supplied primary key.
 * The -primaryKeyPath is used for the comparison. An assertion will be thrown if you have not specified a -primaryKeyPath.
 *
 * The first match will be returned, multiple objects with the same primary key cause undefined behaviour.
 *
 * @param   primaryKey              The primary key that should match the
 * @returns                         The matching object, or nil if not found.
**/
- (id)objectWithPrimaryKey:(id)primaryKey;

/**
 * Searches the data arrays for the specified object and returns its index path.
 *
 * If supplied, the -primaryKeyPath will be used to locate an existing object with the same primary key as the supplied object,
 * otherwise isEqual: will be used to determine equality.
 *
 * @param   object                  An object to search for.
 * @returns                         An NSIndexPath to the specified object, or nil if the object cannot be found.
**/
- (NSIndexPath *)indexPathOfObject:(id)object;

/**
 * Searches the data arrays for the object with the specified primary key and returns the object at that tndex path.
 *
 * Searches the raw data arrays (not the filtered data) for the object whose -valueAtKeyPath: matches the supplied primary key.
 * The -primaryKeyPath is used for the comparison. An assertion will be thrown if you have not specified a -primaryKeyPath.
 *
 * @param   key                     The primary key value to search for.
 * @returns                         An NSIndexPath to the specified object, or nil if the object cannot be found.
**/
- (NSIndexPath *)indexPathOfObjectWithPrimaryKey:(id)key;

/** @name Manipulating Sections **/

/**
 * Adds the specified section to the end of the array.
 *
 * You cannot add sections to one dimensional arrays.
 *
 * The delegate will be notified of the adding of the section, allowing you to animate the changes to your table or collection view.
 *
 * @param   section                 An NSArray of objects.
**/
- (void)addSection:(NSArray *)section;

/**
 * Inserts the specified section to the specified index of the array.
 *
 * You cannot inserts sections to one dimensional arrays.
 *
 * The delegate will be notified of the adding of the section, allowing you to animate the changes to your table or collection view.
 *
 * @param   section                 An NSArray of objects.
 **/
- (void)insertSection:(NSArray *)section atIndex:(NSUInteger)index;

/**
 * Removes the specified section from the array.
 *
 * You cannot remove sections from one dimensional arrays.
 *
 * The delegate will be notified of the removal of the section, allowing you to animate the changes to your table or collection view.
 *
 * @param   section                 An NSArray of objects. Should match an existing section.
**/
- (void)removeSection:(NSArray *)section;

/**
 * Replaces the specified section with a new section.
 *
 * You cannot replace sections in one dimensional arrays.
 *
 * The delegate will be notified of the replacement of the section, allowing you to animate the changes to your table or collection view.
 *
 * @param   oldSection              An existing section NSArray.
 * @param   newSection              A new NSAray of objects to replace it with.
**/
- (void)replaceSection:(NSArray *)oldSection withSection:(NSArray *)newSection;

/**
 * Replaces the section at the specified index with the new one supplied.
 *
 * You cannot replace sections in one dimensional arrays.
 *
 * The delegate will be notified of the replacement of the section, allowing you to animate the changes to your table or collection view.
 *
 * @param   sectionIndex            The index of an existing section.
 * @param   newSection              A new NSArray of objects to replace it with.
**/
- (void)replaceSectionAtIndex:(NSInteger)sectionIndex withSection:(NSArray *)newSection;

/** @name Filtering **/

/**
 * Adds a filter to the list of applied filers.
 *
 * If there is an existing filter with the same group it will be replaced.
 *
 * A new data set will be made available to the UITableView based on all of the applied filters.
 *
 * The delegate will be notified of the changes to the data set, allowing you to animate the changes to your table or collection view.
 *
 * @param   filter                  The DSFilter instance to add.
**/
- (void)addFilter:(UAFilter *)filter;

/**
 * Adds multiple filters to the list of applied filters.
 *
 * If there are existing filters with the same group names they will be replaced.
 *
 * A new data set will be made available to the UITableView based on all of the applied filters.
 *
 * The delegate will be notified of the changes to the data set, allowing you to animate the changes to your table or collection view.
 *
 * @param   filters                 An NSArray of DSFilter objects.
**/
- (void)addFilters:(NSArray *)filters;

/**
 * Removes the specified filter from the list of applied filters.
 *
 * A new data set will be made available to the UITableView based on the remaining filters.
 *
 * The delegate will be notified of the changes to the data set, allowing you to animate the changes to your table or collection view.
 *
 * @param   filter                  The DSFilter instance to remove.
**/
- (void)removeFilter:(UAFilter *)filter;

/**
 * Replaces the existing filters with the supplied filters.
 *
 * A new data set will be made available to the UITableView based on all of the newly applied filters.
 *
 * The delegate will be notified of the changes to the data set, allowing you to animate the changes to your table or collection view.
 *
 * @param   filters                 An NSArray of DSFilter objects.
**/
- (void)replaceFilters:(NSArray *)filters;

/**
 * Removes all of the existing filters.
 *
 * The delegate will be notified of the changes to the data set, allowing you to animate the changes to your table or collection view.
**/
- (void)clearFilters;

/**
 * Returns all of the existing filters.
**/
- (NSArray *)appliedFilters;

@end
