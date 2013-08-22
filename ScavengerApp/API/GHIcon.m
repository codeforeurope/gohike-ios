//
//  GHIcon.m
//
//  Created by Giovanni Maggini on 8/22/13
//  Copyright (c) 2013 gixWorks. All rights reserved.
//

#import "GHIcon.h"


NSString *const kGHIconMd5 = @"md5";
NSString *const kGHIconUrl = @"url";


@interface GHIcon ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation GHIcon

@synthesize md5 = _md5;
@synthesize url = _url;


+ (GHIcon *)modelObjectWithDictionary:(NSDictionary *)dict
{
    GHIcon *instance = [[GHIcon alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.md5 = [self objectOrNilForKey:kGHIconMd5 fromDictionary:dict];
            self.url = [self objectOrNilForKey:kGHIconUrl fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.md5 forKey:kGHIconMd5];
    [mutableDict setValue:self.url forKey:kGHIconUrl];

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

    self.md5 = [aDecoder decodeObjectForKey:kGHIconMd5];
    self.url = [aDecoder decodeObjectForKey:kGHIconUrl];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_md5 forKey:kGHIconMd5];
    [aCoder encodeObject:_url forKey:kGHIconUrl];
}


@end
