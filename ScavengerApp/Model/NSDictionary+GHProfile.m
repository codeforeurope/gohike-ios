//
//  NSDictionary+GHProfile.m
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/26/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "NSDictionary+GHProfile.h"

@implementation NSDictionary (GHProfile)

- (int)GHid
{
    return [[self objectForKey:@"id"] integerValue];
}

- (NSString*)GHname
{
    return [self objectForKey:@"name"];
}


-(NSArray*)GHroutes
{
    return [self objectForKey:@"routes"];
}

- (GHImage*)GHimage
{
    return [self objectForKey:@"image"];
}

- (BOOL)saveToFile
{
    //TODO
    for (GHRoute *route in [self GHroutes]) {
        [route saveToFile];
    }
    return YES;
}

- (NSData*)imageData
{
    
}



@end