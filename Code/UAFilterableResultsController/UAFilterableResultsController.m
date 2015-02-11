//
//  UAFilterableDataSource.m
//  Kestrel
//
//  Created by Rob Amos on 16/10/2013.
//  Copyright (c) 2013 Desto. All rights reserved.
//

#import "UAFilterableResultsControllerClass.h"
#import "NSArray+UAArrayFlattening.h"

#pragma mark Private Methods

@interface UAFilterableResultsController ()

@property (nonatomic, strong) NSMutableArray *UAData;
@property (nonatomic) BOOL tableViewHasLoaded;
@property (nonatomic) NSInteger changeBatches;

@property (nonatomic, strong) NSMutableArray *UAAppliedFilters;
@property (nonatomic, strong) NSMutableArray *filteredData;

@property (nonatomic, strong) NSMutableDictionary *indexPathNotificationMapping;

- (BOOL)isArrayTwoDimensional:(NSArray *)array;

- (BOOL)isObject:(id)object equalToObject:(id)object usingKeyPath:(NSString *)keyPath;

- (NSIndexPath *)indexPathOfObject:(id)object inArray:(NSArray *)data;
- (NSIndexPath *)indexPathOfObjectWithPrimaryKey:(id)key inArray:(NSArray *)data;

- (void)notifyBeginChanges;
- (void)notifyChangedObject:(id)object atIndexPath:(NSIndexPath *)indexPath forChangeType:(UAFilterableResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath;
- (void)notifyChangedSectionAtIndex:(NSInteger)sectionIndex forChangeType:(UAFilterableResultsChangeType)type;
- (void)notifyReload;
- (void)notifyEndChanges;
- (void)notifyEndChangesButDontReapplyFilters;
- (void)notifyForChangesFrom:(NSArray *)fromArray to:(NSArray *)toArray;

- (void)reapplyFilters;
- (void)applyFilters:(NSArray *)array;

- (BOOL)isFiltered;

@end

#pragma mark - Implementation

@implementation UAFilterableResultsController

@synthesize primaryKeyPath=_primaryKeyPath, delegate=_delegate, UAData=_UAData, changeBatches=_changeBatches, UAAppliedFilters=_UAAppliedFilters;

// Initialisation
- (id)initWithPrimaryKeyPath:(NSString *)primaryKeyPath delegate:(id<UAFilterableResultsControllerDelegate>)delegate
{
    if ((self = [self init]))
    {
        [self setPrimaryKeyPath:primaryKeyPath];
        [self setDelegate:delegate];
        [self setTableViewHasLoaded:NO];
        [self setChangeBatches:0];
        [self setUAAppliedFilters:[[NSMutableArray alloc] initWithCapacity:0]];
    }
    return self;
}

- (id)initWithDelegate:(id<UAFilterableResultsControllerDelegate>)delegate
{
    if ((self = [self init]))
    {
        [self setDelegate:delegate];
        [self setTableViewHasLoaded:NO];
        [self setChangeBatches:0];
        [self setUAAppliedFilters:[[NSMutableArray alloc] initWithCapacity:0]];
    }
    return self;
}

#pragma mark - Object Manipulation

- (void)setData:(NSArray *)data
{
    BOOL hasExistingData = self.UAData != nil;
    BOOL isFiltered = [self isFiltered];
    
    // nil'ing out the data?
    if (data == nil)
    {
        [self setUAData:nil];
        [self setFilteredData:nil notifications:NO];

        // notify if there used to be data to delete all of the data
        if (hasExistingData)
        {
            [self notifyReload];
            [self setTableViewHasLoaded:NO];
        }
        return;
    }
    
    // if its 2D, make it mutable on both levels
    if ([self isArrayTwoDimensional:data])
    {
        NSMutableArray *replacementData = [[NSMutableArray alloc] initWithCapacity:[data count]];
        for (NSArray *section in data)
            [replacementData addObject:[[NSMutableArray alloc] initWithArray:section]];

        if (hasExistingData)
        {
            [self notifyBeginChanges];

            if (!isFiltered)
                [self notifyForChangesFrom:self.UAData to:replacementData];

            [self setUAData:replacementData];
            [self notifyEndChanges];
        } else
        {
            [self setUAData:replacementData];
            [self reapplyFiltersWithoutNotifying];
            [self notifyReload];
        }

        replacementData = nil;

    // straight array
    } else
    {
        if (hasExistingData)
        {
            [self notifyBeginChanges];

            NSMutableArray *existingData = self.UAData;
            [self setUAData:[data mutableCopy]];

            if (!isFiltered)
                [self notifyForChangesFrom:existingData to:self.UAData];

            [self notifyEndChanges];
        } else
        {
            [self setUAData:[data mutableCopy]];
            [self reapplyFiltersWithoutNotifying];
            [self notifyReload];
        }
    }
}

- (void)setData:(NSArray *)arrayOfObjects sortComparator:(NSComparator)comparator
{
    if (comparator == NULL)
        [self setData:arrayOfObjects];
    else
        [self setData:[arrayOfObjects sortedArrayUsingComparator:comparator]];
}

- (void)setData:(NSArray *)arrayOfObjects sortKeyPath:(NSString *)sortKeyPath sortOptions:(NSStringCompareOptions)options
{
    [self setData:arrayOfObjects sortComparator:^NSComparisonResult(id obj1, id obj2)
    {
        id value1 = [obj1 valueForKeyPath:sortKeyPath];
        id value2 = [obj2 valueForKeyPath:sortKeyPath];
        return [value1 compare:value2 options:options];
    }];
}

- (NSArray *)data
{
    return self.UAData;
}

- (void)setFilteredData:(NSMutableArray *)filteredData
{
    [self setFilteredData:filteredData notifications:YES];
}

- (void)setFilteredData:(NSMutableArray *)filteredData notifications:(BOOL)notifications
{
    if (!notifications)
    {
        _filteredData = filteredData;
        return;
    }

    // adding or changing a filter
    if (filteredData != nil)
    {
        // changing from unfiltered data to filtered data
        if (_filteredData == nil)
        {
            [self notifyBeginChanges];
            [self notifyForChangesFrom:self.UAData to:filteredData];
            _filteredData = filteredData;
            [self notifyEndChangesButDontReapplyFilters];

        // changing from filtered to filtered
        } else
        {
            [self notifyBeginChanges];
            NSMutableArray *oldFiltered = _filteredData;
            _filteredData = filteredData;
            [self notifyForChangesFrom:oldFiltered to:filteredData];
            [self notifyEndChangesButDontReapplyFilters];
        }

    // removing a filter
    } else if (_filteredData != nil)
    {
        [self notifyBeginChanges];
        [self notifyForChangesFrom:_filteredData to:self.UAData];
        _filteredData = nil;
        [self notifyEndChangesButDontReapplyFilters];
    }
    
    // the fourth is nil to nil, do nothing!
}

- (BOOL)isFiltered
{
    return self.appliedFilters != nil && [self.appliedFilters count] > 0 && self.filteredData != nil;
}

- (NSArray *)allObjects
{
    if ([self isArrayTwoDimensional:self.UAData])
        return [self.UAData UAFlattenedArray];
    return self.UAData;
}

- (void)addObject:(id)object
{
    NSAssert(self.UAData != nil, @"Cannot add object to nil data.");
    NSParameterAssert(object != nil);
    
    [self addObject:object inSection:-1];
}

- (void)addObject:(id)object inSection:(NSInteger)sectionIndex
{
    NSAssert(self.UAData != nil, @"Cannot add object to nil data.");
    NSParameterAssert(object != nil);
    
    [self notifyBeginChanges];
    
    // add it to the bottom of the last section if we're 2D
    if ([self isArrayTwoDimensional:self.UAData])
    {
        NSMutableArray *section = sectionIndex == -1 ? [self.UAData lastObject] : [self.UAData objectAtIndex:(NSUInteger)sectionIndex];
        [section addObject:object];

        if (![self isFiltered])
            [self notifyChangedObject:object atIndexPath:nil
                        forChangeType:UAFilterableResultsChangeInsert
                         newIndexPath:[NSIndexPath indexPathForRow:((NSInteger)[section count]-1) inSection:(sectionIndex == -1 ? [self.UAData count]-1 : sectionIndex)]];
        
    } else
    {
        [self.UAData addObject:object];
        
        if (![self isFiltered])
            [self notifyChangedObject:object atIndexPath:nil
                        forChangeType:UAFilterableResultsChangeInsert
                         newIndexPath:[NSIndexPath indexPathForRow:((NSInteger)[self.UAData count]-1) inSection:0]];
    }
    
    
    [self notifyEndChanges];
}

- (void)removeObject:(id)object
{
    NSAssert(self.UAData != nil, @"Cannot remove object from nil data.");
    NSParameterAssert(object != nil);

    NSIndexPath *indexPath = [self indexPathOfObject:object];
    if (indexPath != nil)
        [self removeObjectAtIndexPath:indexPath];
}

- (void)removeObjectAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(self.UAData != nil, @"Cannot remove object from nil data.");
    NSParameterAssert(indexPath != nil);
    
    [self notifyBeginChanges];
    
    // find the section and remove the item at that index
    NSMutableArray *section = ([self isArrayTwoDimensional:self.UAData] ? [self.UAData objectAtIndex:(NSUInteger)indexPath.section] : self.UAData);
    id oldObject = [section objectAtIndex:(NSUInteger)indexPath.row];
    [section removeObjectAtIndex:(NSUInteger)indexPath.row];
    
    // notify
    if (![self isFiltered])
        [self notifyChangedObject:oldObject
                      atIndexPath:indexPath
                    forChangeType:UAFilterableResultsChangeDelete
                     newIndexPath:nil];

    [self notifyEndChanges];
}

