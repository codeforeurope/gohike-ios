//
//  Profiles.m
//
//  Created by Giovanni Maggini on 5/21/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "Profiles.h"


@interface Profiles ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Profiles

@synthesize name = _name;
@synthesize picture = _picture;
@synthesize profileId = _profileId;


+ (Profiles *)modelObjectWithDictionary:(NSDictionary *)dict
{
    Profiles *instance = [[Profiles alloc] initWithDictionary:dict];
    return instance;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.name = [self objectOrNilForKey:@"name" fromDictionary:dict];
            self.picture = [self objectOrNilForKey:@"picture" fromDictionary:dict];
            self.profileId = [[dict objectForKey:@"profileId"] doubleValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.name forKey:@"name"];
    [mutableDict setValue:self.picture forKey:@"picture"];
    [mutableDict setValue:[NSNumber numberWithDouble:self.profileId] forKey:@"profileId"];

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

    self.name = [aDecoder decodeObjectForKey:@"name"];
    self.picture = [aDecoder decodeObjectForKey:@"picture"];
    self.profileId = [aDecoder decodeDoubleForKey:@"profileId"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_picture forKey:@"picture"];
    [aCoder encodeDouble:_profileId forKey:@"profileId"];
}


@end
