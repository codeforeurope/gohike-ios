//
//  Routes.h
//
//  Created by Giovanni Maggini on 5/16/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Routes : NSObject <NSCoding>

@property (nonatomic, strong) NSArray *touchedExtraPointsIds;
@property (nonatomic, strong) NSArray *touchedPointsIds;
@property (nonatomic, assign) double routeId;
@property (nonatomic, assign) BOOL completed;

+ (Routes *)modelObjectWithDictionary:(NSDictionary *)dict;
- (id)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
