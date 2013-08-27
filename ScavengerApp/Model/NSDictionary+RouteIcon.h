//
//  NSDictionary+RouteIcon.h
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/26/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (GHRouteIcon)

- (NSString*)url;
- (NSString*)md5;

@end

typedef NSDictionary GHRouteIcon;