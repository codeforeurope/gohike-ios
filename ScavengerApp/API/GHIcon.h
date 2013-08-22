//
//  GHIcon.h
//
//  Created by Giovanni Maggini on 8/22/13
//  Copyright (c) 2013 gixWorks. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface GHIcon : NSObject <NSCoding>

@property (nonatomic, strong) NSString *md5;
@property (nonatomic, strong) NSString *url;

+ (GHIcon *)modelObjectWithDictionary:(NSDictionary *)dict;
- (instancetype)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
