//
//  FileUtilities.m
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/29/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "FileUtilities.h"

@implementation FileUtilities

#pragma mark - Catalog

+(BOOL)saveCatalog:(GHCatalog*)catalog WithId:(int)cityId
{
    __block BOOL success = NO;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int catalogId = cityId;
        
        //Save it to library
        
        __autoreleasing NSError *error;
        NSFileManager *manager = [NSFileManager defaultManager];
        NSString* libraryPath = [FileUtilities getLibraryPath];
        NSString *catalogPath = [libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%d", kFilePathCatalogs, catalogId]];
        success = [manager createDirectoryAtPath:catalogPath withIntermediateDirectories:YES attributes:Nil error:&error];
        NSString *filePath = [catalogPath stringByAppendingPathComponent:@"catalog.plist"];
        success = [catalog writeToFile:filePath atomically:YES];
        if(!success)
            NSLog(@"Writing Catalog to file Failed");
        for (GHProfile *profile in [catalog GHprofiles]) {
            [FileUtilities saveProfile:profile];
        }
        
//    });
    return success;
}

+ (GHCatalog*)loadCatalogFromFileWithId:(int)cityID
{
    int catalogId = cityID;
    NSString* libraryPath = [FileUtilities getLibraryPath];
    NSString *catalogPath = [libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%d", kFilePathCatalogs, catalogId]];
    NSString *filePath = [catalogPath stringByAppendingPathComponent:@"catalog.plist"];
    return [NSArray arrayWithContentsOfFile:filePath];
}

#pragma mark - Profile

+(NSData*)imageDataForProfile:(GHProfile*)profile
{
    NSString* libraryPath = [FileUtilities getLibraryPath];
    NSString *routePath = [libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%d", kFilePathProfiles, [profile GHid]]];
    NSString *filePath = [routePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [[profile image] GHmd5]]];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    return data;
}

+ (BOOL)saveProfile:(GHRoute*)profile
{
    //no need to save the dictionary, only the pictures and (recursively) the routes
    int saveId = [profile GHid];
    
    __autoreleasing NSError *error;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString* libraryPath = [FileUtilities getLibraryPath];
    NSString *savePath = [libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%d", kFilePathProfiles, saveId]];
    BOOL success = [manager createDirectoryAtPath:savePath withIntermediateDirectories:YES attributes:Nil error:&error];
    if(!success)
        NSLog(@"Writing Profile to file Failed");
    
    NSString *imageFile = [NSString stringWithFormat:@"%@.png",[[profile GHimage] GHmd5]];
    NSString *imagePath = [savePath stringByAppendingPathComponent:imageFile];
    [[GoHikeHTTPClient sharedClient] downloadFileWithUrl:[[profile GHimage] GHurl] savePath:imagePath];
    
    for (GHRoute *route in [profile GHroutes]) {
        [FileUtilities saveRoute:route];
    }
    return success;
}

#pragma mark - Route

+(NSData*)imageDataForRoute:(GHRoute*)route
{
    NSString* libraryPath = [FileUtilities getLibraryPath];
    NSString *routePath = [libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%d", kFilePathRoutes, [route GHid]]];
    NSString *filePath = [routePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [[route GHimage] GHmd5]]];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    return data;
}

+(NSData*)iconDataForRoute:(GHRoute*)route
{
    NSString* libraryPath = [FileUtilities getLibraryPath];
    NSString *routePath = [libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%d", kFilePathRoutes, [route GHid]]];
    NSString *filePath = [routePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [[route GHicon] GHmd5]]];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    return data;
}

+ (BOOL)saveRoute:(GHRoute*)route
{
    BOOL success = NO;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int fileID = [route GHid];
        
        __autoreleasing NSError *error;
        NSFileManager *manager = [NSFileManager defaultManager];
        NSString* libraryPath = [FileUtilities getLibraryPath];
        NSString *savePath = [libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%d", kFilePathRoutes, fileID]];
        success = [manager createDirectoryAtPath:savePath withIntermediateDirectories:YES attributes:Nil error:&error];
        NSString *filePath = [savePath stringByAppendingPathComponent:@"route.plist"];
        success = [route writeToFile:filePath atomically:YES];
        if(!success)
            NSLog(@"Writing Route to file Failed");
        
        //write the icon file and image
        NSString *iconFile = [NSString stringWithFormat:@"%@.png",[[route GHicon] GHmd5]];
        NSString *iconPath = [savePath stringByAppendingPathComponent:iconFile];
        [[GoHikeHTTPClient sharedClient] downloadFileWithUrl:[[route GHicon] GHurl] savePath:iconPath];
        
        NSString *imageFile = [NSString stringWithFormat:@"%@.png",[[route GHimage] GHmd5]];
        NSString *imagePath = [savePath stringByAppendingPathComponent:imageFile];
        [[GoHikeHTTPClient sharedClient] downloadFileWithUrl:[[route GHimage] GHurl] savePath:imagePath];
        
        
        for (GHWaypoint *waypoint in [route GHwaypoints]) {
            [FileUtilities saveWaypoint:waypoint];
        }
        
        [FileUtilities saveReward:[route GHreward]];
        
//    });
    
    return success;
}

+ (GHRoute*)loadRouteFromFileWithId:(int)routeId
{
    NSString* libraryPath = [FileUtilities getLibraryPath];
    NSString *savePath = [libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%d", kFilePathRoutes, routeId]];
    NSString *filePath = [savePath stringByAppendingPathComponent:@"route.plist"];
    return [NSDictionary dictionaryWithContentsOfFile:filePath];
}

#pragma mark - Waypoints
+(NSData*)imageDataForWaypoint:(GHWaypoint*)waypoint
{
    NSString* libraryPath = [FileUtilities getLibraryPath];
    NSString *routePath = [libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%d", kFilePathRoutes, [waypoint GHroute_id]]];
    NSString *filePath = [routePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [[waypoint GHimage] GHmd5]]];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    return data;
}

+ (BOOL)saveWaypoint:(GHWaypoint*)waypoint
{
    //no need to save the dictionary, only the pictures and (recursively) the routes
    int saveId = [waypoint GHroute_id];
    
    __autoreleasing NSError *error;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString* libraryPath = [FileUtilities getLibraryPath];
    NSString *savePath = [libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%d", kFilePathRoutes, saveId]];
    BOOL success = [manager createDirectoryAtPath:savePath withIntermediateDirectories:YES attributes:Nil error:&error];
    if(!success)
        NSLog(@"Writing Waypoint to file Failed");
    
    NSString *imageFile = [NSString stringWithFormat:@"%@.png",[[waypoint GHimage] GHmd5]];
    NSString *imagePath = [savePath stringByAppendingPathComponent:imageFile];
    [[GoHikeHTTPClient sharedClient] downloadFileWithUrl:[[waypoint GHimage] GHurl] savePath:imagePath];
    
    return success;
}

#pragma mark - Rewards

+(NSData*)imageDataForReward:(GHReward*)reward
{
    NSString* libraryPath = [FileUtilities getLibraryPath];
    NSString *rewardPath = [libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%d", kFilePathRoutes, [reward GHroute_id]]];
    NSString *filePath = [rewardPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", [[reward GHimage] GHmd5]]];
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    return data;
}

+ (BOOL)saveReward:(GHReward*)reward
{
    //no need to save the dictionary, only the pictures and (recursively) the routes
    int saveId = [reward GHroute_id];
    
    __autoreleasing NSError *error;
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString* libraryPath = [FileUtilities getLibraryPath];
    NSString *savePath = [libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%d", kFilePathRoutes, saveId]];
    BOOL success = [manager createDirectoryAtPath:savePath withIntermediateDirectories:YES attributes:Nil error:&error];
    if(!success)
        NSLog(@"Writing Reward to file Failed");
    
    NSString *imageFile = [NSString stringWithFormat:@"%@.png",[[reward GHimage] GHmd5]];
    NSString *imagePath = [savePath stringByAppendingPathComponent:imageFile];
    [[GoHikeHTTPClient sharedClient] downloadFileWithUrl:[[reward GHimage] GHurl] savePath:imagePath];
    
    return success;
}

#pragma mark - 

+ (NSString*)getLibraryPath
{
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}



+ (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
        __autoreleasing NSError *deleteError;
        [[NSFileManager defaultManager] removeItemAtURL:URL error:&deleteError];
    }
    return success;
}

@end
