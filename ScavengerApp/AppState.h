//
//  AppState.h
//  ScavengerApp
//
//  Created by Taco van Dijk on 5/23/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataModels.h"
#import <CoreLocation/CoreLocation.h>

extern NSString* const kLocationServicesFailure;
extern NSString* const kLocationServicesGotBestAccuracyLocation;
extern NSString* const kFinishedLoadingCatalog;
extern NSString* const kFinishedLoadingRoute;


@interface AppState : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) NSMutableArray *checkins; //Array of check-ins along current route
@property (nonatomic, assign) int activeProfileId; //ID of the active profile
@property (nonatomic, assign) int activeRouteId; //ID of the active route
@property (nonatomic, assign) int activeTargetId;   //ID of the active Target where we are navigating to
@property (nonatomic, assign) BOOL playerIsInCompass; //Is the player in compass mode? If so, when restoring, go there immediately
@property (nonatomic, strong) NSDictionary *game; //Dictionary from GHGameData
@property (nonatomic, strong) GHCatalog *currentCatalog; //Catalog of the game (with profiles, routes)
@property (nonatomic, strong) NSDictionary *currentRoute;
@property (nonatomic, strong) GHCity *currentCity; //City the player is currently in
@property (nonatomic, strong) NSDate *lastCatalogUpdate; //when was the catalog last updated

//Location
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;

+(AppState *)sharedInstance;
- (void)checkIn;
- (BOOL)save;
- (void)restore;
- (BOOL)setNextTarget;
- (NSString*)language;

- (NSDictionary*)activeWaypoint;

- (NSDictionary*)nextCheckinForRoute:(int)routeId;
- (NSArray*)checkinsForRoute:(int)routeId;
- (NSArray*)waypointsWithCheckinsForRoute:(int)routeId;

//Network
- (void)downloadRoute:(NSInteger)routeId;


//Location
- (void) startLocationServices;
- (void) stopLocationServices;

@end



//in compass controller

//appdelegate.appstate.activeRoute
//appdelegate.appstate.activeTargetLocation

//check in the current target location

// appdelegate.appstate.activeRoute.activeLocation setMarked:YES
//or
// appdelegate.appstate.progress.add new Progress(appstate.activeRoute.activeLocation)
//

