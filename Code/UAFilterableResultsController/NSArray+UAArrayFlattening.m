//
//  NSArray+UAArrayFlattening.m
//  Kestrel
//
//  Created by Rob Amos on 12/10/2013.
//  Copyright (c) 2013 Desto. All rights reserved.
//

#import "NSArray+UAArrayFlattening.h"

@implementation NSArray (UAArrayFlattening)

// Returns the array, flattened
- (NSArray *)UAFlattenedArray
{
    NSMutableArray *flatArray = [NSMutableArray arrayWithCapacity:0];
    for (id item in self)
    {
        if ([item isKindOfClass:[NSArray class]])
            [flatArray addObjectsFromArray:[((NSArray *)item) UAFlattenedArray]];
        else
            [flatArray addObject:item];
    }
    return flatArray;
}

@end