- (void)removeObjectWithPrimaryKey:(NSString *)primaryKey
{
    NSAssert(self.UAData != nil, @"Cannot remove object from nil data.");
    NSParameterAssert(primaryKey != nil);
    
    // find the object
    NSIndexPath *indexPath = [self indexPathOfObjectWithPrimaryKey:primaryKey inArray:self.UAData];
    if (indexPath != nil)
        [self removeObjectAtIndexPath:indexPath];
}

- (void)replaceObject:(id)anObject
{
    NSAssert(self.UAData != nil, @"Cannot replace object in nil data.");
    NSParameterAssert(anObject != nil);
    
    // find the object
    NSIndexPath *indexPath = [self indexPathOfObject:anObject];
    if (indexPath != nil)
        [self replaceObjectAtIndexPath:indexPath withObject:anObject];
}

- (void)replaceObject:(id)oldObject withObject:(id)newObject
{
    NSAssert(self.UAData != nil, @"Cannot replace object in nil data.");
    NSParameterAssert(oldObject != nil);
    NSParameterAssert(newObject != nil);

    // find the object
    NSIndexPath *indexPath = [self indexPathOfObject:oldObject];
    if (indexPath != nil)
        [self replaceObjectAtIndexPath:indexPath withObject:newObject];
}

- (void)replaceObjectAtIndexPath:(NSIndexPath *)indexPath withObject:(id)newObject
{
    NSAssert(self.UAData != nil, @"Cannot replace object in nil data.");
    NSParameterAssert(indexPath != nil);
    NSParameterAssert(newObject != nil);

    [self notifyBeginChanges];

    // 2D Arrays
    NSMutableArray *data = self.UAData;
    if ([self isArrayTwoDimensional:data])
    {
        NSMutableArray *section = [data objectAtIndex:(NSUInteger)indexPath.section];
        [section replaceObjectAtIndex:(NSUInteger)indexPath.row withObject:newObject];
        
        if (![self isFiltered])
            [self notifyChangedObject:newObject
                          atIndexPath:indexPath
                        forChangeType:UAFilterableResultsChangeUpdate
                         newIndexPath:indexPath];

    } else
    {
        [data replaceObjectAtIndex:(NSUInteger)indexPath.row withObject:newObject];

        if (![self isFiltered])
            [self notifyChangedObject:newObject
                          atIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]
                        forChangeType:UAFilterableResultsChangeUpdate
                         newIndexPath:[NSIndexPath indexPathForRow:indexPath.row inSection:0]];
    }
    
    [self notifyEndChanges];
}

