//
//  GHRoutes.h
//
//  Created by Giovanni Maggini on 5/27/13
//  Copyright (c) 2013 gixWorks. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface GHRoutes : NSObject <NSCoding>

@property (nonatomic, strong) NSString *nameEn;
@property (nonatomic, assign) double routesIdentifier;
@property (nonatomic, assign) id iconData;
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
