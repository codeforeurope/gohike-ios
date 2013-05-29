//
//  AppState.m
//  ScavengerApp
//
//  Created by Taco van Dijk on 5/23/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "AppState.h"

@implementation AppState

+(AppState *)sharedInstance {
    static dispatch_once_t pred;
    static AppState *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[AppState alloc] init];
        //Data restore could be here, see http://stackoverflow.com/questions/1148853/loading-a-singletons-state-from-nskeyedarchiver
    });
    return shared;
}

#pragma mark - Game methods

- (NSString*)language
{
    NSString *locale = [[NSLocale preferredLanguages] objectAtIndex:0];
    if([locale isEqualToString:@"nl"]){
        return @"nl";
    }
    else{
        return @"en";
    }
}

- (void)checkIn
{
    Checkin *thisCheckIn = [[Checkin alloc] init];
    thisCheckIn.timestamp = [NSDate date];
    thisCheckIn.uploaded = NO;
    thisCheckIn.locationId = _activeTargetId;
    thisCheckIn.routeId = _activeRouteId;
    
    if(_checkins == nil){
        _checkins = [[NSMutableArray alloc] init];
    }
    
    [_checkins addObject:thisCheckIn];
#if DEBUG
    NSLog(@"Checkin added. Check-ins list: %@", _checkins);
#endif
    [self save];
    
}

- (BOOL)nextTarget
{
//    NSInteger nextTarget = _activeTargetId + 1;
    NSArray *waypoints = [self.activeRoute objectForKey:@"waypoints"];
    NSUInteger thisWPIndex = [waypoints indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [[obj objectForKey:@"location_id"] integerValue] == _activeTargetId;
    }];
    int thisWaypointRank = [[[waypoints objectAtIndex:thisWPIndex] objectForKey:@"rank"] integerValue];
    int nextTarget = thisWaypointRank + 1;
    
    NSDictionary *next;
    NSUInteger nextWPIndex = [waypoints indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [[obj objectForKey:@"rank"] integerValue] == nextTarget;
    }];
    if (nextWPIndex == NSNotFound) {
        return NO;
    }
    else{
        next = [waypoints objectAtIndex:nextWPIndex];
        _activeTargetId = [[next objectForKey:@"rank"] integerValue];
        [self save];
        return YES;
    }
    
}

- (NSDictionary*)activeProfile
{
    NSArray *profiles = [_game objectForKey:@"profiles"];
    NSUInteger index = [profiles indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [[obj objectForKey:@"id"] integerValue] == _activeProfileId;
    }];

    return [profiles objectAtIndex:index];
}

- (NSDictionary*)activeRoute
{
    NSArray *routes = [self.activeProfile objectForKey:@"routes"];
    NSUInteger index = [routes indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [[obj objectForKey:@"id"] integerValue] == _activeRouteId;
    }];

    return [routes objectAtIndex:index];
}

- (NSDictionary*)activeWaypoint
{
    NSArray *waypoints = [self.activeRoute objectForKey:@"waypoints"];
    NSUInteger index = [waypoints indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [[obj objectForKey:@"location_id"] integerValue] == _activeTargetId;
    }];
    if (index == NSNotFound) {
        return nil;
    }
    else {
        return  [waypoints objectAtIndex:index];
    }
}

- (NSArray*)checkinsForRoute:(int)routeId
{
    NSIndexSet *indexes = [_checkins indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return ((Checkin*)obj).routeId == routeId ;
    }];
    return [_checkins objectsAtIndexes:indexes];
}

- (NSDictionary*)routeWithId:(int)routeId
{
    NSArray *routes = [self.activeProfile objectForKey:@"routes"];
    NSUInteger index = [routes indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [[obj objectForKey:@"id"] integerValue] == routeId;
    }];
    
    return [routes objectAtIndex:index];
}

// Returns an array of waypoints for the route, adding a "visited" BOOL value for convenience
- (NSArray*)waypointsWithCheckinsForRoute:(int)routeId
{
    NSArray *waypoints = [[self routeWithId:routeId] objectForKey:@"waypoints"];
    NSArray *checkinsForRoute = [self checkinsForRoute:routeId] ;
    NSLog(@"checkinsforRoute %@", checkinsForRoute);
    NSMutableArray *waypointsWithVisit = [[NSMutableArray alloc] init];
    
    [waypoints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

        NSMutableDictionary *wp = [[NSMutableDictionary alloc] initWithDictionary:obj];
        if (checkinsForRoute) {
            NSUInteger isCheckedIn = [checkinsForRoute indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
                NSLog(@" ((Checkin*)obj).locationId  %d",  ((Checkin*)obj).locationId );
                return [[wp objectForKey:@"location_id"] integerValue]  == ((Checkin*)obj).locationId ;
            }];
            NSLog(@"ischeckedin %d", isCheckedIn);
            NSLog(@"NSNotFound %d", NSNotFound);
            if(isCheckedIn != NSNotFound){
                [wp setObject:[NSNumber numberWithBool:YES] forKey:@"visited"];
            }
            else{
                [wp setObject:[NSNumber numberWithBool:NO] forKey:@"visited"];
            }
        }
        else{
            [wp setObject:[NSNumber numberWithBool:NO] forKey:@"visited"];
        }
        [waypointsWithVisit addObject:wp];
        
    }];
    
    // order by rank to be sure
     waypointsWithVisit = [NSMutableArray arrayWithArray: [waypointsWithVisit sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber *id1 = [NSNumber numberWithDouble: [[obj1 valueForKey:@"rank"] intValue]];
        NSNumber *id2 = [NSNumber numberWithDouble: [[obj2 valueForKey:@"rank"] intValue]];
        return [id1 compare:id2];
    }]];
    
//    NSLog(@"waypoints with visited %@", waypointsWithVisit);
    
    return waypointsWithVisit;
}


#pragma mark - Save and restore

- (BOOL)save
{
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [docsPath stringByAppendingPathComponent: @"AppData"];
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    [encoder encodeObject:_checkins forKey:@"checkins"];
    [encoder encodeInt:_activeProfileId forKey:@"activeProfileId"];
    [encoder encodeInt:_activeRouteId forKey:@"activeRouteId"];
    [encoder encodeInteger:_activeTargetId forKey:@"activeTargetId"];
    [encoder encodeBool:_playerIsInCompass forKey:@"playerIsInCompass"];
    //    [encoder encodeObject:_game forKey:@"game"]; //We already have the game content stored in content.json

    [encoder finishEncoding];
    
    BOOL result = [data writeToFile:filePath atomically:YES];
    
    return result;
}


- (void)restore
{
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [docsPath stringByAppendingPathComponent: @"AppData"];
    NSMutableData *data = [[NSMutableData alloc] initWithContentsOfFile:filePath];
    
    if (data){
        NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        _checkins = [decoder decodeObjectForKey:@"checkins"];
        _activeProfileId = [decoder decodeIntegerForKey:@"activeProfileId"];
        _activeRouteId = [decoder decodeIntegerForKey:@"activeRouteId"];
        _activeTargetId = [decoder decodeIntegerForKey:@"activeTargetId"];
        _playerIsInCompass = [decoder decodeBoolForKey:@"playerIsInCompass"];
        //    _game = [decoder decodeObjectForKey:@"game"]; //We already have the game content stored in content.json
        
        [decoder finishDecoding];
    }
    else
    {
        NSLog(@"Data for restoring is NULL");
    }
    
}

@end