- (void)replaceObjects:(NSArray *)arrayOfObjects
{
    NSParameterAssert(arrayOfObjects != nil);

    [self notifyBeginChanges];
    for (id object in arrayOfObjects)
        [self replaceObject:object];
    [self notifyEndChanges];
}

- (void)mergeObjects:(NSArray *)arrayOfObjects
{
    [self mergeObjects:arrayOfObjects sortComparator:nil];
}

- (void)mergeObjects:(NSArray *)arrayOfObjects sortComparator:(NSComparator)comparator
{
    // not sorting
    if (comparator == nil)
    {

        // if the existing data is nil just set it
        if (self.UAData == nil)
            [self setData:arrayOfObjects];
        
        else
        {
            [self notifyBeginChanges];

            for (id object in arrayOfObjects)
            {
                if ([self indexPathOfObject:object] != nil)
                    [self replaceObject:object];
                else
                    [self addObject:object];
            }
            [self notifyEndChanges];
        }


    // more complex if sorting (setData: will handle the notifications)
    } else
    {
        NSMutableArray *data = self.UAData ? [self.UAData mutableCopy] : [NSMutableArray array];
        for (id object in arrayOfObjects)
        {
            NSIndexPath *indexPath = [self indexPathOfObject:object inArray:data];
            if (indexPath != nil)
                [data replaceObjectAtIndex:(NSUInteger)indexPath.row withObject:object];
            else
                [data addObject:object];
        }
        [self setData:[data sortedArrayUsingComparator:comparator]];
    }
}

- (void)mergeObjects:(NSArray *)arrayOfObjects sortKeyPath:(NSString *)sortKeyPath sortOptions:(NSStringCompareOptions)options
{
    [self mergeObjects:arrayOfObjects sortComparator:^NSComparisonResult(id obj1, id obj2)
    {
        id value1 = [obj1 valueForKeyPath:sortKeyPath];
        id value2 = [obj2 valueForKeyPath:sortKeyPath];
        return [value1 compare:value2 options:options];
    }];
}

- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.UAData == nil)
        return nil;

    NSParameterAssert(indexPath != nil);

    // 2D Arrays
    NSArray *data = self.UAData;
    if ([self isArrayTwoDimensional:data])
    {
        NSArray *section = [data objectAtIndex:(NSUInteger)indexPath.section];
        
        if ((NSUInteger)indexPath.row >= [section count])
            return nil;
        
        return [section objectAtIndex:(NSUInteger)indexPath.row];

    // Plain array
    } else if ((NSUInteger)indexPath.row < [data count])
        return [data objectAtIndex:(NSUInteger)indexPath.row];
    
    return nil;
}

- (id)filteredObjectAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.filteredData == nil)
        return [self objectAtIndexPath:indexPath];

    NSParameterAssert(indexPath != nil);
    
    // 2D Arrays
    NSArray *data = self.filteredData;
    if ([self isArrayTwoDimensional:data])
    {
        if (indexPath.section >= [data count])
            return nil;
        NSArray *section = [data objectAtIndex:(NSUInteger)indexPath.section];
        
        if (indexPath.row >= [section count])
            return nil;

        return [section objectAtIndex:(NSUInteger)indexPath.row];
        
    // Plain array
    } else
        return [data objectAtIndex:(NSUInteger)indexPath.row];
}

- (id)objectWithPrimaryKey:(id)primaryKey
{
    NSAssert(self.UAData != nil, @"Cannot find object in nil data.");
    NSAssert(self.primaryKeyPath != nil, @"Cannot find object using nil primary key path.");
    NSParameterAssert(primaryKey != nil);
    
    // 2D Arrays
    NSArray *data = self.UAData;
    if ([self isArrayTwoDimensional:data])
    {
        for (NSUInteger sectionCounter = 0; sectionCounter < [data count]; sectionCounter++)
        {
            NSArray *section = [data objectAtIndex:sectionCounter];
            for (NSUInteger rowCounter = 0; rowCounter < [section count]; rowCounter++)
            {
                id obj = [section objectAtIndex:rowCounter];
                id value = [obj valueForKeyPath:self.primaryKeyPath];
                if (value != nil && [primaryKey isEqual:value])
                    return obj;
            }
        }
        
        // Plain array
    } else
    {
        for (NSUInteger rowCounter = 0; rowCounter < [data count]; rowCounter++)
        {
            id obj = [data objectAtIndex:rowCounter];
            id value = [obj valueForKeyPath:self.primaryKeyPath];
            if (value != nil && [primaryKey isEqual:value])
                return obj;
        }
    }
    
    // not found
    return nil;
}

- (NSIndexPath *)indexPathOfObject:(id)object
{
    return [self indexPathOfObject:object inArray:self.UAData];
}

- (NSIndexPath *)filteredIndexPathOfObject:(id)object
{
    return [self indexPathOfObject:object inArray:(self.filteredData ?: self.UAData)];
}

- (NSIndexPath *)indexPathOfObject:(id)object inArray:(NSArray *)data
{
    return [self indexPathOfObject:object inArray:data usingKeyPath:self.primaryKeyPath];
}

- (NSIndexPath *)indexPathOfObject:(id)object inArray:(NSArray *)data usingKeyPath:(NSString *)keyPath
{
    if (data == nil)
        data = self.UAData;

    NSAssert(data != nil, @"Cannot find index path of object in nil data.");
    NSParameterAssert(object != nil);

    // 2D Arrays
    if ([self isArrayTwoDimensional:data])
    {
        for (NSUInteger sectionCounter = 0; sectionCounter < [data count]; sectionCounter++)
        {
            NSArray *section = [data objectAtIndex:sectionCounter];
            for (NSUInteger rowCounter = 0; rowCounter < [section count]; rowCounter++)
            {
                id obj = [section objectAtIndex:rowCounter];
                if ([self isObject:obj equalToObject:object usingKeyPath:keyPath])
                    return [NSIndexPath indexPathForRow:(NSInteger)rowCounter inSection:(NSInteger)sectionCounter];
            }
        }

    // Plain array
    } else
    {
        for (NSUInteger rowCounter = 0; rowCounter < [data count]; rowCounter++)
        {
            id obj = [data objectAtIndex:rowCounter];
            if ([self isObject:obj equalToObject:object usingKeyPath:keyPath])
                return [NSIndexPath indexPathForRow:(NSInteger)rowCounter inSection:0];
        }
    }
    
    // not found
    return nil;
}

