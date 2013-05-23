//
//  Route.m
//
//  Created by Giovanni Maggini on 5/16/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "Route.h"


@interface Route ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation Route

@synthesize profileid = _profileid;
@synthesize picture = _picture;
@synthesize name = _name;
@synthesize locations = _locations;
@synthesize internalBaseClassDescription = _internalBaseClassDescription;


+ (Route *)modelObjectWithDictionary:(NSDictionary *)dict
{
    Route *instance = [[Route alloc] initWithDictionary:dict];
    return instance;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.profileid = [[dict objectForKey:@"profileid"] doubleValue];
            self.picture = [self objectOrNilForKey:@"picture" fromDictionary:dict];
            self.name = [self objectOrNilForKey:@"name" fromDictionary:dict];
            self.locations = [self objectOrNilForKey:@"locations" fromDictionary:dict];
            self.internalBaseClassDescription = [self objectOrNilForKey:@"description" fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithDouble:self.profileid] forKey:@"profileid"];
    [mutableDict setValue:self.picture forKey:@"picture"];
    [mutableDict setValue:self.name forKey:@"name"];
    [mutableDict setValue:self.locations forKey:@"locations"];
    [mutableDict setValue:self.internalBaseClassDescription forKey:@"description"];

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

    self.profileid = [aDecoder decodeDoubleForKey:@"profileid"];
    self.picture = [aDecoder decodeObjectForKey:@"picture"];
    self.name = [aDecoder decodeObjectForKey:@"name"];
    self.locations = [aDecoder decodeObjectForKey:@"locations"];
    self.internalBaseClassDescription = [aDecoder decodeObjectForKey:@"internalBaseClassDescription"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeDouble:_profileid forKey:@"profileid"];
    [aCoder encodeObject:_picture forKey:@"picture"];
    [aCoder encodeObject:_name forKey:@"name"];
    [aCoder encodeObject:_locations forKey:@"locations"];
    [aCoder encodeObject:_internalBaseClassDescription forKey:@"internalBaseClassDescription"];
}


@end
