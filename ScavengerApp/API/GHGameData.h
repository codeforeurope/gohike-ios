//
//  GHGameData.h
//
//  Created by Giovanni Maggini on 5/27/13
//  Copyright (c) 2013 gixWorks. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface GHGameData : NSObject <NSCoding>

@property (nonatomic, strong) NSArray *profiles;

+ (GHGameData *)modelObjectWithDictionary:(NSDictionary *)dict;
- (id)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
