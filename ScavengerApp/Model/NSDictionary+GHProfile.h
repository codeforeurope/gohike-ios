//
//  NSDictionary+GHProfile.h
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/26/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GHImage.h"

@interface NSDictionary (GHProfile)

- (int)GHid;
- (NSString*)GHname;
- (NSArray*)GHroutes;
- (GHImage*)GHimage;

- (BOOL)saveToFile;
- (NSData*)imageData;

@end

typedef NSDictionary GHProfile;