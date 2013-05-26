//
//  GHRoutes.m
//
//  Created by Giovanni Maggini on 5/27/13
//  Copyright (c) 2013 gixWorks. All rights reserved.
//

#import "GHRoutes.h"
#import "GHWaypoints.h"


@interface GHRoutes ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation GHRoutes

@synthesize nameEn = _nameEn;
@synthesize routesIdentifier = _routesIdentifier;
@synthesize iconData = _iconData;
@synthesize nameNl = _nameNl;
@synthesize imageData = _imageData;
@synthesize profileId = _profileId;
@synthesize waypoints = _waypoints;
@synthesize descriptionNl = _descriptionNl;
@synthesize descriptionEn = _descriptionEn;


+ (GHRoutes *)modelObjectWithDictionary:(NSDictionary *)dict
{
    GHRoutes *instance = [[GHRoutes alloc] initWithDictionary:dict];
    return instance;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.nameEn = [self objectOrNilForKey:@"name_en" fromDictionary:dict];
            self.routesIdentifier = [[dict objectForKey:@"id"] doubleValue];
            self.iconData = [self objectOrNilForKey:@"icon_data" fromDictionary:dict];
            self.nameNl = [self objectOrNilForKey:@"name_nl" fromDictionary:dict];
            self.imageData = [self objectOrNilForKey:@"image_data" fromDictionary:dict];
            self.profileId = [[dict objectForKey:@"profile_id"] doubleValue];
    NSObject *receivedGHWaypoints = [dict objectForKey:@"waypoints"];
    NSMutableArray *parsedGHWaypoints = [NSMutableArray array];
    if ([receivedGHWaypoints isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedGHWaypoints) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedGHWaypoints addObject:[GHWaypoints modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedGHWaypoints isKindOfClass:[NSDictionary class]]) {
       [parsedGHWaypoints addObject:[GHWaypoints modelObjectWithDictionary:(NSDictionary *)receivedGHWaypoints]];
    }

    self.waypoints = [NSArray arrayWithArray:parsedGHWaypoints];
            self.descriptionNl = [self objectOrNilForKey:@"description_nl" fromDictionary:dict];
            self.descriptionEn = [self objectOrNilForKey:@"description_en" fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.nameEn forKey:@"name_en"];
    [mutableDict setValue:[NSNumber numberWithDouble:self.routesIdentifier] forKey:@"id"];
    [mutableDict setValue:self.iconData forKey:@"icon_data"];
    [mutableDict setValue:self.nameNl forKey:@"name_nl"];
    [mutableDict setValue:self.imageData forKey:@"image_data"];
    [mutableDict setValue:[NSNumber numberWithDouble:self.profileId] forKey:@"profile_id"];
NSMutableArray *tempArrayForWaypoints = [NSMutableArray array];
    for (NSObject *subArrayObject in self.waypoints) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForWaypoints addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForWaypoints addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForWaypoints] forKey:@"waypoints"];
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
    self.routesIdentifier = [aDecoder decodeDoubleForKey:@"routesIdentifier"];
    self.iconData = [aDecoder decodeObjectForKey:@"iconData"];
    self.nameNl = [aDecoder decodeObjectForKey:@"nameNl"];
    self.imageData = [aDecoder decodeObjectForKey:@"imageData"];
    self.profileId = [aDecoder decodeDoubleForKey:@"profileId"];
    self.waypoints = [aDecoder decodeObjectForKey:@"waypoints"];
    self.descriptionNl = [aDecoder decodeObjectForKey:@"descriptionNl"];
    self.descriptionEn = [aDecoder decodeObjectForKey:@"descriptionEn"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_nameEn forKey:@"nameEn"];
    [aCoder encodeDouble:_routesIdentifier forKey:@"routesIdentifier"];
    [aCoder encodeObject:_iconData forKey:@"iconData"];
    [aCoder encodeObject:_nameNl forKey:@"nameNl"];
    [aCoder encodeObject:_imageData forKey:@"imageData"];
    [aCoder encodeDouble:_profileId forKey:@"profileId"];
    [aCoder encodeObject:_waypoints forKey:@"waypoints"];
    [aCoder encodeObject:_descriptionNl forKey:@"descriptionNl"];
    [aCoder encodeObject:_descriptionEn forKey:@"descriptionEn"];
}


@end
