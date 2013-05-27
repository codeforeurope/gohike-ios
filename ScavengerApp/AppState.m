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


- (void)checkIn
{
    Checkin *thisCheckIn = [[Checkin alloc] init];
    thisCheckIn.timestamp = [NSDate date];
    thisCheckIn.uploaded = NO;
    thisCheckIn.locationId = _activeTargetId;
    thisCheckIn.routeId = _activeRouteId;
    
    [self.checkins addObject:thisCheckIn];
    [self save];
    
}

- (BOOL)nextTarget
{
    NSInteger nextTarget = _activeTargetId + 1;
    NSArray *waypoints = [self.activeRoute objectForKey:@"waypoints"];
    NSDictionary *next;
    NSInteger nextWPIndex = [waypoints indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [[obj objectForKey:@"rank"] integerValue] == nextTarget;
    }];
    if (index < 0) {
        return NO;
        //TODO: mark end of route
    }
    else{
        next = [waypoints objectAtIndex:nextWPIndex];
        _activeTargetId = [[next objectForKey:@"rank"] integerValue];
        [self save];
        return YES;
    }
    
}


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
        return [[obj objectForKey:@"rank"] integerValue] == _activeTargetId;
    }];
    if (index > 0) {
        return  [waypoints objectAtIndex:index];
    }
    else {
        return nil;
    }
}




@end
