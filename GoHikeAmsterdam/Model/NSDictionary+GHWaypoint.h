//
//  NSDictionary+GHWaypoint.h
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/27/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (GHWaypoint)

- (NSInteger)GHid;
- (GHImage*)GHimage;
- (NSString*)GHname;
- (NSString*)GHdescription;
- (NSInteger)GHlocation_id;
- (double)GHlatitude;
- (double)GHlongitude;
- (NSInteger)GHroute_id;
- (NSInteger)GHrank;

@end

typedef NSDictionary GHWaypoint;