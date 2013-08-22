//
//  GHWithin.h
//
//  Created by Giovanni Maggini on 8/21/13
//  Copyright (c) 2013 gixWorks. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface GHWithin : NSObject <NSCoding>

@property (nonatomic, strong) NSString *countryCode;
@property (nonatomic, assign) double withinIdentifier;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *stateProvince;

+ (GHWithin *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
