//
//  GHWithin.m
//
//  Created by Giovanni Maggini on 8/21/13
//  Copyright (c) 2013 gixWorks. All rights reserved.
//

#import "GHCity.h"


NSString *const kGHWithinCountryCode = @"country_code";
NSString *const kGHWithinId = @"id";
NSString *const kGHWithinName = @"name";
NSString *const kGHWithinStateProvince = @"state_province";


@interface GHCity ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation GHCity

@synthesize countryCode = _countryCode;
@synthesize cityIdentifier = _withinIdentifier;
@synthesize name = _name;
@synthesize stateProvince = _stateProvince;


+ (GHCity *)modelObjectWithDictionary:(NSDictionary *)dict
{
    GHCity *instance = [[GHCity alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.countryCode = [self objectOrNilForKey:kGHWithinCountryCode fromDictionary:dict];
            self.cityIdentifier = [[self objectOrNilForKey:kGHWithinId fromDictionary:dict] doubleValue];
            self.name = [self objectOrNilForKey:kGHWithinName fromDictionary:dict];
            self.stateProvince = [self objectOrNilForKey:kGHWithinStateProvince fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.countryCode forKey:kGHWithinCountryCode];
    [mutableDict setValue:[NSNumber numberWithDouble:self.cityIdentifier] forKey:kGHWithinId];
    [mutableDict setValue:self.name forKey:kGHWithinName];
    [mutableDict setValue:self.stateProvince forKey:kGHWithinStateProvince];

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

    self.countryCode = [aDecoder decodeObjectForKey:kGHWithinCountryCode];
    self.cityIdentifier = [aDecoder decodeDoubleForKey:kGHWithinId];
    self.name = [aDecoder decodeObjectForKey:kGHWithinName];
    self.stateProvince = [aDecoder decodeObjectForKey:kGHWithinStateProvince];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_countryCode forKey:kGHWithinCountryCode];
    [aCoder encodeDouble:_withinIdentifier forKey:kGHWithinId];
    [aCoder encodeObject:_name forKey:kGHWithinName];
    [aCoder encodeObject:_stateProvince forKey:kGHWithinStateProvince];
}


@end
