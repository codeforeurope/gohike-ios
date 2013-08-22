//
//  GHImage.m
//
//  Created by Giovanni Maggini on 8/22/13
//  Copyright (c) 2013 gixWorks. All rights reserved.
//

#import "GHImage.h"


NSString *const kGHImageMd5 = @"md5";
NSString *const kGHImageUrl = @"url";


@interface GHImage ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation GHImage

@synthesize md5 = _md5;
@synthesize url = _url;


+ (GHImage *)modelObjectWithDictionary:(NSDictionary *)dict
{
    GHImage *instance = [[GHImage alloc] initWithDictionary:dict];
    return instance;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.md5 = [self objectOrNilForKey:kGHImageMd5 fromDictionary:dict];
            self.url = [self objectOrNilForKey:kGHImageUrl fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.md5 forKey:kGHImageMd5];
    [mutableDict setValue:self.url forKey:kGHImageUrl];

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

    self.md5 = [aDecoder decodeObjectForKey:kGHImageMd5];
    self.url = [aDecoder decodeObjectForKey:kGHImageUrl];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_md5 forKey:kGHImageMd5];
    [aCoder encodeObject:_url forKey:kGHImageUrl];
}


@end
