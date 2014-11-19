//
//  NSDictionary+GHCities.m
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/26/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "NSDictionary+GHCities.h"

@implementation NSDictionary (GHCities)

- (NSArray*)GHwithin
{
    return [self objectForKey:@"within"];
}

- (NSArray*)GHother
{
    return [self objectForKey:@"other"];
}

@end
