//
//  Checkin.h
//  ScavengerApp
//
//  Created by Taco van Dijk on 5/23/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Checkin : NSObject <NSCoding> //TODO: save to disk to a file called "SaveGame"

@property (nonatomic, assign) int locationId;
@property (nonatomic, assign) int routeId;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, assign) BOOL uploaded;


@end
