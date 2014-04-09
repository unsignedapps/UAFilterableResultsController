# UAFilterableResultsController

This is an implementation of a `NSFetchedResultsController`-style pattern using `NSMutableArray` as the backing store instead of Core Data. It provides methods for manipulation and filtering of the store.

You typically set the `-dataSource` property on your `UITableView` or `UICollectionView` to an instance of UAFilterableResultsController and then feed it changes. Like `NSFetchedResultsController`, this results controller will compute the differences in the data source and notify your `UITableView` or `UICollectionView`, allowing you to animate the changes.

## Overview

UAFilterableResultsController provides the following:

* A `NSMutableArray` based data source that you can manipulate.
* A `UITableViewDataSource` implementation.
* A `UICollectionViewDataSource` implementation.
* Support for applying `NSPredicate`-based filters on top of your data.
* All changes are computed and your delegate informed (like `NSFetchedResultsController`) so they can be animated.

## Supported Structures

UAFilterableResultsController supports two structural types:

### Two Dimension Arrays

This mirrors your typical section -> row/item setup that you use in your table or collection views. You can manipulate the objects directly, or entire sections.

### Single Dimension Arrays

If you supply a flat `NSArray` as your data source, the UAFilterableResultsController will inform the table or collection view that the structure is a single section with the `NSArray` as the rows or items within that view.

## Primary Keys

UAFilterableResultsController is designed to operate with data models and so works best with a primary key, but it functions perfectly fine without one.

If you supply a primary key, either through `-initWithPrimaryKeyPath:delegate:` or `-setPrimaryKeyPath:` it will attempt to perform all matching, replacing or merge operations using the value at the specified primary key path.

Say your data looks something like this:

```
- Employee
 |-- employeeID
 |-- firstName
 `-- lastName
```

After setting your initial data source, any calls to `-replaceObjects:` or `-mergeObjects:` would look for existing objects with the same `employeeID` and replace those.

If no Primary Key Path is specified, UAFilterableResultsController will just use `isEqual:` when determining equality.

## Installation

UAFilterableResultsController requires iOS6+. It has been tested against iOS6 but is only used regularly in iOS7-only production apps. It should work under OS X, but its usefulness is obviously diminished.

You can either install using [CocoaPods](http://cocoapods.org/) (search for UAFilterableResultsController) or by cloning this repo into your project.

Then import:

```objc
#import <UAFilterableResultsController/UAFilterableResultsController.h>
```

## Getting Started

Typically this is as creating an instance of the controller and assigning it as the data source to your table or collection view.

**Note: `UITableView` and `UICollectionView` do not retain their data source, so you will need to keep a strong reference to your UAFilterableResultsController around, usually as a strong property on your `UITableViewController` or `UICollectionViewController` subclass.**

Anyway, when using primary keys:

```objc
[self setResultsController:[[UAFilterableResultsController alloc] initWithPrimaryKeyPath:@"imageID" delegate:self]];
[self.tableView setDataSource:self.resultsController];
```

or when not using primary keys:

```objc
[self setResultsController:[[UAFilterableResultsController alloc] initWithDelegate:self]];
[self.collectionView setDataSource:self.resultsController];
```

Depending on how you load your views (to Storyboard or not to Storyboard, that is the question..) you'll want to stick these in your `-awakeFromNib`, `-initWithStyle:` or `-initWithCollectionViewLayout:` implementations as it is a good idea to set your `dataSource` before the table or collection views are loaded.

## Manipulating Data

UAFilterableResultsController provides a bunch of methods for manipulating your data arrays. A few are summarised below but check the full documentation for more.

### Manipulating Objects

#### -setData:(NSArray *)data

Sets (or replaces) the entire `NSMutableArray` contents with the supplied `data`. If your delegate is set it will be notified to reload its data, or animate the changes to the table or collection view as appropriate.

#### -addObject:(id)object

Appends an object to the data stack, either as the last object in the last section, or as the last object in the only section. If your delegate is set it will be notified to animate the changes to the table or collection view as appropriate.

#### -removeObject:(id)object

Removes the specified object from the data stack. If using the primary key path it will remove the object with the matching primary key value, otherwise the object that matches using `-isEqual:`. If your delegate is set it will be notified to animate the changes to the table or collection view as appropriate.

#### -replaceObject:(id)object

Replaces the specified object with the specified object, because that makes total sense. Actually, this is mostly used when you have a primary key path, as it will locate the object with the matching primary key value and replace it. If your delegate is set it will be notified to animate the changes to the table or collection view as appropriate.

#### Index Paths

It is worth noting that most of these operations have an index path equivalent, such as `-removeObjectAtIndexPath:` and `-replaceObjectAtIndexPath:withObject:`.

#### Merging

You can merge changes in if required. This is useful if you hit an API endpoint more than once and want to merge any changes in (say if you allow refreshing).

You can use `-mergeObjects:` and `-mergeObjects:sortComparator:` to accomplish this. If your delegate is set it will be notified to animate the changes to the table or collection view as appropriate.

If you don't supply a `NSSortComparator` any new objects will be appended to the data stack.

### Manipulating Sections

In addition to manipulating the individual objects you can manipulate entire sections.

`-addSection:`, `-insertSection:atIndex:`, `-removeSection:`, `-replaceSection:withSection:` and `-replaceSectionAtIndex:withSection:` exist for this purpose. As always, if your delegate is set it will be notified to animate the changes to the table or collection view as appropriate.

### Finding Objects

UAFilterableResultsController also supports searching the data stack for objects. You can use `-objectAtIndexPath:` or `-objectWithPrimaryKey:` for locating known objects, or `-indexPathOfObject:` or `-indexPathOfObjectWithPrimaryKey:` for finding the location of the objects within the data stack.

You can pull the entire data stack with `-data`, or all objects within the stack using `-allObjects`.

## Filtering

Filtering is a big part of UAFilterableResultsController, hence the name. You can easily supply a number of `NSPredicate`-based filters and have them automatically applied over the top of your data stack before it is presented to your table or collection view.

### UAFilter

A `UAFilter` object is a simple wrapper around an `NSPredicate` that allows for naming and grouping. Only one `UAFilter` object belonging to the same group will be applied, any new filters with the same group will replace the existing one.

You can create a `UAFilter` like so:

```objc
UAFilter *filter = [UAFilter filterWithTitle:@"Micro instances"
                                       group:@"Instance Types"
                                   predicate:[NSPredicate predicateWithFormat:@"instanceType BEGINSWITH[c] \"t1\""]];

