//
//  GHWithin.m
//
//  Created by Giovanni Maggini on 8/21/13
//  Copyright (c) 2013 gixWorks. All rights reserved.
//

#import "GHCity.h"


NSString *const kGHCityCountryCode = @"country_code";
NSString *const kGHCityId = @"id";
NSString *const kGHCityName = @"name";
NSString *const kGHCityStateProvince = @"state_province";


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
            self.countryCode = [self objectOrNilForKey:kGHCityCountryCode fromDictionary:dict];
            self.cityIdentifier = [[self objectOrNilForKey:kGHCityId fromDictionary:dict] intValue];
            self.name = [self objectOrNilForKey:kGHCityName fromDictionary:dict];
            self.stateProvince = [self objectOrNilForKey:kGHCityStateProvince fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.countryCode forKey:kGHCityCountryCode];
    [mutableDict setValue:[NSNumber numberWithInt:self.cityIdentifier] forKey:kGHCityId];
    [mutableDict setValue:self.name forKey:kGHCityName];
    [mutableDict setValue:self.stateProvince forKey:kGHCityStateProvince];

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

    self.countryCode = [aDecoder decodeObjectForKey:kGHCityCountryCode];
    self.cityIdentifier = [aDecoder decodeIntForKey:kGHCityId];
    self.name = [aDecoder decodeObjectForKey:kGHCityName];
    self.stateProvince = [aDecoder decodeObjectForKey:kGHCityStateProvince];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_countryCode forKey:kGHCityCountryCode];
    [aCoder encodeInt:_withinIdentifier forKey:kGHCityId];
    [aCoder encodeObject:_name forKey:kGHCityName];
    [aCoder encodeObject:_stateProvince forKey:kGHCityStateProvince];
}


@end
