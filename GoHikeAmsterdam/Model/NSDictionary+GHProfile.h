//
//  NSDictionary+GHProfile.h
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/26/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+GHImage.h"

@interface NSDictionary (GHProfile)

- (int)GHid;
- (NSString*)GHname;
- (NSArray*)GHroutes;
- (GHImage*)GHimage;

@end

typedef NSDictionary GHProfile;