- (NSUInteger)indexOfObject:(id)object inArray:(NSArray *)data usingKeyPath:(NSString *)keyPath
{
    for (NSUInteger rowCounter = 0; rowCounter < [data count]; rowCounter++)
    {
        id obj = [data objectAtIndex:rowCounter];
        if ([self isObject:obj equalToObject:object usingKeyPath:keyPath])
            return rowCounter;
    }
    return NSNotFound;
}

- (NSIndexPath *)indexPathOfObjectWithPrimaryKey:(id)key
{
    return [self indexPathOfObjectWithPrimaryKey:key inArray:self.UAData];
}

- (NSIndexPath *)filteredIndexPathOfObjectWithPrimaryKey:(id)key
{
    return [self indexPathOfObjectWithPrimaryKey:key inArray:(self.filteredData ?: self.UAData)];
}

- (NSIndexPath *)indexPathOfObjectWithPrimaryKey:(id)key inArray:(NSArray *)data
{
    if (self.primaryKeyPath == nil)
        return nil;
    NSString *keyPath = self.primaryKeyPath;

    if (data == nil)
        data = self.UAData;
    
    NSAssert(data != nil, @"Cannot find index path of object in nil data.");
    NSAssert(self.primaryKeyPath != nil, @"Cannot find object using nil primary key path.");
    NSParameterAssert(key != nil);
    
    @try
    {
    
        // 2D Arrays
        if ([self isArrayTwoDimensional:data])
        {
            for (NSUInteger sectionCounter = 0; sectionCounter < [data count]; sectionCounter++)
            {
                NSArray *section = [data objectAtIndex:sectionCounter];
                for (NSUInteger rowCounter = 0; rowCounter < [section count]; rowCounter++)
                {
                    id obj = [section objectAtIndex:rowCounter];
                    id aValue = [obj valueForKeyPath:keyPath];
                    if ([aValue isEqual:key])
                        return [NSIndexPath indexPathForRow:(NSInteger)rowCounter inSection:(NSInteger)sectionCounter];
                }
            }
            
            // Plain array
        } else
        {
            for (NSUInteger rowCounter = 0; rowCounter < [data count]; rowCounter++)
            {
                id obj = [data objectAtIndex:rowCounter];
                id aValue = [obj valueForKeyPath:keyPath];
                if ([aValue isEqual:key])
                    return [NSIndexPath indexPathForRow:(NSInteger)rowCounter inSection:0];
            }
        }

    } @catch (NSException *exception)
    {
        return nil;
    }
    
    // not found
    return nil;
}

#pragma mark - Object Comparison

- (BOOL)isObject:(id)anObject equalToObject:(id)anotherObject usingKeyPath:(NSString *)keyPath
{
    // hack for ids and hashes
    if ([anObject isEqual:anotherObject])
        return YES;

    // are they the same class?
    if (![anObject isKindOfClass:[anotherObject class]])
        return NO;

    // no key path supplied? Can't continue further checking.
    if (keyPath == nil)
    {
        // check directly (we already know they're the same class)
        if ([anObject isKindOfClass:[NSString class]])
            return [((NSString *)anObject) isEqualToString:anotherObject];
        
        return NO;
    }
    
    // otherwise, get the values at the specified keypath for both and compare those
    @try
    {
        id aValue = [anObject valueForKeyPath:keyPath];
        id anotherValue = [anotherObject valueForKeyPath:keyPath];
        if ([aValue isEqual:anotherValue])
            return YES;
        
        // otherwise no
        return NO;
    }
    @catch (NSException *)
    {
        // the keypath wasnt found on at least one of the objects, so definitely not.
        return NO;
    }
}

- (BOOL)isArrayTwoDimensional:(NSArray *)array
{
    if (array == nil || [array count] == 0)
        return NO;
    
    return [[array firstObject] isKindOfClass:[NSArray class]];
}

#pragma mark - Section Manipulation

- (void)addSection:(NSArray *)section
{
    NSAssert(self.UAData != nil, @"Cannot add section to nil data.");
    NSAssert([self isArrayTwoDimensional:self.UAData], @"Cannot add section to 1D array.");
    NSParameterAssert(section != nil);
    
    [self notifyBeginChanges];
    [self.UAData addObject:[[NSMutableArray alloc] initWithArray:section]];
    [self notifyChangedSectionAtIndex:((NSInteger)[self.UAData count]-1) forChangeType:UAFilterableResultsChangeInsert];
    [self notifyEndChanges];
}

- (void)insertSection:(NSArray *)section atIndex:(NSUInteger)index
{
    NSAssert(self.UAData != nil, @"Cannot insert section to nil data.");
    NSAssert([self isArrayTwoDimensional:self.UAData], @"Cannot imsert section to 1D array.");
    NSParameterAssert(section != nil);
    
    [self notifyBeginChanges];
    [self.UAData insertObject:[section mutableCopy] atIndex:index];
    [self notifyChangedSectionAtIndex:(NSInteger)index forChangeType:UAFilterableResultsChangeInsert];
    [self notifyEndChanges];
}

- (void)removeSection:(NSArray *)section
{
    NSAssert(self.UAData != nil, @"Cannot remove section from nil data.");
    NSAssert([self isArrayTwoDimensional:self.UAData], @"Cannot remove section from 1D array.");
    NSParameterAssert(section != nil);
    
    NSUInteger indexOfSection = [self.UAData indexOfObject:section];
    [self removeSectionAtIndex:indexOfSection];
}

- (void)removeSectionAtIndex:(NSUInteger)sectionIndex
{
    NSAssert(self.UAData != nil, @"Cannot remove section from nil data.");
    NSAssert([self isArrayTwoDimensional:self.UAData], @"Cannot remove section from 1D array.");

    if (sectionIndex != NSNotFound)
    {
        [self notifyBeginChanges];
        [self.UAData removeObjectAtIndex:sectionIndex];
        [self notifyChangedSectionAtIndex:(NSInteger)sectionIndex forChangeType:UAFilterableResultsChangeDelete];
        [self notifyEndChanges];
    }
}

