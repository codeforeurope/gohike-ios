//
//  GHReward.m
//
//  Created by Giovanni Maggini on 6/6/13
//  Copyright (c) 2013 gixWorks. All rights reserved.
//

#import "GHReward.h"


@interface GHReward ()

- (id)objectOrNilForKey:(id)aKey fromDictionary:(NSDictionary *)dict;

@end

@implementation GHReward

@synthesize descriptionNl = _descriptionNl;
@synthesize rewardIdentifier = _rewardIdentifier;
@synthesize descriptionEn = _descriptionEn;
@synthesize nameEn = _nameEn;
@synthesize nameNl = _nameNl;
@synthesize imageData = _imageData;


+ (GHReward *)modelObjectWithDictionary:(NSDictionary *)dict
{
    GHReward *instance = [[GHReward alloc] initWithDictionary:dict];
    return instance;
}

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
            self.descriptionNl = [self objectOrNilForKey:@"description_nl" fromDictionary:dict];
            self.rewardIdentifier = [[dict objectForKey:@"id"] doubleValue];
            self.descriptionEn = [self objectOrNilForKey:@"description_en" fromDictionary:dict];
            self.nameEn = [self objectOrNilForKey:@"name_en" fromDictionary:dict];
            self.nameNl = [self objectOrNilForKey:@"name_nl" fromDictionary:dict];
            self.imageData = [self objectOrNilForKey:@"image_data" fromDictionary:dict];

    }
    
    return self;
    
}

- (NSDictionary *)dictionaryRepresentation
{
    NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
    [mutableDict setValue:self.descriptionNl forKey:@"description_nl"];
    [mutableDict setValue:[NSNumber numberWithDouble:self.rewardIdentifier] forKey:@"id"];
    [mutableDict setValue:self.descriptionEn forKey:@"description_en"];
    [mutableDict setValue:self.nameEn forKey:@"name_en"];
    [mutableDict setValue:self.nameNl forKey:@"name_nl"];
    [mutableDict setValue:self.imageData forKey:@"image_data"];

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

    self.descriptionNl = [aDecoder decodeObjectForKey:@"descriptionNl"];
    self.rewardIdentifier = [aDecoder decodeDoubleForKey:@"rewardIdentifier"];
    self.descriptionEn = [aDecoder decodeObjectForKey:@"descriptionEn"];
    self.nameEn = [aDecoder decodeObjectForKey:@"nameEn"];
    self.nameNl = [aDecoder decodeObjectForKey:@"nameNl"];
    self.imageData = [aDecoder decodeObjectForKey:@"imageData"];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{

    [aCoder encodeObject:_descriptionNl forKey:@"descriptionNl"];
    [aCoder encodeDouble:_rewardIdentifier forKey:@"rewardIdentifier"];
    [aCoder encodeObject:_descriptionEn forKey:@"descriptionEn"];
    [aCoder encodeObject:_nameEn forKey:@"nameEn"];
    [aCoder encodeObject:_nameNl forKey:@"nameNl"];
    [aCoder encodeObject:_imageData forKey:@"imageData"];
}


@end
