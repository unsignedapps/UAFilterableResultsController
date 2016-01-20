//
//  UAFilterableResultsController+Private.h
//  UAFilterableResultsController
//
//  Created by Kocsis Olivér on 2015. 08. 18..
//  Copyright (c) 2015. Unsigned Apps. All rights reserved.
//

#import "UAFilterableResultsControllerClass.h"
NS_ASSUME_NONNULL_BEGIN
@interface UAFilterableResultsController ()

@property (nonatomic, strong,nullable) NSMutableArray *UAData;
@property (nonatomic) BOOL tableViewHasLoaded;
@property (nonatomic) NSInteger changeBatches;

@property (nonatomic, strong) NSMutableArray *UAAppliedFilters;
@property (nonatomic, strong) NSMutableArray *filteredData;

@property (nonatomic, strong,nullable ) NSMutableDictionary *indexPathNotificationMapping;

- (BOOL)isArrayTwoDimensional:(NSArray *)array;

- (BOOL)isObject:(id)object equalToObject:(id)object usingKeyPath:(NSString *)keyPath;

- (nullable NSIndexPath *)indexPathOfObject:(id)object inArray:(NSArray *)data;
- (nullable NSIndexPath *)indexPathOfObjectWithPrimaryKey:(id)key inArray:(NSArray *)data;

- (void)notifyBeginChanges;
- (void)notifyChangedObject:(id)object atIndexPath:(nullable NSIndexPath *)indexPath forChangeType:(UAFilterableResultsChangeType)type newIndexPath:(nullable NSIndexPath *)newIndexPath;
- (void)notifyChangedSectionAtIndex:(NSInteger)sectionIndex forChangeType:(UAFilterableResultsChangeType)type;
- (void)notifyReload;
- (void)notifyEndChanges;
- (void)notifyEndChangesButDontReapplyFilters;
- (void)notifyForChangesFrom:(NSArray *)fromArray to:(NSArray *)toArray;

- (void)reapplyFilters;
- (void)applyFilters:(nullable NSArray *)array;

@property (nonatomic,readonly) BOOL isFiltered;

@end
NS_ASSUME_NONNULL_END