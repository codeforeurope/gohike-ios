//
//  NSDictionary+GHWaypoint.h
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/27/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (GHWaypoint)

- (int)GHid;
- (NSData*)GHimageData;
- (GHImage*)image;
- (int)GHlocation_id;
- (NSString*)GHdescription;
- (double)GHlatitude;
- (double)GHlongitude;
- (NSString*)GHname;
- (int)GHroute_id;

@end

typedef NSDictionary GHWaypoint;