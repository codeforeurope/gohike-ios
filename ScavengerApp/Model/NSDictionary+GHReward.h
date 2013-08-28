//
//  NSDictionary+GHReward.h
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/28/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSDictionary+GHImage.h"

@interface NSDictionary (GHReward)

- (int)GHid;
- (GHImage*)GHImage;
- (NSString*)GHname;
- (NSString*)GHdescription;


@end

typedef NSDictionary GHReward;