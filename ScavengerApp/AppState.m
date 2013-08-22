//
//  AppState.m
//  ScavengerApp
//
//  Created by Taco van Dijk on 5/23/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "AppState.h"
#import "AppDelegate.h"

NSString* const kLocationServicesFailure = @"kLocationServicesFailure";
NSString* const kLocationServicesGotBestAccuracyLocation = @"kLocationServicesGotBestAccuracyLocation";
NSString* const kFinishedLoadingCatalog = @"kFinishedLoadingCatalog";

@implementation AppState

+(AppState *)sharedInstance {
    static dispatch_once_t pred;
    static AppState *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[AppState alloc] init];
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
    
    [(AppDelegate*)[[UIApplication sharedApplication] delegate] pushCheckins]; //try to push check-ins if we have internet connection
}

- (BOOL)setNextTarget
{
    NSDictionary *nextTarget = [self nextCheckinForRoute:self.activeRouteId];
    if(nextTarget)
    {
        _activeTargetId = [[nextTarget objectForKey:@"location_id"] integerValue];
        [self save];
        return YES; 
    }
    return NO;
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
    if (index == NSNotFound) {
        return nil;
    }
    else {
        return [routes objectAtIndex:index];
    }
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

- (NSDictionary*)nextCheckinForRoute:(int)routeId
{
    NSArray *waypoints = [self waypointsWithCheckinsForRoute:routeId];
    
    NSUInteger firstUncheckedIndex = [waypoints indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [[obj objectForKey:@"visited"] boolValue] == NO;
    }];
    
    if (firstUncheckedIndex != NSNotFound) {
        return  [waypoints objectAtIndex:firstUncheckedIndex];
    }
    return nil;
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

    NSMutableArray *waypointsWithVisit = [[NSMutableArray alloc] init];
    
    [waypoints enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

        NSMutableDictionary *wp = [[NSMutableDictionary alloc] initWithDictionary:obj];
        if (checkinsForRoute) {
            NSUInteger isCheckedIn = [checkinsForRoute indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {

                return [[wp objectForKey:@"location_id"] integerValue]  == ((Checkin*)obj).locationId ;
            }];

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
    [encoder encodeObject:_currentCity forKey:@"currentCity"];
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
        _currentCity = [decoder decodeObjectForKey:@"currentCity"];
        //    _game = [decoder decodeObjectForKey:@"game"]; //We already have the game content stored in content.json
        
        [decoder finishDecoding];
    }
    else
    {
        NSLog(@"Data for restoring is NULL");
    }
    
}

#pragma mark - Location Manager

- (void)startLocationServices
{
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"location services are disabled");
        [[NSNotificationCenter defaultCenter] postNotificationName:kLocationServicesFailure object:nil];
        return;
    }
    
    if (nil == _locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.distanceFilter = 100;
    
    [_locationManager startUpdatingLocation];
}

- (void)stopLocationServices
{
    [_locationManager stopUpdatingLocation];
}

-(void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *currentLocation = [locations lastObject];
    NSDate* eventDate = currentLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0 && currentLocation.horizontalAccuracy >= _locationManager.desiredAccuracy) {
        _currentLocation = currentLocation;
        [[NSNotificationCenter defaultCenter] postNotificationName:kLocationServicesGotBestAccuracyLocation object:nil];
        NSLog(@"_currentLocation: %@", currentLocation);
        
    }
}

@end
