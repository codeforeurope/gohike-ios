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

//@property (nonatomic, strong)

@property (nonatomic, strong) NSArray *locations;
@property (nonatomic, strong) NSMutableArray *checkins;
@property (nonatomic, strong) Route *activeRoute;
@property (nonatomic, strong) Profiles *activeProfile;
@property (nonatomic, assign) int activeTargetId;
@property (nonatomic, assign) Location *activeTarget;

+(AppState *)sharedInstance;
- (void)checkIn;
- (void)save;
- (void)nextTarget;



@end



//in compass controller

//appdelegate.appstate.activeRoute
//appdelegate.appstate.activeTargetLocation

//check in the current target location

// appdelegate.appstate.activeRoute.activeLocation setMarked:YES
//or
// appdelegate.appstate.progress.add new Progress(appstate.activeRoute.activeLocation)
//

