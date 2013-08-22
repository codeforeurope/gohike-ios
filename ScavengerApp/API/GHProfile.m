//
//  GHProfile.m
//
//  Created by Giovanni Maggini on 8/22/13
//  Copyright (c) 2013 gixWorks. All rights reserved.
//

#import "GHProfile.h"
#import "GHImage.h"
#import "GHRoute.h"


NSString *const kGHProfileId = @"id";
NSString *const kGHProfileName = @"name";
NSString *const kGHProfileImage = @"image";
NSString *const kGHProfileRoutes = @"routes";


@interface GHProfile ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation GHProfile

@synthesize internalBaseClassIdentifier = _internalBaseClassIdentifier;
@synthesize name = _name;
@synthesize image = _image;
@synthesize routes = _routes;


+ (GHProfile *)modelObjectWithDictionary:(NSDictionary *)dict
{
    GHProfile *instance = [[GHProfile alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.internalBaseClassIdentifier = [[self objectOrNilForKey:kGHProfileId fromDictionary:dict] doubleValue];
            self.name = [self objectOrNilForKey:kGHProfileName fromDictionary:dict];
            self.image = [GHImage modelObjectWithDictionary:[dict objectForKey:kGHProfileImage]];
    NSObject *receivedGHRoutes = [dict objectForKey:kGHProfileRoutes];
    NSMutableArray *parsedGHRoutes = [NSMutableArray array];
    if ([receivedGHRoutes isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedGHRoutes) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedGHRoutes addObject:[GHRoute modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedGHRoutes isKindOfClass:[NSDictionary class]]) {
       [parsedGHRoutes addObject:[GHRoute modelObjectWithDictionary:(NSDictionary *)receivedGHRoutes]];
    }

    self.routes = [NSArray arrayWithArray:parsedGHRoutes];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.internalBaseClassIdentifier] forKey:kGHProfileId];
    [mutableDict setValue:self.name forKey:kGHProfileName];
    [mutableDict setValue:[self.image dictionaryRepresentation] forKey:kGHProfileImage];
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
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForRoutes] forKey:@"kGHProfileRoutes"];

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

    self.internalBaseClassIdentifier = [aDecoder decodeDoubleForKey:kGHProfileId];
    self.name = [aDecoder decodeObjectForKey:kGHProfileName];
    self.image = [aDecoder decodeObjectForKey:kGHProfileImage];
    self.routes = [aDecoder decodeObjectForKey:kGHProfileRoutes];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeDouble:_internalBaseClassIdentifier forKey:kGHProfileId];
    [aCoder encodeObject:_name forKey:kGHProfileName];
    [aCoder encodeObject:_image forKey:kGHProfileImage];
    [aCoder encodeObject:_routes forKey:kGHProfileRoutes];
}


@end
