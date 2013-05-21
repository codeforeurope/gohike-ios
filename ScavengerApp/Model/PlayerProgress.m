//
//  PlayerProgress.m
//
//  Created by Giovanni Maggini on 5/16/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import "PlayerProgress.h"
#import "Routes.h"


@interface PlayerProgress ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation PlayerProgress

@synthesize completed = _completed;
@synthesize started = _started;
@synthesize routes = _routes;
@synthesize profileId = _profileId;


+ (PlayerProgress *)modelObjectWithDictionary:(NSDictionary *)dict
{
    PlayerProgress *instance = [[PlayerProgress alloc] initWithDictionary:dict];
    return instance;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.completed = [[dict objectForKey:@"completed"] boolValue];
            self.started = [[dict objectForKey:@"started"] boolValue];
    NSObject *receivedRoutes = [dict objectForKey:@"routes"];
    NSMutableArray *parsedRoutes = [NSMutableArray array];
    if ([receivedRoutes isKindOfClass:[NSArray class]]) {
        for (NSDictionary *item in (NSArray *)receivedRoutes) {
            if ([item isKindOfClass:[NSDictionary class]]) {
                [parsedRoutes addObject:[Routes modelObjectWithDictionary:item]];
            }
       }
    } else if ([receivedRoutes isKindOfClass:[NSDictionary class]]) {
       [parsedRoutes addObject:[Routes modelObjectWithDictionary:(NSDictionary *)receivedRoutes]];
    }

    self.routes = [NSArray arrayWithArray:parsedRoutes];
            self.profileId = [[dict objectForKey:@"profileId"] doubleValue];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:[NSNumber numberWithBool:self.completed] forKey:@"completed"];
    [mutableDict setValue:[NSNumber numberWithBool:self.started] forKey:@"started"];
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

    self.completed = [aDecoder decodeBoolForKey:@"completed"];
    self.started = [aDecoder decodeBoolForKey:@"started"];
    self.routes = [aDecoder decodeObjectForKey:@"routes"];
    self.profileId = [aDecoder decodeDoubleForKey:@"profileId"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeBool:_completed forKey:@"completed"];
    [aCoder encodeBool:_completed forKey:@"started"];
    [aCoder encodeObject:_routes forKey:@"routes"];
    [aCoder encodeDouble:_profileId forKey:@"profileId"];
}


@end
