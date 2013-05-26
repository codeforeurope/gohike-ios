//
//  GHWaypoints.h
//
//  Created by Giovanni Maggini on 5/27/13
//  Copyright (c) 2013 gixWorks. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface GHWaypoints : NSObject <NSCoding>

@property (nonatomic, strong) NSString *nameEn;
@property (nonatomic, strong) NSString *nameNl;
@property (nonatomic, assign) double locationId;
@property (nonatomic, assign) double rank;
@property (nonatomic, assign) double routeId;
@property (nonatomic, strong) NSString *descriptionNl;
@property (nonatomic, strong) NSString *descriptionEn;

+ (GHWaypoints *)modelObjectWithDictionary:(NSDictionary *)dict;
- (id)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
