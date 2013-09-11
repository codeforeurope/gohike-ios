//
//  Utilities.m
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/27/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "Utilities.h"

@implementation Utilities

#pragma mark - Utilities

+ (NSString*)getTranslatedStringForKey:(NSString*)key fromDictionary:(NSDictionary*)dictionary
{
    if ([[dictionary objectForKey:key] isKindOfClass:[NSDictionary class]]){
        //it's a dictionary, so may contain more locales
        return [self getStringForCurrentLocaleFromDictionary:[dictionary objectForKey:key]];
    }
    else{
        //it's just a string, return the object
        return [dictionary objectForKey:key];
    }
}

+ (NSString*)getStringForCurrentLocaleFromDictionary:(NSDictionary*)dictionary
{
    NSString *labelText = nil;
    NSString *locale = [[NSLocale preferredLanguages] objectAtIndex:0];
    if([dictionary objectForKey:locale]){
        labelText = [dictionary objectForKey:locale];
    }
    else if([dictionary objectForKey:@"en"]){
        labelText = [dictionary objectForKey:@"en"];
    }
    else{
        labelText = [dictionary objectForKey:[[dictionary allKeys] objectAtIndex:0]];
    }
    //One last test to avoid return <null> values if they are by mistake stored in the API
    if(labelText == nil){
        labelText = @"";
    }
    return labelText;
}

+ (NSString *)createNewUUID {
    
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

+ (NSString*)getCurrentLocale
{
    return[[NSLocale preferredLanguages] objectAtIndex:0];
}

+ (NSString*)formattedStringFromDate:(NSDate*)date
{
    //Use the string for correct conversion to JSON
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd HH:mm:ss Z"];
    NSString *dateToString = [formatter stringFromDate:date];
    return dateToString;
}

+ (NSNumber*)formattedNumberFromDate:(NSDate*)date
{
    return [NSNumber numberWithInt:[date timeIntervalSince1970]];
}

+ (void)clearDownloadedData
{
    //TODO
    NSString *cacheDir = [FileUtilities getLibraryPath];
    
    // check if cache dir exists
    
    // get all files in this directory
    NSFileManager *fm = [NSFileManager defaultManager];
    NSArray *fileList = [fm contentsOfDirectoryAtPath: cacheDir error: nil];
    
    // remove
    for(NSInteger i = 0; i < [fileList count]; ++i)
    {
        NSString *fp =  [fileList objectAtIndex: i];
        NSString *remPath = [cacheDir stringByAppendingPathComponent: fp];
        [fm removeItemAtPath: remPath error: nil];
    }
}

+ (UIColor*)appColor
{
    //The "main color" for the app
    return [UIColor colorWithRed:0.386 green:0.720 blue:0.834 alpha:1.000];
}

@end
