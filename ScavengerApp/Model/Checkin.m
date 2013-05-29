//
//  Checkin.m
//  ScavengerApp
//
//  Created by Taco van Dijk on 5/23/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "Checkin.h"

@implementation Checkin

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    
    self.locationId = [aDecoder decodeIntForKey:@"locationId"];
    self.routeId = [aDecoder decodeIntForKey:@"routeId"];
    self.timestamp = [aDecoder decodeObjectForKey:@"timestamp"];
    self.uploaded = [aDecoder decodeBoolForKey:@"uploaded"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    
    [aCoder encodeInt:_locationId forKey:@"locationId"];
    [aCoder encodeInt:_routeId forKey:@"routeId"];
    [aCoder encodeObject:_timestamp forKey:@"timestamp"];
    [aCoder encodeBool:_uploaded forKey:@"uploaded"];
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.locationId] forKey:@"locationId"];
    [mutableDict setValue:[NSNumber numberWithDouble:self.routeId] forKey:@"routeId"];
    
    //Use the string for correct conversion to JSON
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss Z"]; 
    NSString *dateToString = [formatter stringFromDate:self.timestamp];
    [mutableDict setValue:dateToString forKey:@"timestamp"];
    
    // Default implementation, not ok with JSON
//    [mutableDict setValue:self.timestamp forKey:@"timestamp"];
    [mutableDict setValue:[NSNumber numberWithBool:self.uploaded] forKey:@"uploaded"];
    
    return [NSDictionary dictionaryWithDictionary:mutableDict];
}


- (NSString *)description
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

@end
