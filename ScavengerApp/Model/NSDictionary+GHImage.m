//
//  NSDictionary+GHImage.m
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/27/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "NSDictionary+GHImage.h"

@implementation NSDictionary (GHImage)

- (NSString*)url
{
    return [self objectForKey:@"url"];
}

- (NSString*)md5
{
    return [self objectForKey:@"md5"];
}

@end
