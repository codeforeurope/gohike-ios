//
//  NSArray+GHCatalog.m
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/26/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "NSArray+GHCatalog.h"

@implementation NSArray (GHCatalog)

- (void)saveToFileWithId:(int)cityID
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //Save it to library
        NSString* libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *filePath = [libraryPath stringByAppendingPathComponent: [NSString stringWithFormat:@"catalog_%d",cityID]];
        BOOL success = [self writeToFile:filePath atomically:YES];
        if(!success)
            NSLog(@"Writing to file Failed");
    });
}

- (NSArray*)GHprofiles
{
    return self;
}

@end
