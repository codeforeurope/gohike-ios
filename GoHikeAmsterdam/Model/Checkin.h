//
//  Checkin.h
//  ScavengerApp
//
//  Created by Taco van Dijk on 5/23/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Checkin : NSObject <NSCoding> 

@property (nonatomic, assign) NSInteger locationId;
@property (nonatomic, assign) NSInteger routeId;
@property (nonatomic, strong) NSDate *timestamp;
@property (nonatomic, assign) BOOL uploaded;

- (NSDictionary *)dictionaryRepresentation;

@end
