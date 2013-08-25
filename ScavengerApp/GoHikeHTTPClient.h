//
//  GoHikeHTTPClient.h
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/25/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "AFHTTPClient.h"

extern NSString* const kFinishedLoadingCatalog;
extern NSString* const kFinishedLoadingRoute;
extern NSString* const kFinishedLoadingCities;

@interface GoHikeHTTPClient : AFHTTPClient

+ (id)sharedClient;

- (void)locate;
- (void)getCatalogForCity:(int)cityID;
- (void)downloadRoute:(NSInteger)routeId;


@end
