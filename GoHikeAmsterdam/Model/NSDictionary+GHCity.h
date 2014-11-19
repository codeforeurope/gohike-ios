//
//  NSDictionary+GHCity.h
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/26/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (GHCity)

- (int)GHid;
- (NSString*)GHname;
- (NSString*)GHstate_province;
- (NSString*)GHcountry_code;

@end

typedef NSDictionary GHCity;
