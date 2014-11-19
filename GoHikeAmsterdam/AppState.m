//
//  AppState.m
//  ScavengerApp
//
//  Created by Taco van Dijk on 5/23/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "AppState.h"
#import "AppDelegate.h"
#import "AFNetworking.h"


NSString* const kLocationServicesFailure = @"kLocationServicesFailure";
NSString* const kLocationServicesForbidden = @"kLocationServicesForbidden";
NSString* const kLocationServicesGotBestAccuracyLocation = @"kLocationServicesGotBestAccuracyLocation";
NSString* const kLocationServicesUpdateHeading =  @"kLocationServicesUpdateHeading";
NSString* const kLocationServicesEnteredDestinationRegion =  @"kLocationServicesEnteredDestinationRegion";

NSString* const kFilePathCatalogs = @"catalogs";
NSString* const kFilePathRoutes = @"routes";
NSString* const kFilePathProfiles = @"profiles";

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
    [self save];
    
    [[GoHikeHTTPClient sharedClient] pushCheckins]; //try to push check-ins if we have internet connection
}

- (BOOL)setNextTarget
{
    GHWaypoint *nextTarget = [self nextCheckinForRoute:self.activeRouteId startingFromWaypointRank:[[self activeWaypoint] GHrank]];
    if(nextTarget)
    {
        _activeTargetId = [nextTarget GHlocation_id];
        [self save];
        return YES; 
    }
    return NO;
}
 
- (GHWaypoint*)activeWaypoint
{
    NSArray *waypoints = [self.currentRoute GHwaypoints];
    if ([waypoints count] < 1) {
        return nil;
    }
    
    NSUInteger index = [waypoints indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj GHlocation_id] == _activeTargetId;
    }];
    if (index == NSNotFound) {
        return nil;
    }
    else {
        return  [waypoints objectAtIndex:index];
    }
}

- (GHWaypoint*)nextCheckinForRoute:(int)routeId startingFromWaypointRank:(int)rank
{
    NSArray *waypoints = [self waypointsWithCheckinsForRoute:routeId];
    
    if([waypoints count] <1){
        return [[GHWaypoint alloc] init]; //should return nil
    }
    
    NSUInteger firstUncheckedIndex = [waypoints indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return ([[obj objectForKey:@"visited"] boolValue] == NO && [obj GHrank] >= rank);
    }];
    
    if (firstUncheckedIndex != NSNotFound) {
        return  [waypoints objectAtIndex:firstUncheckedIndex];
    }
    else if(rank > 0){
        return [self nextCheckinForRoute:routeId startingFromWaypointRank:0];
    }
    else{
    return nil;
    }
}

- (NSArray*)checkinsForRoute:(int)routeId
{
    NSIndexSet *indexes = [_checkins indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return ((Checkin*)obj).routeId == routeId ;
    }];
    return [_checkins objectsAtIndexes:indexes];
}


// Returns an array of waypoints for the route, adding a "visited" BOOL value for convenience
- (NSArray*)waypointsWithCheckinsForRoute:(int)routeId
{
    NSArray *waypoints = [[self currentRoute] GHwaypoints];
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

- (BOOL)isRouteFinished:(GHRoute*)route
{
    NSArray *waypoints = [[self currentRoute] GHwaypoints];
    if([waypoints count] < 1 )
        return NO;
    
    NSArray *checkinsForRoute = [self checkinsForRoute:[route GHid]];
    if ([waypoints count] <= [checkinsForRoute count]){
        return YES;
    }
    else
        return NO;
}

#pragma mark - Save and restore

- (BOOL)save
{
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [docsPath stringByAppendingPathComponent: @"AppData"];
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    
    [encoder encodeObject:_checkins forKey:@"checkins"];
    [encoder encodeInt:_activeRouteId forKey:@"activeRouteId"];
    [encoder encodeInteger:_activeTargetId forKey:@"activeTargetId"];
    [encoder encodeBool:_playerIsInCompass forKey:@"playerIsInCompass"];
    [encoder encodeObject:_cities forKey:@"cities"];
    [encoder encodeObject:_currentCity forKey:@"currentCity"];
    
    
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
        _activeRouteId = [decoder decodeIntegerForKey:@"activeRouteId"];
        _activeTargetId = [decoder decodeIntegerForKey:@"activeTargetId"];
        _playerIsInCompass = [decoder decodeBoolForKey:@"playerIsInCompass"];
        _cities = [decoder decodeObjectForKey:@"cities"];
        _currentCity = [decoder decodeObjectForKey:@"currentCity"];
        _currentCatalog = [FileUtilities loadCatalogFromFileWithId:_currentCity.GHid];
        _currentRoute = [FileUtilities loadRouteFromFileWithId:_activeRouteId];
        
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
        [[NSNotificationCenter defaultCenter] postNotificationName:kLocationServicesForbidden object:nil];
        return;
    }
    
    if (nil == _locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
    }
    
    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    _locationManager.distanceFilter = 40;
    
    [_locationManager startUpdatingLocation];
    [_locationManager startUpdatingHeading];
}

