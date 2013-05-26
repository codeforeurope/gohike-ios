//
//  GHProfiles.m
//
//  Created by Giovanni Maggini on 5/27/13
//  Copyright (c) 2013 gixWorks. All rights reserved.
//

#import "GHProfiles.h"
#import "GHRoutes.h"


@interface GHProfiles ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation GHProfiles

@synthesize routes = _routes;
@synthesize nameEn = _nameEn;
@synthesize profilesIdentifier = _profilesIdentifier;
@synthesize iconData = _iconData;
@synthesize nameNl = _nameNl;
@synthesize imageData = _imageData;
@synthesize descriptionNl = _descriptionNl;
@synthesize descriptionEn = _descriptionEn;


+ (GHProfiles *)modelObjectWithDictionary:(NSDictionary *)dict
{
    GHProfiles *instance = [[GHProfiles alloc] initWithDictionary:dict];
    return instance;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
    NSObject *receivedGHRoutes = [dict objectForKey:@"routes"];
    NSMutableArray *parsedGHRoutes = [NSMutableArray array];
    if ([receivedGHRoutes isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedGHRoutes) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedGHRoutes addObject:[GHRoutes modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedGHRoutes isKindOfClass:[NSDictionary class]]) {
       [parsedGHRoutes addObject:[GHRoutes modelObjectWithDictionary:(NSDictionary *)receivedGHRoutes]];
    }

    self.routes = [NSArray arrayWithArray:parsedGHRoutes];
            self.nameEn = [self objectOrNilForKey:@"name_en" fromDictionary:dict];
            self.profilesIdentifier = [[dict objectForKey:@"id"] doubleValue];
            self.iconData = [self objectOrNilForKey:@"icon_data" fromDictionary:dict];
            self.nameNl = [self objectOrNilForKey:@"name_nl" fromDictionary:dict];
            self.imageData = [self objectOrNilForKey:@"image_data" fromDictionary:dict];
            self.descriptionNl = [self objectOrNilForKey:@"description_nl" fromDictionary:dict];
            self.descriptionEn = [self objectOrNilForKey:@"description_en" fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
NSMutableArray *tempArrayForRoutes = [NSMutableArray array];
    for (NSObject *subArrayObject in self.routes) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForRoutes addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForRoutes addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForRoutes] forKey:@"routes"];
    [mutableDict setValue:self.nameEn forKey:@"name_en"];
    [mutableDict setValue:[NSNumber numberWithDouble:self.profilesIdentifier] forKey:@"id"];
    [mutableDict setValue:self.iconData forKey:@"icon_data"];
    [mutableDict setValue:self.nameNl forKey:@"name_nl"];
    [mutableDict setValue:self.imageData forKey:@"image_data"];
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

    self.routes = [aDecoder decodeObjectForKey:@"routes"];
    self.nameEn = [aDecoder decodeObjectForKey:@"nameEn"];
    self.profilesIdentifier = [aDecoder decodeDoubleForKey:@"profilesIdentifier"];
    self.iconData = [aDecoder decodeObjectForKey:@"iconData"];
    self.nameNl = [aDecoder decodeObjectForKey:@"nameNl"];
    self.imageData = [aDecoder decodeObjectForKey:@"imageData"];
    self.descriptionNl = [aDecoder decodeObjectForKey:@"descriptionNl"];
    self.descriptionEn = [aDecoder decodeObjectForKey:@"descriptionEn"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_routes forKey:@"routes"];
    [aCoder encodeObject:_nameEn forKey:@"nameEn"];
    [aCoder encodeDouble:_profilesIdentifier forKey:@"profilesIdentifier"];
    [aCoder encodeObject:_iconData forKey:@"iconData"];
    [aCoder encodeObject:_nameNl forKey:@"nameNl"];
    [aCoder encodeObject:_imageData forKey:@"imageData"];
    [aCoder encodeObject:_descriptionNl forKey:@"descriptionNl"];
    [aCoder encodeObject:_descriptionEn forKey:@"descriptionEn"];
}


@end
