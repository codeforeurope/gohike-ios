//
//  GHReward.h
//
//  Created by Giovanni Maggini on 6/6/13
//  Copyright (c) 2013 gixWorks. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface GHReward : NSObject <NSCoding>

@property (nonatomic, strong) NSString *descriptionNl;
@property (nonatomic, assign) double rewardIdentifier;
@property (nonatomic, strong) NSString *descriptionEn;
@property (nonatomic, strong) NSString *nameEn;
@property (nonatomic, strong) NSString *nameNl;
@property (nonatomic, strong) NSString *imageData;

+ (GHReward *)modelObjectWithDictionary:(NSDictionary *)dict;
- (id)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
