//
//  GHGame.h
//
//  Created by Giovanni Maggini on 6/6/13
//  Copyright (c) 2013 gixWorks. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface GHGameData : NSObject <NSCoding>

@property (nonatomic, strong) NSString *version;
@property (nonatomic, strong) NSArray *profiles;

+ (GHGameData *)modelObjectWithDictionary:(NSDictionary *)dict;
- (id)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
