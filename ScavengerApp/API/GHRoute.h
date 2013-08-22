//
//  GHRoute.h
//
//  Created by Giovanni Maggini on 8/22/13
//  Copyright (c) 2013 gixWorks. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GHImage, GHIcon;

@interface GHRoute : NSObject <NSCoding>

@property (nonatomic, strong) NSString *publishedKey;
@property (nonatomic, assign) double routesIdentifier;
@property (nonatomic, strong) GHImage *image;
@property (nonatomic, assign) double profileId;
@property (nonatomic, strong) NSString *routesDescription;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) GHIcon *icon;

+ (GHRoute *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