- (void)replaceSection:(NSArray *)oldSection withSection:(NSArray *)newSection
{
    NSAssert(self.UAData != nil, @"Cannot replace section in nil data.");
    NSAssert([self isArrayTwoDimensional:self.UAData], @"Cannot replace section in 1D array.");
    NSParameterAssert(oldSection != nil);
    NSParameterAssert(newSection != nil);
    
    NSUInteger indexOfSection = [self.UAData indexOfObject:oldSection];
    if (indexOfSection != NSNotFound)
        [self replaceSectionAtIndex:(NSInteger)indexOfSection withSection:newSection];
}

- (void)replaceSectionAtIndex:(NSInteger)sectionIndex withSection:(NSArray *)newSection
{
    NSAssert(self.UAData != nil, @"Cannot replace section in nil data.");
    NSAssert([self isArrayTwoDimensional:self.UAData], @"Cannot replace section in 1D array.");
    NSParameterAssert(sectionIndex != NSNotFound);
    NSParameterAssert(newSection != nil);
    
    [self notifyBeginChanges];

    NSArray *existing = [self.UAData objectAtIndex:(NSUInteger)sectionIndex];
    [self.UAData replaceObjectAtIndex:(NSUInteger)sectionIndex withObject:newSection];

    if (existing != nil)
        [self notifyForChangesForSectionAtIndex:sectionIndex from:existing to:newSection];
    else
        [self notifyChangedSectionAtIndex:sectionIndex forChangeType:UAFilterableResultsChangeUpdate];

    [self notifyEndChanges];
}


#pragma mark - Filters

- (void)addFilter:(UAFilter *)filter
{
    NSMutableArray *appliedFilters = self.UAAppliedFilters;

    // are there any existing filters in this group?
    BOOL didReplaceFilter = NO;
    for (NSUInteger i = 0; i < [appliedFilters count]; i++)
    {
        UAFilter *existingFilter = [appliedFilters objectAtIndex:i];
        if (existingFilter.groupTitle != nil && filter.groupTitle != nil && [existingFilter.groupTitle isEqualToString:filter.groupTitle])
        {
            [appliedFilters replaceObjectAtIndex:i withObject:filter];
            didReplaceFilter = YES;
            break;
        }
    }
    
    // if we did not replace an existing filter we add it in
    if (!didReplaceFilter)
        [appliedFilters addObject:filter];
    
    // reload the filters
    [self applyFilters:appliedFilters];
}

- (void)addFilters:(NSArray *)filters
{
    NSMutableArray *appliedFilters = self.UAAppliedFilters;
    
    for (UAFilter *filter in filters)
    {
        // are there any existing filters in this group?
        BOOL didReplaceFilter = NO;
        for (NSUInteger i = 0; i < [appliedFilters count]; i++)
        {
            UAFilter *existingFilter = [appliedFilters objectAtIndex:i];
            if (existingFilter.groupTitle != nil && filter.groupTitle != nil && [existingFilter.groupTitle isEqualToString:filter.groupTitle])
            {
                [appliedFilters replaceObjectAtIndex:i withObject:filter];
                didReplaceFilter = YES;
                break;
            }
        }
        
        // if we did not replace an existing filter we add it in
        if (!didReplaceFilter)
            [appliedFilters addObject:filter];
    }
    
    // reload the filters
    [self applyFilters:appliedFilters];
}

- (void)removeFilter:(UAFilter *)filter
{
    NSMutableArray *appliedFilters = self.UAAppliedFilters;
    if ([appliedFilters count] == 0)
        return;
    [appliedFilters removeObject:filter];
    [self applyFilters:appliedFilters];
}

- (void)replaceFilters:(NSArray *)filters
{
    NSMutableArray *appliedFilters = self.UAAppliedFilters;
    [appliedFilters replaceObjectsInRange:NSMakeRange(0, [self.UAAppliedFilters count]) withObjectsFromArray:filters];
    [self applyFilters:appliedFilters];
}

- (void)clearFilters
{
    [self.UAAppliedFilters removeAllObjects];
    [self applyFilters:nil];
}

- (void)reapplyFiltersWithoutNotifying
{
    if (self.UAAppliedFilters != nil && [self.UAAppliedFilters count] > 0)
        [self applyFilters:self.UAAppliedFilters notifications:NO];
}

- (void)reapplyFilters
{
    if (self.UAAppliedFilters != nil && [self.UAAppliedFilters count] > 0)
        [self applyFilters:self.UAAppliedFilters];
}

- (void)applyFilters:(NSArray *)filters
{
    [self applyFilters:filters notifications:YES];
}

- (void)applyFilters:(NSArray *)filters notifications:(BOOL)notifications
{
    if (filters == nil)
    {
        [self setFilteredData:nil notifications:notifications];
        return;
    }
    
    // nothing to apply to?
    if (self.UAData == nil)
        return;

    // 2D Arrays
    NSMutableArray *data = self.UAData;
    if ([self isArrayTwoDimensional:data])
    {
        NSMutableArray *filteredData = [[NSMutableArray alloc] initWithCapacity:[data count]];
        for (NSMutableArray *section in data)
        {
            NSMutableArray *filteredSection = [[NSMutableArray alloc] initWithArray:section];

            // apply all of the filters to that section now
            for (UAFilter *filter in filters)
            {
                if (filter.predicate != nil)
                    [filteredSection filterUsingPredicate:filter.predicate];
            }

            // and add it to the filtered data
            [filteredData addObject:filteredSection];
        }
        
        [self setFilteredData:filteredData notifications:notifications];

    // 1D Array
    } else
    {
        NSMutableArray *filteredData = [[NSMutableArray alloc] initWithArray:data];
        
        // apply all of the filters to that section now
        for (UAFilter *filter in filters)
        {
            if (filter.predicate != nil)
                [filteredData filterUsingPredicate:filter.predicate];
        }
        
        [self setFilteredData:filteredData notifications:notifications];
    }
}

- (NSArray *)appliedFilters
{
    return self.UAAppliedFilters;
}