[self.resultsController addFilter:filter];
```

The filter will be applied to the data stack and your delegate is informed any changes to the rows or items, allowing you to animate the changes as required.

### Manipulating Filters

Similar to objects, you can manipulate the filters applied to the data stack using `-addFilter:`, `-addFilters:`, and `-removeFilter:`.

You can use `-replaceFilters:` to remove all of the existing filters and apply the new filters, or `-clearFilters` to remove all filters. `-appliedFilters` will return an array of the currently applied filters.

### Searching

If you're using a UISearchBar and want to live-filter your results you can do so easily. Avoid using `UISearchDisplayController` here though as we don't always play nicely trying to work with more than one table or collection view.

Instead what you can do is hook your `UISearchBar` up to the UAFilterableResultsController and use its filtering:

```objc
// in your UISearchBarDelegate:

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
	UAFilter *filter = [UAFilter filterWithName:@"Search Results"
	                                      group:@"Search Results"
	                                  predicate:[NSPredicate predicateWithFormat:@"instanceName CONTAINS[c] %@", searchText]];
	[self.resultsController addFilter:filter];
}
```

From there, UAFilterableResultsController will take care of replacing the existing "Search Results" filter, computing the differences between the filtered data sets and informing your delegate of the changes so you can animate them in your table or collection view.

## Working With Table Views

Much like `NSFetchedResultsController`, you can rely on UAFilterableResultsController to help animate changes to your tables. You will also need to supply the cells, and section headers and footers, since these can't be calculated for you.

Make sure you set the `-delegate` on the UAFilterableResultsController instance, and then configure your delegate to (at minimum) supply the cell:

```objc
- (UITableViewCell *)filterableResultsController:(UAFilterableResultsController *)controller cellForItemWithObject:(id)object atIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"SomeIdentifier" forIndexPath:indexPath];
	
	// make magic

    return cell;
}
```

If you want to animate the changes in your table you're looking for something like this:

```objc
#pragma mark - UAFilterableResultsControllerDelegate Table Changes

- (void)filterableResultsControllerWillChangeContent:(UAFilterableResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)filterableResultsController:(UAFilterableResultsController *)controller didChangeSectionAtIndex:(NSInteger)sectionIndex forChangeType:(UAFilterableResultsChangeType)type
{
    switch (type)
    {
        case UAFilterableResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:(NSUInteger)sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case UAFilterableResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:(NSUInteger)sectionIndex] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        default:
            break;
    }
}

