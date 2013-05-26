//
//  GHWaypoints.m
//
//  Created by Giovanni Maggini on 5/27/13
//  Copyright (c) 2013 gixWorks. All rights reserved.
//

#import "GHWaypoints.h"


@interface GHWaypoints ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation GHWaypoints

@synthesize nameEn = _nameEn;
@synthesize nameNl = _nameNl;
@synthesize locationId = _locationId;
@synthesize rank = _rank;
@synthesize routeId = _routeId;
@synthesize descriptionNl = _descriptionNl;
@synthesize descriptionEn = _descriptionEn;


+ (GHWaypoints *)modelObjectWithDictionary:(NSDictionary *)dict
{
    GHWaypoints *instance = [[GHWaypoints alloc] initWithDictionary:dict];
    return instance;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.nameEn = [self objectOrNilForKey:@"name_en" fromDictionary:dict];
            self.nameNl = [self objectOrNilForKey:@"name_nl" fromDictionary:dict];
            self.locationId = [[dict objectForKey:@"location_id"] doubleValue];
            self.rank = [[dict objectForKey:@"rank"] doubleValue];
            self.routeId = [[dict objectForKey:@"route_id"] doubleValue];
            self.descriptionNl = [self objectOrNilForKey:@"description_nl" fromDictionary:dict];
            self.descriptionEn = [self objectOrNilForKey:@"description_en" fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.nameEn forKey:@"name_en"];
    [mutableDict setValue:self.nameNl forKey:@"name_nl"];
    [mutableDict setValue:[NSNumber numberWithDouble:self.locationId] forKey:@"location_id"];
    [mutableDict setValue:[NSNumber numberWithDouble:self.rank] forKey:@"rank"];
    [mutableDict setValue:[NSNumber numberWithDouble:self.routeId] forKey:@"route_id"];
    [mutableDict setValue:self.descriptionNl forKey:@"description_nl"];
    [mutableDict setValue:self.descriptionEn forKey:@"description_en"];

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

    self.nameEn = [aDecoder decodeObjectForKey:@"nameEn"];
    self.nameNl = [aDecoder decodeObjectForKey:@"nameNl"];
    self.locationId = [aDecoder decodeDoubleForKey:@"locationId"];
    self.rank = [aDecoder decodeDoubleForKey:@"rank"];
    self.routeId = [aDecoder decodeDoubleForKey:@"routeId"];
    self.descriptionNl = [aDecoder decodeObjectForKey:@"descriptionNl"];
    self.descriptionEn = [aDecoder decodeObjectForKey:@"descriptionEn"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_nameEn forKey:@"nameEn"];
    [aCoder encodeObject:_nameNl forKey:@"nameNl"];
    [aCoder encodeDouble:_locationId forKey:@"locationId"];
    [aCoder encodeDouble:_rank forKey:@"rank"];
    [aCoder encodeDouble:_routeId forKey:@"routeId"];
    [aCoder encodeObject:_descriptionNl forKey:@"descriptionNl"];
    [aCoder encodeObject:_descriptionEn forKey:@"descriptionEn"];
}


@end
