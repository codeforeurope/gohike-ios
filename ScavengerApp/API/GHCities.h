//
//  GHCities.h
//
//  Created by Giovanni Maggini on 8/25/13
//  Copyright (c) 2013 gixWorks. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface GHCities : NSObject <NSCoding>

@property (nonatomic, strong) NSArray *within;
@property (nonatomic, strong) NSArray *other;

+ (GHCities *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