#pragma mark - Delegate Notifications

- (void)beginUpdates
{
    [self notifyBeginChanges];
}

- (void)notifyBeginChanges
{
    // not until we've loaded
    if (![self tableViewHasLoaded])
        return;

    // we only notify for the outer one, not the inner ones
    if (self.changeBatches == 0)
    {
        // Notify the delegate of the impending change
        id<UAFilterableResultsControllerDelegate> delegate = self.delegate;
        if (delegate != nil && [delegate respondsToSelector:@selector(filterableResultsControllerWillChangeContent:)])
            [delegate filterableResultsControllerWillChangeContent:self];
        
        [self setIndexPathNotificationMapping:[NSMutableDictionary dictionary]];
    }
    [self setChangeBatches:(self.changeBatches + 1)];
//    NSLog(@"Change batches: %li", (long)self.changeBatches);
}

- (void)notifyChangedObject:(id)object atIndexPath:(NSIndexPath *)indexPath forChangeType:(UAFilterableResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    // not until we've loaded
    if (![self tableViewHasLoaded])
        return;
    
    id<UAFilterableResultsControllerDelegate> delegate = self.delegate;
    if (delegate != nil && [delegate respondsToSelector:@selector(filterableResultsController:didChangeObject:atIndexPath:forChangeType:newIndexPath:)])
    {
        [delegate filterableResultsController:self
                              didChangeObject:object
                                  atIndexPath:indexPath
                                forChangeType:type
                                 newIndexPath:newIndexPath];
    }
}

- (void)notifyChangedSectionAtIndex:(NSInteger)sectionIndex forChangeType:(UAFilterableResultsChangeType)type
{
    // not until we've loaded
    if (![self tableViewHasLoaded])
        return;
    
    // so we changed a section at that index, which means all the rest are pushed down
    if (type == UAFilterableResultsChangeInsert)
    {
        NSInteger sectionCount = (NSInteger)[self.data count] - 1;
        if (sectionIndex < sectionCount)
        {
            for (NSInteger i = sectionIndex; i < sectionCount; i++)
            {
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:-1 inSection:i+1];
                NSIndexPath *oldIndexPath = [NSIndexPath indexPathForItem:-1 inSection:i];
                [self.indexPathNotificationMapping setObject:oldIndexPath forKey:newIndexPath];
            }
        }

    // likewise, all the sections were bumped up
    } else if (type == UAFilterableResultsChangeDelete)
    {
        NSInteger sectionCount = (NSInteger)[self.data count] + 1;
        if (sectionIndex+1 < sectionCount)
        {
            for (NSInteger i = sectionIndex+1; i < sectionCount; i++)
            {
                NSIndexPath *newIndexPath = [NSIndexPath indexPathForItem:-1 inSection:i-1];
                NSIndexPath *oldIndexPath = [NSIndexPath indexPathForItem:-1 inSection:i];
                [self.indexPathNotificationMapping setObject:oldIndexPath forKey:newIndexPath];
            }
        }
    }
    
    id<UAFilterableResultsControllerDelegate> delegate = self.delegate;
    if (delegate != nil && [delegate respondsToSelector:@selector(filterableResultsController:didChangeSectionAtIndex:forChangeType:)])
    {
        [delegate filterableResultsController:self
                      didChangeSectionAtIndex:sectionIndex
                                forChangeType:type];
    }
}

- (void)notifyForChangesForSectionAtIndex:(NSInteger)sectionIndex from:(NSArray *)fromArray to:(NSArray *)toArray
{
    // move everything that exists in both arrays into a mutable array, notify for all the others
    NSMutableArray *fromMutable = [[NSMutableArray alloc] initWithCapacity:0];
    for (NSUInteger rowIndex = 0; rowIndex < [fromArray count]; rowIndex++)
    {
        id obj = [fromArray objectAtIndex:rowIndex];
        
        // if it exists in the target we add it
        if ([self indexPathOfObject:obj inArray:toArray usingKeyPath:nil] != nil)
            [fromMutable addObject:obj];
        
        // otherwise, we notify about it
        else
            [self notifyChangedObject:obj atIndexPath:[NSIndexPath indexPathForRow:(NSInteger)rowIndex inSection:[self originalSectionIndexForIndex:(NSInteger)sectionIndex]] forChangeType:UAFilterableResultsChangeDelete newIndexPath:nil];
    }
    
    // now that thats over, we need to loop over the target array and note anything that isn't in the same place as last time
    for (NSUInteger rowIndex = 0; rowIndex < [toArray count]; rowIndex++)
    {
        id obj = [toArray objectAtIndex:rowIndex];
        
        // alrighty, does this object exist in the old one?
        NSUInteger indexInExisting = [self indexOfObject:obj inArray:fromArray usingKeyPath:nil];
        if (indexInExisting == NSNotFound)
        {
            // nope, lets notify about it
            [self notifyChangedObject:obj atIndexPath:nil forChangeType:UAFilterableResultsChangeInsert newIndexPath:[NSIndexPath indexPathForRow:(NSInteger)rowIndex inSection:[self originalSectionIndexForIndex:(NSInteger)sectionIndex]]];
            
        // is it the same as where we are now?
        } else if (indexInExisting == (NSInteger)rowIndex)
            [self notifyChangedObject:obj atIndexPath:[NSIndexPath indexPathForRow:(NSInteger)rowIndex inSection:[self originalSectionIndexForIndex:(NSInteger)sectionIndex]] forChangeType:UAFilterableResultsChangeUpdate newIndexPath:nil];
        
        // nope, tell them where it is now
        else
            [self notifyChangedObject:obj atIndexPath:[NSIndexPath indexPathForRow:(NSInteger)indexInExisting inSection:[self originalSectionIndexForIndex:(NSInteger)sectionIndex]] forChangeType:UAFilterableResultsChangeMove newIndexPath:[NSIndexPath indexPathForRow:(NSInteger)rowIndex inSection:(NSInteger)sectionIndex]];
    }
}

