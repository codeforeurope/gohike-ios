//
//  Location.m
//  ScavengerApp
//
//  Created by Taco van Dijk on 5/23/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "Location.h"

@implementation Location

#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    self.locationId = [aDecoder decodeIntForKey:@"locationId"];
    self.locationName = [aDecoder decodeObjectForKey:@"locationName"];
    self.locationPicture = [aDecoder decodeObjectForKey:@"locationPicture"];
    self.longitude = [aDecoder decodeDoubleForKey:@"latitude"];
    self.longitude = [aDecoder decodeDoubleForKey:@"longitude"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
    [aCoder encodeInt:_locationId forKey:@"locationId"];
    [aCoder encodeObject:_locationName forKey:@"locationName"];
    [aCoder encodeObject:_locationPicture forKey:@"locationPicture"];
    [aCoder encodeDouble:_latitude forKey:@"latitude"];
    [aCoder encodeDouble:_longitude forKey:@"longitude"];
    
}

@end
