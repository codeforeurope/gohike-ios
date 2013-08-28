//
//  NSDictionary+GHReward.m
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/28/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "NSDictionary+GHReward.h"

@implementation NSDictionary (GHReward)

- (int)GHid
{
    return [[self objectForKey:@"id"] integerValue];
}

- (GHImage*)GHImage
{
    return [self objectForKey:@"image"];
}

- (NSString*)GHname
{
    return [Utilities getTranslatedStringForKey:@"name" fromDictionary:self];
}

- (NSString*)GHdescription
{
    return [Utilities getTranslatedStringForKey:@"description" fromDictionary:self];
}

@end
