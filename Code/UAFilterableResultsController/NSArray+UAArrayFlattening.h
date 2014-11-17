//
//  NSArray+UAArrayFlattening.h
//  Kestrel
//
//  Created by Rob Amos on 12/10/2013.
//  Copyright (c) 2013 Desto. All rights reserved.
//

@import Foundation;

@interface NSArray (UAArrayFlattening)

/**
 * Flattens a multi-dimension array into a single array. Infinitely recursive.
 *
 * @returns             A single-dimension NSArray with the child NSArray's flattened into a single array.
**/
- (NSArray *)UAFlattenedArray;

@end
