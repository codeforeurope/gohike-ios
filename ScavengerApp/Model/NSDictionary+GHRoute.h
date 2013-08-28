//
//  NSDictionary+GHRoute.h
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/26/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+GHImage.h"

@interface NSDictionary (GHRoute)

- (int)GHid;
- (GHImage*)GHicon;
- (GHImage*)GHimage;
- (NSString*)GHdescription;
- (NSString*)GHname;
- (NSArray*)GHwaypoints;
- (GHReward*)GHreward;

@end

typedef NSDictionary GHRoute;