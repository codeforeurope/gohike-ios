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

- (GHImage*)image
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

- (NSData*)GHimageData
{
    NSString* libraryPath = [Utilities getLibraryPath];
    NSString *rewardPath = [libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"rewards/%d", [self GHroute_id]]];
    NSString *filePath = [rewardPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [[self image] GHmd5]]];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    return data;
}

@end
