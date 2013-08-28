//
//  NSArray+GHCatalog.m
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/26/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "NSArray+GHCatalog.h"

@implementation NSArray (GHCatalog)

- (NSArray*)GHprofiles
{
    return self;
}

#pragma mark - Save and Load

- (void)saveToFileWithId:(int)cityID
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        int catalogId = cityID;
        
        //Save it to library
        
        __autoreleasing NSError *error;
        NSFileManager *manager = [NSFileManager defaultManager];
        NSString* libraryPath = [Utilities getLibraryPath];
        NSString *catalogPath = [libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"catalog/%d", catalogId]];
        BOOL success = [manager createDirectoryAtPath:catalogPath withIntermediateDirectories:YES attributes:Nil error:&error];
        NSString *filePath = [catalogPath stringByAppendingPathComponent:@"catalog.plist"];
        success = [self writeToFile:filePath atomically:YES];
        if(!success)
            NSLog(@"Writing to file Failed");
        for (GHProfile *profile in [self GHprofiles]) {
            [profile saveToFile];
        }
        
    });
}

+ (NSArray*)loadFromFileWithId:(int)cityID
{
    int catalogId = cityID;
    NSString* libraryPath = [Utilities getLibraryPath];
    NSString *catalogPath = [libraryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"catalog/%d", catalogId]];
    NSString *filePath = [catalogPath stringByAppendingPathComponent:@"catalog.plist"];
    return [NSArray arrayWithContentsOfFile:filePath];
//
//    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
//        return [NSArray arrayWithContentsOfFile:filePath];
//    else
//        return [[NSArray alloc] init];
}

@end
