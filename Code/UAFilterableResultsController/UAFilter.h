//
//  UAFilter.h
//  Kestrel
//
//  Created by Rob Amos on 16/10/2013.
//  Copyright (c) 2013 Desto. All rights reserved.
//

@import Foundation;

/**
 * A filter object that is applied to a result set inside the filterable results controller.
**/
@interface UAFilter : NSObject

/**
 * The title of the filter. Not used internally to the Filterable Results Controller, but can be
 * useful when allowing the user to select filters.
**/
@property (nonatomic, strong) NSString *title;

/**
 * The title of a group of filters that this filter belongs to.
 *
 * There can only be one filter per group, so each filter will *replace* an existing filter with the
 * same group.
 *
 * If nil, no replacement will occur.
**/
@property (nonatomic, strong) NSString *groupTitle;

/**
 * An NSPredicate to apply directly to the result set. The predicates from all filters will be applied in sequence.
**/
@property (nonatomic, strong) NSPredicate *predicate;

/**
 * Creates a UAFilter object with the specified predicate.
 *
 * @param   predicate               A NSPredicate object to apply to the results in the Filterable Results Controller.
 * @returns                         An allocated and initialised UAFilter object.
**/
+ (UAFilter *)filterWithPredicate:(NSPredicate *)predicate;

/**
 * Creates a UAFilter object with the specified title, group and predicate.
 *
 * @param   title                   The title of the filter, not used internally.
 * @param   groupTitle              The title of a group that this filter belongs to. Filters from the same group replace each other.
 * @param   predicate               A NSPredicate object to apply to the results in the Filterable Results Controller.
 * @returns                         An allocated and initialised UAFilter object.
**/
+ (UAFilter *)filterWithTitle:(NSString *)title group:(NSString *)groupTitle predicate:(NSPredicate *)predicate;

/**
 * Checks whether the supplied filter is equal to the receiver.
 *
 * @param   filter                  Another filter to compare against the receiver.
 * @returns                         YES if the filters should be considered equal, NO otherwise.
**/
- (BOOL)isEqualToFilter:(UAFilter *)filter;

@end
