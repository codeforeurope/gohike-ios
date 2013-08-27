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
    return labelText;
}

+ (NSString *)createNewUUID {
    
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

@end
