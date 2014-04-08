//
//  UAFilter.m
//  Kestrel
//
//  Created by Rob Amos on 16/10/2013.
//  Copyright (c) 2013 Desto. All rights reserved.
//

#import "UAFilter.h"

@implementation UAFilter

@synthesize title=_title, predicate=_predicatem, groupTitle=_groupTitle;

+ (UAFilter *)filterWithPredicate:(NSPredicate *)predicate
{
    UAFilter *filter = [[UAFilter alloc] init];
    [filter setPredicate:predicate];
    return filter;
}

+ (UAFilter *)filterWithTitle:(NSString *)title group:(NSString *)groupTitle predicate:(NSPredicate *)predicate
{
    UAFilter *filter = [[UAFilter alloc] init];
    [filter setTitle:title];
    [filter setGroupTitle:groupTitle];
    [filter setPredicate:predicate];
    return filter;
}

- (BOOL)isEqualToFilter:(UAFilter *)filter
{
    return [self.title isEqualToString:filter.title] && [self.groupTitle isEqualToString:filter.groupTitle];
}

// override the default isEqual:
- (BOOL)isEqual:(id)object
{
    return ([object isKindOfClass:[UAFilter class]] ? [self isEqualToFilter:object] : [super isEqual:object]);
}

@end