- (void)filterableResultsController:(UAFilterableResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(UAFilterableResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type)
    {
        case UAFilterableResultsChangeInsert:
            [self.tableView insertRowsAtIndexPaths:@[ newIndexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
            
        case UAFilterableResultsChangeDelete:
            // is the row deleted already selected?
            if ([[self.tableView indexPathForSelectedRow] isEqual:indexPath])
                [self.tableView deselectRowAtIndexPath:indexPath animated:NO];

            [self.tableView deleteRowsAtIndexPaths:@[ indexPath ] withRowAnimation:UITableViewRowAnimationAutomatic];
            
            break;
            
        case UAFilterableResultsChangeMove:
            [self.tableView moveRowAtIndexPath:indexPath toIndexPath:newIndexPath];
            break;
            
        case UAFilterableResultsChangeUpdate:
            [self tableView:self.tableView reloadCellAtIndexPath:indexPath withObject:anObject];
            break;
    }
}

// when the table should be reloaded (used when moving to/from no data situations)
- (void)filterableResultsControllerShouldReload:(UAFilterableResultsController *)controller
{
    [self.tableView reloadData];
}

// When the changes have been completed
- (void)filterableResultsControllerDidChangeContent:(UAFilterableResultsController *)controller
{
    [self.tableView endUpdates];
}
```

## Working with Collection Views

Working with `UICollectionView` is just as easy as for tables (yes, you can filter/search on Collection Views also).

You will need to supply the cells, as always, and optionally the supplementary views as these can't be calculated for you. You can animate the changes if you wish, though this is more complex than with Table Views.

Make sure you set the `-delegate` property on the UAFilterableResultsController instance and then configure your delegate to (at minimum) supply the cell:

```objc
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
	DSEC2AddressCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"SomeIdentifier" forIndexPath:indexPath];

	// make magic

    return cell;
}
```

As mentioned, animations are a bunch more work as you need to wrap these into a single call to `-performBatchUpdates:`.

I typically collect these into an `NSMutableArray` of blocks and execute them all in one go, like so:

```objc
// a void block that accepts nothing and returns nothing
typedef void(^BatchUpdateBlock)();

@interface MyViewController ()

// Used to collect the updates for the collection view
@property (nonatomic, strong) NSMutableArray *batchUpdates;

@end

@implementation MyViewController

@synthesize batchUpdates=_batchUpdates;

// .. skipping all the irrelevant stuff

#pragma mark - UAFilterableResultsControllerDelegate Collection View Changes

- (void)filterableResultsControllerWillChangeContent:(UAFilterableResultsController *)controller
{
    // start our batch updates array
    if (self.batchUpdates == nil)
        [self setBatchUpdates:[[NSMutableArray alloc] initWithCapacity:0]];
}

- (void)filterableResultsController:(UAFilterableResultsController *)controller didChangeSectionAtIndex:(NSInteger)sectionIndex forChangeType:(UAFilterableResultsChangeType)type
{
    __block MyViewController *blockSelf = self;
    BatchUpdateBlock block = NULL;
    
    switch (type)
    {
        case UAFilterableResultsChangeInsert:

            block = ^
            {
                [blockSelf.collectionView insertSections:[NSIndexSet indexSetWithIndex:(NSUInteger)sectionIndex]];
            };
            break;
            
        case UAFilterableResultsChangeDelete:

            block = ^
            {
                [blockSelf.collectionView deleteSections:[NSIndexSet indexSetWithIndex:(NSUInteger)sectionIndex]];
            };
            break;

        default:
            break;
    }
    
    if (block == NULL)
        return;
    
    if (self.batchUpdates != nil)
        [self.batchUpdates addObject:block];
    else
        block();
}

- (void)filterableResultsController:(UAFilterableResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(UAFilterableResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    __block MyViewController *blockSelf = self;
    BatchUpdateBlock block = NULL;
    
    switch (type)
    {
        case UAFilterableResultsChangeInsert:
        {
            block = ^
            {
                [blockSelf.collectionView insertItemsAtIndexPaths:@[ newIndexPath ]];
            };
            break;
        }
            
        case UAFilterableResultsChangeDelete:
        {
            block = ^
            {
                [blockSelf.collectionView deleteItemsAtIndexPaths:@[ indexPath ]];
            };
            
            break;
        }
            
        case UAFilterableResultsChangeMove:
        {
            block = ^
            {
                [blockSelf.collectionView moveItemAtIndexPath:indexPath toIndexPath:newIndexPath];
            };
            break;
        }

        case UAFilterableResultsChangeUpdate:
        {
            block = ^
            {
                [blockSelf.collectionView reloadItemsAtIndexPaths:@[ indexPath ]];
            };
            break;
        }
    }
    
    if (block == NULL)
        return;
    
    if (self.batchUpdates != nil)
        [self.batchUpdates addObject:block];
    else
        block();
}

- (void)filterableResultsControllerShouldReload:(UAFilterableResultsController *)controller
{
    [self.collectionView reloadData];
}

- (void)filterableResultsControllerDidChangeContent:(UAFilterableResultsController *)controller
{
    // if we have batch changes, apply them all now
    if (self.batchUpdates != nil)
    {
        [self.collectionView performBatchUpdates:^
        {
            for (BatchUpdateBlock block in blockSelf.batchUpdates)
                block();

        } completion:NULL];
    }
    [self setBatchUpdates:nil];
}
```

## Support

UAFilterableResultsController is provided as open source with no warranty and no guarantee of support. Best efforts are made to address [issues](https://github.com/unsignedapps/UAFilterableResultsController/issues) raised on GitHub.

You can email the author at bok@&lt;github username&gt;.com. Where <github username> should hopefully be apparent from the URL to this repo (https://github.com/unsignedapps/UAFilterableResultsController).

## Contributions

All contributions are welcome and greatly appreciated. Any pull requests will be considered, but remember that sometimes, if your requirements are specialised, it may be easier to just implement as a category.

## License

UAFilterableResultsController is released under a MIT license. See the `LICENSE` file for more.
