//
//  SelectionScreen.m
//
//  Created by Giovanni Maggini on 5/16/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "RouteProfiles.h"
#import "Profiles.h"


@interface RouteProfiles ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation RouteProfiles

@synthesize lastupdate = _lastupdate;
@synthesize profiles = _profiles;


+ (RouteProfiles *)modelObjectWithDictionary:(NSDictionary *)dict
{
    RouteProfiles *instance = [[RouteProfiles alloc] initWithDictionary:dict];
    return instance;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.lastupdate = [self objectOrNilForKey:@"lastupdate" fromDictionary:dict];
    NSObject *receivedProfiles = [dict objectForKey:@"profiles"];
    NSMutableArray *parsedProfiles = [NSMutableArray array];
    if ([receivedProfiles isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedProfiles) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedProfiles addObject:[Profiles modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedProfiles isKindOfClass:[NSDictionary class]]) {
       [parsedProfiles addObject:[Profiles modelObjectWithDictionary:(NSDictionary *)receivedProfiles]];
    }

    self.profiles = [NSArray arrayWithArray:parsedProfiles];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.lastupdate forKey:@"lastupdate"];
NSMutableArray *tempArrayForProfiles = [NSMutableArray array];
    for (NSObject *subArrayObject in self.profiles) {
        if([subArrayObject respondsToSelector:@selector(dictionaryRepresentation)]) {
            // This class is a model object
            [tempArrayForProfiles addObject:[subArrayObject performSelector:@selector(dictionaryRepresentation)]];
        } else {
            // Generic object
            [tempArrayForProfiles addObject:subArrayObject];
        }
    }
    [mutableDict setValue:[NSArray arrayWithArray:tempArrayForProfiles] forKey:@"profiles"];

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

    self.lastupdate = [aDecoder decodeObjectForKey:@"lastupdate"];
    self.profiles = [aDecoder decodeObjectForKey:@"profiles"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_lastupdate forKey:@"lastupdate"];
    [aCoder encodeObject:_profiles forKey:@"profiles"];
}


@end
