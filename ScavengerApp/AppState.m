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


- (BOOL)save
{
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [docsPath stringByAppendingPathComponent: @"AppData"];
    NSMutableData *data = [NSMutableData data];
    NSKeyedArchiver *encoder = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];

    
//    NSCoder *encoder = [[NSCoder alloc] init];
    [encoder encodeObject:self.locations forKey:@"locations"];
    [encoder encodeObject:self.checkins forKey:@"checkins"];
    [encoder encodeObject:self.activeRoute forKey:@"activeRoute"];
    [encoder encodeObject:self.activeProfile forKey:@"activeProfile"];
    [encoder encodeInteger:self.activeTargetId forKey:@"activeTargetId"];
    [encoder encodeObject:self.activeTarget forKey:@"activeTarget"];
    [encoder encodeBool:[self playerIsInCompass] forKey:@"playerIsInCompass"];
    [encoder encodeObject:self.waypoints forKey:@"waypoints"];
    
    [encoder finishEncoding];

    
//    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString *filename = [docsPath stringByAppendingPathComponent:@"save"];
//    NSString *archivePath = filename;
//    NSMutableData *data = [NSMutableData data];
//    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
//    [archiver encodeObject:state forKey:@"appState"];
//    [archiver finishEncoding];
    
//    NSURL *archiveURL = [NSURL URLWithString:filePath];
    
    BOOL result = [data writeToFile:filePath atomically:YES];
    
    return result;
}


- (void)restore
{
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [docsPath stringByAppendingPathComponent: @"AppData"];
//    NSURL *archiveURL = [NSURL URLWithString:filePath];
    NSMutableData *data = [[NSMutableData alloc] initWithContentsOfFile:filePath]; // [NSData dataWithContentsOfFile:filePath];  //[NSData dataWithContentsOfURL:archiveURL];
    
    if (data){
    NSKeyedUnarchiver *decoder = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    self.locations = [decoder decodeObjectForKey:@"locations"];
    self.checkins = [decoder decodeObjectForKey:@"checkins"];
    self.activeRoute = [decoder decodeObjectForKey:@"activeRoute"];
    self.activeProfile = [decoder decodeObjectForKey:@"activeProfile"];
    self.activeTargetId = [decoder decodeIntegerForKey:@"activeTargetId"];
    self.activeTarget = [decoder decodeObjectForKey:@"activeTarget"];
    self.playerIsInCompass = [decoder decodeBoolForKey:@"playerIsInCompass"];
    self.waypoints = [decoder decodeObjectForKey:@"waypoints"];

    [decoder finishDecoding];
    }
    else
    {
        NSLog(@"Data for restoring is NULL");
    }
    
}


#pragma mark - NSCoding
//
//- (id)initWithCoder:(NSCoder *)decoder {
//    self = [super init];
//    if (!self) {
//        return nil;
//    }
//
//    self.locations = [decoder decodeObjectForKey:@"locations"];
//    self.checkins = [decoder decodeObjectForKey:@"checkins"];
//    self.activeRoute = [decoder decodeObjectForKey:@"activeRoute"];
//    self.activeProfile = [decoder decodeObjectForKey:@"activeProfile"];
//    self.activeTargetId = [decoder decodeIntegerForKey:@"activeTargetId"];
//    self.activeTarget = [decoder decodeObjectForKey:@"activeTarget"];
//    self.playerIsInCompass = [decoder decodeBoolForKey:@"playerIsInCompass"];
//    self.waypoints = [decoder decodeObjectForKey:@"waypoints"];
//    
//    return self;
//}
//
//- (void)encodeWithCoder:(NSCoder *)encoder {
//    [encoder encodeObject:self.title forKey:@"title"];
//    [encoder encodeObject:self.author forKey:@"author"];
//    [encoder encodeInteger:self.pageCount forKey:@"pageCount"];
//    [encoder encodeObject:self.categories forKey:@"categories"];
//    [encoder encodeBool:[self isAvailable] forKey:@"available"];
//}


@end
