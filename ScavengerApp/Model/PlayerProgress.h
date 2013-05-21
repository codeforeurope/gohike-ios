//
//  PlayerProgress.h
//
//  Created by Giovanni Maggini on 5/16/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface PlayerProgress : NSObject <NSCoding>

@property (nonatomic, assign) BOOL completed;
@property (nonatomic, assign) BOOL started;
@property (nonatomic, strong) NSArray *routes;
@property (nonatomic, assign) double profileId;

+ (PlayerProgress *)modelObjectWithDictionary:(NSDictionary *)dict;
- (id)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
