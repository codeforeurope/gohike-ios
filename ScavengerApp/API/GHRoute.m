//
//  GHRoute.m
//
//  Created by Giovanni Maggini on 8/22/13
//  Copyright (c) 2013 gixWorks. All rights reserved.
//

#import "GHRoute.h"
#import "GHImage.h"
#import "GHIcon.h"


NSString *const kGHRoutesPublishedKey = @"published_key";
NSString *const kGHRoutesId = @"id";
NSString *const kGHRoutesImage = @"image";
NSString *const kGHRoutesProfileId = @"profile_id";
NSString *const kGHRoutesDescription = @"description";
NSString *const kGHRoutesName = @"name";
NSString *const kGHRoutesIcon = @"icon";


@interface GHRoute ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation GHRoute

@synthesize publishedKey = _publishedKey;
@synthesize routesIdentifier = _routesIdentifier;
@synthesize image = _image;
@synthesize profileId = _profileId;
@synthesize routesDescription = _routesDescription;
@synthesize name = _name;
@synthesize icon = _icon;


+ (GHRoute *)modelObjectWithDictionary:(NSDictionary *)dict
{
    GHRoute *instance = [[GHRoute alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.publishedKey = [self objectOrNilForKey:kGHRoutesPublishedKey fromDictionary:dict];
            self.routesIdentifier = [[self objectOrNilForKey:kGHRoutesId fromDictionary:dict] doubleValue];
            self.image = [GHImage modelObjectWithDictionary:[dict objectForKey:kGHRoutesImage]];
            self.profileId = [[self objectOrNilForKey:kGHRoutesProfileId fromDictionary:dict] doubleValue];
            self.routesDescription = [self objectOrNilForKey:kGHRoutesDescription fromDictionary:dict];
            self.name = [self objectOrNilForKey:kGHRoutesName fromDictionary:dict];
            self.icon = [GHIcon modelObjectWithDictionary:[dict objectForKey:kGHRoutesIcon]];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.publishedKey forKey:kGHRoutesPublishedKey];
    [mutableDict setValue:[NSNumber numberWithDouble:self.routesIdentifier] forKey:kGHRoutesId];
    [mutableDict setValue:[self.image dictionaryRepresentation] forKey:kGHRoutesImage];
    [mutableDict setValue:[NSNumber numberWithDouble:self.profileId] forKey:kGHRoutesProfileId];
    [mutableDict setValue:self.routesDescription forKey:kGHRoutesDescription];
    [mutableDict setValue:self.name forKey:kGHRoutesName];
    [mutableDict setValue:[self.icon dictionaryRepresentation] forKey:kGHRoutesIcon];

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

    self.publishedKey = [aDecoder decodeObjectForKey:kGHRoutesPublishedKey];
    self.routesIdentifier = [aDecoder decodeDoubleForKey:kGHRoutesId];
    self.image = [aDecoder decodeObjectForKey:kGHRoutesImage];
    self.profileId = [aDecoder decodeDoubleForKey:kGHRoutesProfileId];
    self.routesDescription = [aDecoder decodeObjectForKey:kGHRoutesDescription];
    self.name = [aDecoder decodeObjectForKey:kGHRoutesName];
    self.icon = [aDecoder decodeObjectForKey:kGHRoutesIcon];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_publishedKey forKey:kGHRoutesPublishedKey];
    [aCoder encodeDouble:_routesIdentifier forKey:kGHRoutesId];
    [aCoder encodeObject:_image forKey:kGHRoutesImage];
    [aCoder encodeDouble:_profileId forKey:kGHRoutesProfileId];
    [aCoder encodeObject:_routesDescription forKey:kGHRoutesDescription];
    [aCoder encodeObject:_name forKey:kGHRoutesName];
    [aCoder encodeObject:_icon forKey:kGHRoutesIcon];
}


@end
