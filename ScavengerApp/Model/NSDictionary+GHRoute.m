//
//  NSDictionary+GHRoute.m
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/26/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "NSDictionary+GHRoute.h"

@implementation NSDictionary (GHRoute)

- (int)GHid
{
    return [[self objectForKey:@"id"] integerValue];
}

- (GHRouteIcon*)GHicon
{
    return [self objectForKey:@"icon"];
}

- (GHImage*)GHimage
{
    return [self objectForKey:@"image"];
}

- (NSString*)GHdescription
{
    return [Utilities getTranslatedStringForKey:@"description" fromDictionary:self];
}

- (NSString*)GHname
{
    return [Utilities getTranslatedStringForKey:@"name" fromDictionary:self];

}

- (NSArray*)GHwaypoints
{
    return [self objectForKey:@"waypoints"];
}

- (BOOL)saveToFile
{

    __block BOOL success = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int fileID = [self GHid];
    
        __autoreleasing NSError *error;
        NSFileManager *manager = [NSFileManager defaultManager];
        NSString* libraryPath = [Utilities getLibraryPath];
        NSString *savePath = [libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"route/%d", fileID]];
        BOOL success = [manager createDirectoryAtPath:savePath withIntermediateDirectories:YES attributes:Nil error:&error];
        NSString *filePath = [savePath stringByAppendingPathComponent:@"route.plist"];
        success = [self writeToFile:filePath atomically:YES];
        if(!success)
            NSLog(@"Writing to file Failed");
        
        //write the icon file and image
        NSString *iconFile = [NSString stringWithFormat:@"%@.png",[[self GHicon] GHmd5]];
        NSString *iconPath = [savePath stringByAppendingPathComponent:iconFile];
        [[GoHikeHTTPClient sharedClient] downloadFileWithUrl:[[self GHicon] GHurl] savePath:iconPath];
        
        NSString *imageFile = [NSString stringWithFormat:@"%@.png",[[self GHimage] GHmd5]];
        NSString *imagePath = [savePath stringByAppendingPathComponent:@"image.png"];
        [[GoHikeHTTPClient sharedClient] downloadFileWithUrl:[[self GHimage] GHurl] savePath:imagePath];
        
        
        for (GHWaypoint *waypoint in [self GHwaypoints]) {
            [waypoint saveToFile];
        }
        
    });

    return success;
}

@end
