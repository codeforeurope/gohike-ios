//
//  NSDictionary+GHWaypoint.m
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/27/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "NSDictionary+GHWaypoint.h"

@implementation NSDictionary (GHWaypoint)

- (int)GHid
{
    return [[self objectForKey:@"id"] integerValue];
}

- (GHImage*)image
{
    return [self objectForKey:@"image"];
}

- (int)GHlocation_id
{
    return [[self objectForKey:@"location_id"] integerValue];
}

- (NSString*)GHname
{
    return [Utilities getTranslatedStringForKey:@"name" fromDictionary:self];
}

- (NSString*)GHdescription
{
    return [Utilities getTranslatedStringForKey:@"description" fromDictionary:self];
}

- (double)GHlatitude
{
    return [[self objectForKey:@"latitude"] doubleValue];
}

- (double)GHlongitude
{
    return [[self objectForKey:@"longitude"] doubleValue];
}

- (int)GHroute_id
{
    return [[self objectForKey:@"route_id"] integerValue];
}

- (int)GHrank
{
    return [[self objectForKey:@"rank"] integerValue];
}

- (NSData*)GHimageData
{
    NSString* libraryPath = [Utilities getLibraryPath];
    NSString *routePath = [libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"waypoints/%d", [self GHroute_id]]];
    NSString *filePath = [routePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [[self GHimage] GHmd5]]];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    return data;
}

- (BOOL)saveToFile
{
    //TODO
    return YES;
}

@end
