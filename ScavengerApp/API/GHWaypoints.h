//
//  GHWaypoints.h
//
//  Created by Giovanni Maggini on 6/6/13
//  Copyright (c) 2013 gixWorks. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface GHWaypoints : NSObject <NSCoding>

@property (nonatomic, strong) NSString *nameEn;
@property (nonatomic, strong) NSString *longitude;
@property (nonatomic, strong) NSString *imageData;
@property (nonatomic, strong) NSString *nameNl;
@property (nonatomic, strong) NSString *latitude;
@property (nonatomic, assign) double locationId;
@property (nonatomic, assign) double rank;
@property (nonatomic, strong) NSString *descriptionNl;
@property (nonatomic, assign) double routeId;
@property (nonatomic, strong) NSString *descriptionEn;

+ (GHWaypoints *)modelObjectWithDictionary:(NSDictionary *)dict;
- (id)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
