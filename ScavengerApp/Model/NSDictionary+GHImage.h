//
//  NSDictionary+GHImage.h
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/27/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (GHImage)

- (NSString*)url;
- (NSString*)md5;

@end

typedef NSDictionary GHImage;