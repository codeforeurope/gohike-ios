//
//  Route.h
//
//  Created by Giovanni Maggini on 5/16/13
//  Copyright (c) 2013 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface Route : NSObject <NSCoding>

@property (nonatomic, assign) NSInteger profileid;
@property (nonatomic, assign) NSInteger routeId;
@property (nonatomic, strong) NSString *picture;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *internalBaseClassDescription;
@property (nonatomic, strong) NSArray *locations;

+ (Route *)modelObjectWithDictionary:(NSDictionary *)dict;
- (id)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
