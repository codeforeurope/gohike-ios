//
//  GHRoutes.h
//
//  Created by Giovanni Maggini on 6/6/13
//  Copyright (c) 2013 gixWorks. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GHReward;

@interface GHRoutes : NSObject <NSCoding>

@property (nonatomic, strong) GHReward *reward;
@property (nonatomic, assign) id myProperty1;
@property (nonatomic, strong) NSString *nameEn;
@property (nonatomic, assign) double routesIdentifier;
@property (nonatomic, strong) NSString *iconData;
@property (nonatomic, strong) NSString *nameNl;
@property (nonatomic, strong) NSString *imageData;
@property (nonatomic, assign) double profileId;
@property (nonatomic, strong) NSArray *waypoints;
@property (nonatomic, strong) NSString *descriptionNl;
@property (nonatomic, strong) NSString *descriptionEn;

+ (GHRoutes *)modelObjectWithDictionary:(NSDictionary *)dict;
- (id)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
