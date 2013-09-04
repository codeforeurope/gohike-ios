//
//  Utilities.h
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/27/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Utilities : NSObject

//Utility
+ (NSString*)getTranslatedStringForKey:(NSString*)key fromDictionary:(NSDictionary*)dictionary;
+ (NSString*)getStringForCurrentLocaleFromDictionary:(NSDictionary*)dictionary;
+ (NSString *)createNewUUID;
+ (NSString*)getCurrentLocale;
+ (NSString*)formattedStringFromDate:(NSDate*)date;
+ (NSNumber*)formattedNumberFromDate:(NSDate*)date;

@end