- (NSInteger)originalSectionIndexForIndex:(NSInteger)sectionIndex
{
    if (self.indexPathNotificationMapping == nil || [self.indexPathNotificationMapping count] == 0)
        return sectionIndex;
    
    NSIndexPath *oldIndexPath = [self.indexPathNotificationMapping objectForKey:[NSIndexPath indexPathForItem:-1 inSection:sectionIndex]];
    if (oldIndexPath != nil)
        return oldIndexPath.section;
    
    return sectionIndex;
}

- (void)notifyReload
{
    // the only one we can send without being fully loaded
    id<UAFilterableResultsControllerDelegate> delegate = self.delegate;
    if (delegate != nil && [delegate respondsToSelector:@selector(filterableResultsControllerShouldReload:)])
        [delegate filterableResultsControllerShouldReload:self];
}

- (void)endUpdates
{
    [self notifyEndChanges];
}

- (void)notifyEndChanges
{
    // not until we've loaded
    if (![self tableViewHasLoaded])
        return;

    if (self.changeBatches > 0)
        [self setChangeBatches:(self.changeBatches - 1)];
//    NSLog(@"Change batches: %li", (long)self.changeBatches);

    // we only notify for the outer one, not the inner ones
    if (self.changeBatches == 0)
    {
        if (self.appliedFilters != nil && [self.appliedFilters count] > 0)
        {
            // increment it again lest the count is out
            [self setChangeBatches:1];

            // reapply filters
            [self reapplyFilters];

            // increment it again lest the count is out
            [self setChangeBatches:0];
        }
        
        [self setIndexPathNotificationMapping:nil];

        // Notify the delegate of the impending change
        id delegate = self.delegate;
        if (delegate != nil && [delegate respondsToSelector:@selector(filterableResultsControllerDidChangeContent:)])
            [delegate filterableResultsControllerDidChangeContent:self];
    }
}

- (void)notifyEndChangesButDontReapplyFilters
{
    // not until we've loaded
    if (![self tableViewHasLoaded])
        return;
    
    if (self.changeBatches > 0)
        [self setChangeBatches:(self.changeBatches - 1)];
    
    // we only notify for the outer one, not the inner ones
    if (self.changeBatches == 0)
    {
        // Notify the delegate of the impending change
        id delegate = self.delegate;
        if (delegate != nil && [delegate respondsToSelector:@selector(filterableResultsControllerDidChangeContent:)])
            [delegate filterableResultsControllerDidChangeContent:self];
    }
}

- (void)notifyForChangesFrom:(NSArray *)fromArray to:(NSArray *)toArray
{
    // do we have a primary key? we use an optimised version of this approach if so.
    if (self.primaryKeyPath != nil)
    {
        [self notifyForChangesFrom:fromArray to:toArray usingKeyPath:self.primaryKeyPath];
        return;
    }

    // we need to make sure they're both 2 dimensional
    if (![self isArrayTwoDimensional:fromArray])
        fromArray = @[ fromArray ];
    if (![self isArrayTwoDimensional:toArray])
        toArray = @[ toArray ];
    
    // move everything that exists in both arrays into a mutable array, notify for all the others
    NSMutableArray *fromMutable = [[NSMutableArray alloc] initWithCapacity:[fromArray count]];
    for (NSUInteger sectionIndex = 0; sectionIndex < [fromArray count]; sectionIndex++)
    {
        NSArray *section = [fromArray objectAtIndex:sectionIndex];
        NSMutableArray *newSection = [[NSMutableArray alloc] initWithCapacity:0];
        for (NSUInteger rowIndex = 0; rowIndex < [section count]; rowIndex++)
        {
            id obj = [section objectAtIndex:rowIndex];

            // if it exists in the target we add it
            if ([self indexPathOfObject:obj inArray:toArray usingKeyPath:nil] != nil)
                [newSection addObject:obj];
            
            // otherwise, we notify about it
            else
                [self notifyChangedObject:obj atIndexPath:[NSIndexPath indexPathForRow:(NSInteger)rowIndex inSection:(NSInteger)sectionIndex] forChangeType:UAFilterableResultsChangeDelete newIndexPath:nil];
        }
        
        [fromMutable addObject:newSection];
        newSection = nil;
    }

    // now that thats over, we need to loop over the target array and note anything that isn't in the same place as last time
    for (NSUInteger sectionIndex = 0; sectionIndex < [toArray count]; sectionIndex++)
    {
        // now loop over the section
        NSArray *section = [toArray objectAtIndex:sectionIndex];
        for (NSUInteger rowIndex = 0; rowIndex < [section count]; rowIndex++)
        {
            id obj = [section objectAtIndex:rowIndex];
            
            // alrighty, does this object exist in the old one?
            NSIndexPath *pathInExisting = [self indexPathOfObject:obj inArray:fromMutable usingKeyPath:nil];
            if (pathInExisting == nil)
            {
                // nope, lets notify about it
                [self notifyChangedObject:obj atIndexPath:nil forChangeType:UAFilterableResultsChangeInsert newIndexPath:[NSIndexPath indexPathForRow:(NSInteger)rowIndex inSection:(NSInteger)sectionIndex]];
                
                // does this section exist?
                if (sectionIndex+1 > [fromMutable count])
                    [fromMutable addObject:[[NSMutableArray alloc] initWithCapacity:0]];
                
                NSMutableArray *fromSection = [fromMutable objectAtIndex:sectionIndex];
                [fromSection insertObject:obj atIndex:rowIndex];

                // is it the same as where we are now?
            } else if (pathInExisting.section == (NSInteger)sectionIndex && pathInExisting.row == (NSInteger)rowIndex)
                [self notifyChangedObject:obj atIndexPath:[self indexPathOfObject:obj inArray:fromArray usingKeyPath:nil] forChangeType:UAFilterableResultsChangeUpdate newIndexPath:nil];
        
            // nope, tell them where it is now
            else
                [self notifyChangedObject:obj atIndexPath:pathInExisting forChangeType:UAFilterableResultsChangeMove newIndexPath:[NSIndexPath indexPathForRow:(NSInteger)rowIndex inSection:(NSInteger)sectionIndex]];
        }
    }
}

