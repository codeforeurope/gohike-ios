//
//  NSDictionary+RouteIcon.m
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/26/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "NSDictionary+RouteIcon.h"

@implementation NSDictionary (GHRouteIcon)

- (NSString*)GHurl;
{
    return [self objectForKey:@"url"];
}

- (NSString*)GHmd5
{
    return [self objectForKey:@"md5"];
}

@end
