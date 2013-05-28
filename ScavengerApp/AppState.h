//
//  AppState.h
//  ScavengerApp
//
//  Created by Taco van Dijk on 5/23/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataModels.h"

@interface AppState : NSObject

@property (nonatomic, strong) NSMutableArray *checkins; //Array of check-ins along current route
@property (nonatomic, assign) int activeProfileId; //ID of the active profile
@property (nonatomic, assign) int activeRouteId; //ID of the active route
@property (nonatomic, assign) int activeTargetId;   //ID of the active Target where we are navigating to
@property (nonatomic, assign) BOOL playerIsInCompass; //Is the player in compass mode? If so, when restoring, go there immediately
@property (nonatomic, strong) NSDictionary *game; //Dictionary from GHGameData
@property (nonatomic, strong) NSString *secret; //For contacting the API


+(AppState *)sharedInstance;
- (void)checkIn;
- (BOOL)save;
- (void)restore;
- (BOOL)nextTarget;
- (NSString*)language;

- (NSDictionary*)activeProfile;
- (NSDictionary*)activeRoute;
- (NSDictionary*)activeWaypoint;

- (NSArray*)checkinsForRoute:(int)routeId;
- (NSDictionary*)routeWithId:(int)routeId;
- (NSArray*)waypointsWithCheckinsForRoute:(int)routeId;

@end



//in compass controller

//appdelegate.appstate.activeRoute
//appdelegate.appstate.activeTargetLocation

//check in the current target location

// appdelegate.appstate.activeRoute.activeLocation setMarked:YES
//or
// appdelegate.appstate.progress.add new Progress(appstate.activeRoute.activeLocation)
//