- (void)startLocationServicesLowPrecision
{
    if (![CLLocationManager locationServicesEnabled]) {
        NSLog(@"location services are disabled");
        [[NSNotificationCenter defaultCenter] postNotificationName:kLocationServicesForbidden object:nil];
        return;
    }
    
    _locationManager = [[CLLocationManager alloc] init];

    _locationManager.delegate = self;
    _locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    
    [_locationManager startUpdatingLocation];
    [_locationManager startUpdatingHeading];
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
#if !TARGET_IPHONE_SIMULATOR
    if (abs(howRecent) < 15.0) {
        _currentLocation = currentLocation;
        [[NSNotificationCenter defaultCenter] postNotificationName:kLocationServicesGotBestAccuracyLocation object:nil];
    }
#else
    if (abs(howRecent) < 15.0) {
        _currentLocation = currentLocation;
        [[NSNotificationCenter defaultCenter] postNotificationName:kLocationServicesGotBestAccuracyLocation object:nil];
    }
#endif
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    if ([error domain] == kCLErrorDomain) {
        
        // We handle CoreLocation-related errors here
        switch ([error code]) {
                // "Don't Allow" on two successive app launches is the same as saying "never allow". The user
                // can reset this for all apps by going to Settings > General > Reset > Reset Location Warnings.
            case kCLErrorDenied:{
                [[NSNotificationCenter defaultCenter] postNotificationName:kLocationServicesForbidden object:nil];
            }
            case kCLErrorLocationUnknown:
            {
                NSDictionary *userInfo = @{ @"error" : error };
                [[NSNotificationCenter defaultCenter] postNotificationName:kLocationServicesFailure object:nil userInfo:userInfo];
            }
                
            default:
                break;
        }
    } else {
        // We handle all non-CoreLocation errors here
    }

}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    if (newHeading.headingAccuracy > 0) {
        float magneticHeading = newHeading.magneticHeading;
        float trueHeading = newHeading.trueHeading;
        
        //current heading in degrees and radians
        //use true heading if it is available
        float heading = (trueHeading > 0) ? trueHeading : magneticHeading;
        
        NSDictionary *userInfo = @{ @"heading" : [NSNumber numberWithFloat:heading] };
        [[NSNotificationCenter defaultCenter] postNotificationName:kLocationServicesUpdateHeading object:nil userInfo:userInfo];
        
    }
}

- (void)startMonitoringForDestination
{
   
    {
        if ([CLLocationManager significantLocationChangeMonitoringAvailable]) {
            // Stop normal location updates and start significant location change updates for battery efficiency.
            CLLocationCoordinate2D coordinates = CLLocationCoordinate2DMake([[self activeWaypoint] GHlatitude], [[self activeWaypoint] GHlongitude]);
            CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:coordinates radius:500.0 identifier:@"destinationLocation"];
            [_locationManager startMonitoringForRegion:region];
            [_locationManager startMonitoringSignificantLocationChanges];
#if DEBUG
            NSLog(@"Started monitoring for destination: %f %f", coordinates.latitude, coordinates.longitude);
#endif
        }
        else {
            NSLog(@"Significant location change monitoring is not available.");
        }
    }

}

- (void)stopMonitoringForDestination
{
    [[_locationManager monitoredRegions] enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        [_locationManager stopMonitoringForRegion:(CLRegion*)obj];
#if DEBUG
        NSLog(@"Stopped monitoring for region: %@", (CLRegion*)obj);
#endif
    }];
    
    [_locationManager stopMonitoringSignificantLocationChanges];    

}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
#if DEBUG
    NSLog(@"Did Enter Region! %@", [region identifier]);
#endif
    if([[region identifier] isEqualToString:@"destinationLocation"] && [UIApplication sharedApplication].applicationState != UIApplicationStateActive)
    {
        UILocalNotification *notification = [[UILocalNotification alloc] init];
//        notification.fireDate = [NSDate date];
//        NSTimeZone* timezone = [NSTimeZone defaultTimeZone];
//        notification.timeZone = timezone;
        notification.alertBody = NSLocalizedString(@"NotificationAlertBody", @"Local notification when user getting closer to location");
        notification.alertAction = NSLocalizedString(@"NotificationAlertActionRegion", @"Text shown next to the notification when entering REGION");
//        notification.soundName = UILocalNotificationDefaultSoundName;
//        [[UIApplication sharedApplication] scheduleLocalNotification:notification];
        [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
    }
    else if([[region identifier] isEqualToString:@"destinationLocation"] && [[AppState sharedInstance] playerIsInCompass] == YES){
        [[NSNotificationCenter defaultCenter] postNotificationName:kLocationServicesEnteredDestinationRegion object:nil];
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"Monitoring did fail for region: %@ Error %@",region, error);
}



@end
