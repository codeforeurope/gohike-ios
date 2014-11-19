//
//  NSDictionary+GHCity.m
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/26/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "NSDictionary+GHCity.h"

@implementation NSDictionary (GHCity)

- (NSInteger)GHid
{
    return [[self objectForKey:@"id"] integerValue];
}

- (NSString*)GHname
{
    return [Utilities getTranslatedStringForKey:@"name" fromDictionary:self];
}

- (NSString*)GHstate_province
{
    return [self objectForKey:@"state_province"];
}

- (NSString*)GHcountry_code
{
    return [self objectForKey:@"country_code"];
}

@end
