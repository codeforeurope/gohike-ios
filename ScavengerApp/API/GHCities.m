//
//  GHCities.m
//
//  Created by Giovanni Maggini on 8/25/13
//  Copyright (c) 2013 gixWorks. All rights reserved.
//

#import "GHCities.h"
#import "GHCity.h"


NSString *const kGHCitiesWithin = @"within";
NSString *const kGHCitiesOther = @"other";


@interface GHCities ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation GHCities

@synthesize within = _within;
@synthesize other = _other;


+ (GHCities *)modelObjectWithDictionary:(NSDictionary *)dict
{
    GHCities *instance = [[GHCities alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
    NSObject *receivedGHWithin = [dict objectForKey:kGHCitiesWithin];
    NSMutableArray *parsedGHWithin = [NSMutableArray array];
    if ([receivedGHWithin isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedGHWithin) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedGHWithin addObject:[GHCity modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedGHWithin isKindOfClass:[NSDictionary class]]) {
       [parsedGHWithin addObject:[GHCity modelObjectWithDictionary:(NSDictionary *)receivedGHWithin]];
    }

    self.within = [NSArray arrayWithArray:parsedGHWithin];
    NSObject *receivedGHOther = [dict objectForKey:kGHCitiesOther];
    NSMutableArray *parsedGHOther = [NSMutableArray array];
    if ([receivedGHOther isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedGHOther) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedGHOther addObject:[GHCity modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedGHOther isKindOfClass:[NSDictionary class]]) {
       [parsedGHOther addObject:[GHCity modelObjectWithDictionary:(NSDictionary *)receivedGHOther]];
    }

    self.other = [NSArray arrayWithArray:parsedGHOther];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
NSMutableArray *tempArrayForWithin = [NSMutableArray array];
    for (NSObject *subArrayObject in self.within) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForWithin addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForWithin addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForWithin] forKey:@"kGHCitiesWithin"];
NSMutableArray *tempArrayForOther = [NSMutableArray array];
    for (NSObject *subArrayObject in self.other) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForOther addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForOther addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForOther] forKey:@"kGHCitiesOther"];

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

    self.within = [aDecoder decodeObjectForKey:kGHCitiesWithin];
    self.other = [aDecoder decodeObjectForKey:kGHCitiesOther];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_within forKey:kGHCitiesWithin];
    [aCoder encodeObject:_other forKey:kGHCitiesOther];
}


@end
