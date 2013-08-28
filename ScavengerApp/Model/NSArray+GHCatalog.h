//
//  NSArray+GHCatalog.h
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/26/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (GHCatalog)

- (NSArray*)GHprofiles;

- (void)saveToFileWithId:(int)cityID;
+ (NSArray*)loadFromFileWithId:(int)cityID;

@end

typedef NSArray GHCatalog;