- (void)notifyForChangesFrom:(NSArray *)fromArray to:(NSArray *)toArray usingKeyPath:(NSString *)keyPath
{
    // we need to make sure they're both 2 dimensional
    if (![self isArrayTwoDimensional:fromArray])
        fromArray = @[ fromArray ];
    if (![self isArrayTwoDimensional:toArray])
        toArray = @[ toArray ];
    
    // refine it down to just the key paths, if an exception is thrown anywhere there we fall back to the non-optimised method
    NSArray *originalFromArray = [fromArray copy];
    NSArray *originalToArray = [toArray copy];
    @try
    {
        fromArray = [fromArray valueForKeyPath:keyPath];
        toArray = [toArray valueForKeyPath:keyPath];
        keyPath = nil;

    } @catch (NSException *exception)
    {
        // go back to the originals
        fromArray = originalFromArray;
        toArray = originalToArray;
    }

    // copy the primary keys from everything that exists in both arrays into a mutable array, notify for all the others
    NSMutableArray *fromMutable = [[NSMutableArray alloc] initWithCapacity:[fromArray count]];
    for (NSUInteger sectionIndex = 0; sectionIndex < [fromArray count]; sectionIndex++)
    {
        // does this section exist in the target?
        if (sectionIndex >= [toArray count])
        {
            // nope, deleted
            [self notifyChangedSectionAtIndex:sectionIndex forChangeType:UAFilterableResultsChangeDelete];
            continue;
        }
        
        NSArray *section = [fromArray objectAtIndex:sectionIndex];
        NSArray *originalSection = [originalFromArray objectAtIndex:sectionIndex];
        NSMutableArray *newSection = [[NSMutableArray alloc] initWithCapacity:0];
        for (NSUInteger rowIndex = 0; rowIndex < [section count]; rowIndex++)
        {
            id obj = [section objectAtIndex:rowIndex];
            
            // if it exists in the target we add it
            if ([self indexPathOfObject:obj inArray:toArray usingKeyPath:keyPath] != nil)
                [newSection addObject:obj];
            
            // otherwise, we notify about it
            else
                [self notifyChangedObject:[originalSection objectAtIndex:rowIndex] atIndexPath:[NSIndexPath indexPathForRow:(NSInteger)rowIndex inSection:(NSInteger)sectionIndex] forChangeType:UAFilterableResultsChangeDelete newIndexPath:nil];
        }
        
        [fromMutable addObject:newSection];
        newSection = nil;
    }
    
    // now that thats over, we need to loop over the target array and note anything that isn't in the same place as last time
    for (NSUInteger sectionIndex = 0; sectionIndex < [toArray count]; sectionIndex++)
    {
        // does this section exist in the source?
        if (sectionIndex >= [fromArray count])
        {
            // nope, lets just add the whole thing in
            [self notifyChangedSectionAtIndex:sectionIndex forChangeType:UAFilterableResultsChangeInsert];
            continue;
        }
        
        // now loop over the section
        NSArray *section = [toArray objectAtIndex:sectionIndex];
        NSArray *originalSection = [originalToArray objectAtIndex:sectionIndex];
        for (NSUInteger rowIndex = 0; rowIndex < [section count]; rowIndex++)
        {
            id obj = [section objectAtIndex:rowIndex];
            
            // alrighty, does this object exist in the old one?
            NSIndexPath *pathInExisting = [self indexPathOfObject:obj inArray:fromMutable usingKeyPath:keyPath];
            if (pathInExisting == nil)
            {
                // nope, lets notify about it
                [self notifyChangedObject:[originalSection objectAtIndex:rowIndex] atIndexPath:nil forChangeType:UAFilterableResultsChangeInsert newIndexPath:[NSIndexPath indexPathForRow:(NSInteger)rowIndex inSection:(NSInteger)sectionIndex]];
                
                // does this section exist?
                if (sectionIndex+1 > [fromMutable count])
                    [fromMutable addObject:[[NSMutableArray alloc] initWithCapacity:0]];
                
                NSMutableArray *fromSection = [fromMutable objectAtIndex:sectionIndex];
                [fromSection insertObject:obj atIndex:rowIndex];
                
            // is it the same as where we are now?
            } else if (pathInExisting.section == (NSInteger)sectionIndex && pathInExisting.row == (NSInteger)rowIndex)
                [self notifyChangedObject:[originalSection objectAtIndex:rowIndex] atIndexPath:[self indexPathOfObject:obj inArray:fromArray usingKeyPath:keyPath] forChangeType:UAFilterableResultsChangeUpdate newIndexPath:nil];
            
            // nope, tell them where it is now
            else
                [self notifyChangedObject:[originalSection objectAtIndex:rowIndex] atIndexPath:pathInExisting forChangeType:UAFilterableResultsChangeMove newIndexPath:[NSIndexPath indexPathForRow:(NSInteger)rowIndex inSection:(NSInteger)sectionIndex]];
        }
    }
}

#pragma mark - Forwarding for unsupported Data Source Methods

- (BOOL)respondsToSelector:(SEL)aSelector
{
    if ([super respondsToSelector:aSelector])
        return YES;
    
    // if we don't support it but it is an obvious UICollectionViewDataSource or UITableViewDataSource method we should try forwarding it
    id delegate = self.delegate;
    
    // nothing to forward to
    if (delegate == nil)
        return NO;
    
    NSString *selectorName = NSStringFromSelector(aSelector);
    if ([selectorName rangeOfString:@"tableView:"].location == 0 || [selectorName rangeOfString:@"collectionView:"].location == 0)
    {
        // it is for a collection view or table view method, see if we can pass it
        if ([delegate respondsToSelector:aSelector])
            return YES;
    }
    
    // nothing supported
    return NO;
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    // if we don't support it but it is an obvious UICollectionViewDataSource or UITableViewDataSource method we should try forwarding it
    id delegate = self.delegate;
    
    // nothing to forward to
    if (delegate == nil)
        return nil;
    
    NSString *selectorName = NSStringFromSelector(aSelector);
    if ([selectorName rangeOfString:@"tableView:"].location == 0 || [selectorName rangeOfString:@"collectionView:"].location == 0)
    {
        // it is for a collection view or table view method, see if we can pass it
        if ([delegate respondsToSelector:aSelector])
            return delegate;
    }
    
    // nothing supported
    return nil;
}

@end

