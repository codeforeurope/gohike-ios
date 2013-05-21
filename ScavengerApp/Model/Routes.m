//
//  Routes.m
//
//  Created by Giovanni Maggini on 5/16/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "Routes.h"


@interface Routes ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Routes

@synthesize touchedExtraPointsIds = _touchedExtraPointsIds;
@synthesize touchedPointsIds = _touchedPointsIds;
@synthesize routeId = _routeId;
@synthesize completed = _completed;


+ (Routes *)modelObjectWithDictionary:(NSDictionary *)dict
{
    Routes *instance = [[Routes alloc] initWithDictionary:dict];
    return instance;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.touchedExtraPointsIds = [self objectOrNilForKey:@"touchedExtraPointsIds" fromDictionary:dict];
            self.touchedPointsIds = [self objectOrNilForKey:@"touchedPointsIds" fromDictionary:dict];
            self.routeId = [[dict objectForKey:@"routeId"] doubleValue];
            self.completed = [[dict objectForKey:@"completed"] boolValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
NSMutableArray *tempArrayForTouchedExtraPointsIds = [NSMutableArray array];
    for (NSObject *subArrayObject in self.touchedExtraPointsIds) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForTouchedExtraPointsIds addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForTouchedExtraPointsIds addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForTouchedExtraPointsIds] forKey:@"touchedExtraPointsIds"];
NSMutableArray *tempArrayForTouchedPointsIds = [NSMutableArray array];
    for (NSObject *subArrayObject in self.touchedPointsIds) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForTouchedPointsIds addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForTouchedPointsIds addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForTouchedPointsIds] forKey:@"touchedPointsIds"];
    [mutableDict setValue:[NSNumber numberWithDouble:self.routeId] forKey:@"routeId"];
    [mutableDict setValue:[NSNumber numberWithBool:self.completed] forKey:@"completed"];

    return [NSDictionary dictionaryWithDictionary:mutableDict];
}

- (NSString *)description 
{
    return [NSString stringWithFormat:@"%@", [self dictionaryRepresentation]];
}

#pragma mark - Helper Method
- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict
{
    id object = [dict objectForKey:aKey];
    return [object isEqual:[NSNull null]] ? nil : object;
}


#pragma mark - NSCoding Methods

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];

    self.touchedExtraPointsIds = [aDecoder decodeObjectForKey:@"touchedExtraPointsIds"];
    self.touchedPointsIds = [aDecoder decodeObjectForKey:@"touchedPointsIds"];
    self.routeId = [aDecoder decodeDoubleForKey:@"routeId"];
    self.completed = [aDecoder decodeBoolForKey:@"completed"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_touchedExtraPointsIds forKey:@"touchedExtraPointsIds"];
    [aCoder encodeObject:_touchedPointsIds forKey:@"touchedPointsIds"];
    [aCoder encodeDouble:_routeId forKey:@"routeId"];
    [aCoder encodeBool:_completed forKey:@"completed"];
}


@end
