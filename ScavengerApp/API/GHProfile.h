//
//  GHProfile.h
//
//  Created by Giovanni Maggini on 8/22/13
//  Copyright (c) 2013 gixWorks. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GHImage;

@interface GHProfile : NSObject <NSCoding>

@property (nonatomic, assign) double internalBaseClassIdentifier;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) GHImage *image;
@property (nonatomic, strong) NSArray *routes;

+ (GHProfile *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
