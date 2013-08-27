//
//  NSDictionary+GHRoute.m
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/26/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "NSDictionary+GHRoute.h"

@implementation NSDictionary (GHRoute)

- (int)GHid
{
    return [[self objectForKey:@"id"] integerValue];
}

- (GHRouteIcon*)GHicon
{
    return [self objectForKey:@"icon"];
}

- (GHImage*)GHimage
{
    return [self objectForKey:@"icon"];
}

- (NSString*)GHdescription
{
    return [Utilities getTranslatedStringForKey:@"description" fromDictionary:self];
}

- (NSString*)GHname
{
    return [Utilities getTranslatedStringForKey:@"name" fromDictionary:self];

}

- (NSArray*)GHwaypoints
{
    return [self objectForKey:@"waypoints"];
}

@end
