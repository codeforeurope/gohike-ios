//
//  FileUtilities.h
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/29/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileUtilities : NSObject

//Catalog
+ (BOOL)saveCatalog:(GHCatalog*)catalog WithId:(int)cityId;
+ (GHCatalog*)loadCatalogFromFileWithId:(int)cityID;
+ (NSArray*)picturesInCatalog:(GHCatalog*)catalog;

//Profile
+ (NSData*)imageDataForProfile:(GHProfile*)profile;
+ (BOOL)saveProfile:(GHRoute*)profile;
+ (NSArray*)pictureInProfile:(GHProfile*)profile;

//Route
+ (NSData*)imageDataForRoute:(GHRoute*)route;
+ (NSData*)iconDataForRoute:(GHRoute*)route;
+ (BOOL)saveRoute:(GHRoute*)route;
+ (GHRoute*)loadRouteFromFileWithId:(int)routeId;
+ (NSArray*)picturesInRoute:(GHRoute*)route;

//Waypoint
+ (NSData*)imageDataForWaypoint:(GHWaypoint*)waypoint;
+ (BOOL)saveWaypoint:(GHWaypoint*)waypoint;
+ (NSArray*)pictureInWaypoint:(GHWaypoint*)waypoint;

//Reward
+(NSData*)imageDataForReward:(GHReward*)reward;
+ (BOOL)saveReward:(GHReward*)reward;

//
+ (NSString*)getLibraryPath;
+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL; //for not backing up to iCloud


@end
