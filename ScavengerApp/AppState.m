//
//  AppState.m
//  ScavengerApp
//
//  Created by Taco van Dijk on 5/23/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "AppState.h"

@implementation AppState

//TODO: use the shared instance implementation
+(AppState *)sharedInstance {
    static dispatch_once_t pred;
    static AppState *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[AppState alloc] init];
    });
    return shared;
}


- (void)checkIn
{
    Checkin *thisCheckIn = [[Checkin alloc] init];
    thisCheckIn.timestamp = [NSDate date];
    thisCheckIn.uploaded = NO;
    thisCheckIn.locationId = self.activeTargetId;
    
    [self.checkins addObject:thisCheckIn];
    
}

- (void)nextTarget
{
    int index =  [self.locations indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return ((Location*)obj).locationId ==  self.activeTargetId+1;
    }];

    Location *next;
    if(index < 0){
    //TODO: mark end of route
    }
    else{
        next = [self.locations objectAtIndex:index];
        NSLog(@"Next: %@", next);
        self.activeTarget = next;

    }
}


- (void)save
{
    //todo
}

@end
