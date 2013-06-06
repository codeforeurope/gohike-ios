//
//  GHGame.m
//
//  Created by Giovanni Maggini on 6/6/13
//  Copyright (c) 2013 gixWorks. All rights reserved.
//

#import "GHGameData.h"
#import "GHProfiles.h"


@interface GHGameData ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation GHGameData

@synthesize version = _version;
@synthesize profiles = _profiles;


+ (GHGameData *)modelObjectWithDictionary:(NSDictionary *)dict
{
    GHGameData *instance = [[GHGameData alloc] initWithDictionary:dict];
    return instance;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.version = [self objectOrNilForKey:@"version" fromDictionary:dict];
    NSObject *receivedGHProfiles = [dict objectForKey:@"profiles"];
    NSMutableArray *parsedGHProfiles = [NSMutableArray array];
    if ([receivedGHProfiles isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedGHProfiles) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedGHProfiles addObject:[GHProfiles modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedGHProfiles isKindOfClass:[NSDictionary class]]) {
       [parsedGHProfiles addObject:[GHProfiles modelObjectWithDictionary:(NSDictionary *)receivedGHProfiles]];
    }

    self.profiles = [NSArray arrayWithArray:parsedGHProfiles];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.version forKey:@"version"];
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

    self.version = [aDecoder decodeObjectForKey:@"version"];
    self.profiles = [aDecoder decodeObjectForKey:@"profiles"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_version forKey:@"version"];
    [aCoder encodeObject:_profiles forKey:@"profiles"];
}


@end
