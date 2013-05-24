//
//  Waypoint.h
//  ScavengerApp
//
//  Created by Giovanni on 5/24/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Waypoint : NSObject

@property (nonatomic, assign) NSInteger waypointId;
@property (nonatomic, assign) NSInteger previousWaypointId;
@property (nonatomic, assign) NSInteger nextWaypointId;
@property (nonatomic, assign) NSInteger locationId;



@end
