//
//  GHProfiles.h
//
//  Created by Giovanni Maggini on 5/27/13
//  Copyright (c) 2013 gixWorks. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface GHProfiles : NSObject <NSCoding>

@property (nonatomic, strong) NSArray *routes;
@property (nonatomic, strong) NSString *nameEn;
@property (nonatomic, assign) double profilesIdentifier;
@property (nonatomic, assign) id iconData;
@property (nonatomic, strong) NSString *nameNl;
@property (nonatomic, strong) NSString *imageData;
@property (nonatomic, strong) NSString *descriptionNl;
@property (nonatomic, strong) NSString *descriptionEn;

+ (GHProfiles *)modelObjectWithDictionary:(NSDictionary *)dict;
- (id)initWithDictionary:(NSDictionary *)dict;
- (NSDictionary *)dictionaryRepresentation;

@end
