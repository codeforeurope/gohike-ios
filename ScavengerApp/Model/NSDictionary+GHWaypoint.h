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
- (NSString*)GHname;
- (NSString*)GHdescription;
- (int)GHlocation_id;
- (double)GHlatitude;
- (double)GHlongitude;
- (int)GHroute_id;
- (int)GHrank;

- (BOOL)saveToFile;

@end

typedef NSDictionary GHWaypoint;