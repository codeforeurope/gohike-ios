//
//  GoHikeHTTPClient.m
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/25/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "GoHikeHTTPClient.h"
#import "AFJSONRequestOperation.h"

#define BASE_URL @"http://www.gotakeahike.nl"

NSString* const kFinishedLoadingCatalog = @"kFinishedLoadingCatalog";
NSString* const kFinishedLoadingRoute = @"kFinishedLoadingRoute";
NSString* const kFinishedLoadingCities = @"kFinishedLoadingCities";

@implementation GoHikeHTTPClient

+ (id)sharedClient {
    static GoHikeHTTPClient *__instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseUrl = [NSURL URLWithString:BASE_URL];
        __instance = [[GoHikeHTTPClient alloc] initWithBaseURL:baseUrl];
    });
    return __instance;
}

- (id)initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];

    }
    return self;
}



- (void)locate
{
    
    if(self.networkReachabilityStatus == AFNetworkReachabilityStatusNotReachable)
    {
        NSDictionary *userInfo = @{@"error" : NSLocalizedString(@"Unreachable", @"Unreachable")};
        NSNotification *notification = [NSNotification notificationWithName:kFinishedLoadingCatalog object:self userInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        return;
    }
    
    NSNumber *latitude = [NSNumber numberWithDouble: [[AppState sharedInstance] currentLocation].coordinate.latitude];
    NSNumber *longitude = [NSNumber numberWithDouble: [[AppState sharedInstance] currentLocation].coordinate.longitude];
    //    NSDictionary *requestBody = @{@"latitude": @52.3702157, @"longitude":@4.8951679 };

    NSDictionary *requestBody = @{@"latitude": latitude,
                                  @"longitude": longitude};
    __autoreleasing NSError *error;
    NSMutableURLRequest *locationRequest = [self requestWithMethod:@"POST" path:@"/api/locate" parameters:nil];
    [locationRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [locationRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:requestBody options:0 error:&error]];
    
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:locationRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        
        NSLog(@"JSON: %@", JSON);
        
        if([NSJSONSerialization isValidJSONObject:JSON]){
            [AppState sharedInstance].cities = [GHCities modelObjectWithDictionary:(NSDictionary*)JSON];
            [[AppState sharedInstance] save];
            
            NSNotification *resultNotification = [NSNotification notificationWithName:kFinishedLoadingCities object:self userInfo:nil];
            
            [[NSNotificationCenter defaultCenter] postNotification:resultNotification];
            
        }
        else{
            
            NSLog(@"JSON data not valid");
            NSDictionary *userInfo = @{@"error": NSLocalizedString(@"Invalid JSON data", @"Invalid JSON data")};
            NSNotification *notification = [NSNotification notificationWithName:kFinishedLoadingCities object:self userInfo:userInfo];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Error when retrieving cities: %@", [error description]);
        NSDictionary *userInfo = @{@"error":error};
        NSNotification *notification = [NSNotification notificationWithName:kFinishedLoadingCities object:self userInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
    
    }];
    [self enqueueHTTPRequestOperation:op];
}


- (void)getCatalogForCity:(int)cityID
{
    NSString *locale = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    NSString *path = [NSString stringWithFormat:@"/api/%@/catalog/%d", locale, cityID];
    NSMutableURLRequest *catalogRequest = [self requestWithMethod:@"GET" path:path parameters:nil];
    [catalogRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:catalogRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if([NSJSONSerialization isValidJSONObject:JSON]){ 
            
            [[AppState sharedInstance] setCurrentCatalog:(GHCatalog*)JSON];
            [[AppState sharedInstance] save];
            
            
            //Save it to library
            NSString* libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *filePath = [libraryPath stringByAppendingPathComponent: [NSString stringWithFormat:@"catalog_%d",cityID]];
            BOOL success = [((NSDictionary*)JSON) writeToFile:filePath atomically:YES];
            if(!success)
                NSLog(@"Writing to file Failed");
            
            NSDictionary *userInfo = [[NSDictionary alloc] init]; //  @{@"catalog":catalog};
            NSNotification *resultNotification = [NSNotification notificationWithName:kFinishedLoadingCatalog object:self userInfo:userInfo];
            [[NSNotificationCenter defaultCenter] postNotification:resultNotification];
            
        }
        else{
            NSLog(@"JSON data not valid");
            NSDictionary *userInfo = @{@"error" : NSLocalizedString(@"JSON data not valid", @"JSON data not valid")};
            NSNotification *notification = [NSNotification notificationWithName:kFinishedLoadingCatalog object:self userInfo:userInfo];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Error when retrieving catalog: %@", [error description]);
        
        NSDictionary *userInfo = @{@"error" : NSLocalizedString(@"JSON data not valid", @"JSON data not valid")};
        NSNotification *notification = [NSNotification notificationWithName:kFinishedLoadingCatalog object:self userInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        
    }];
    [self enqueueHTTPRequestOperation:op];
    
}


- (void)downloadRoute:(NSInteger)routeId
{
    NSString *path = [NSString stringWithFormat:@"/api/route/%d", routeId];
    NSMutableURLRequest *routeRequest = [self requestWithMethod:@"GET" path:path parameters:nil];
    [routeRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:routeRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"JSON: %@", JSON);
        if([NSJSONSerialization isValidJSONObject:JSON]){
            
            NSDictionary *route = (NSDictionary*)JSON;
            
            [[AppState sharedInstance] setCurrentRoute:route];
            
            //Save it to library
            NSString* libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            NSString *filePath = [libraryPath stringByAppendingPathComponent: [NSString stringWithFormat:@"route_%d",routeId]];
            BOOL success = [((NSDictionary*)JSON) writeToFile:filePath atomically:YES];
            if(!success)
                NSLog(@"Writing to file Failed");
            
            
            NSDictionary *userInfo =  @{@"route" : route};
            NSNotification *resultNotification = [NSNotification notificationWithName:kFinishedLoadingRoute object:self userInfo:userInfo];
            
            [[NSNotificationCenter defaultCenter] postNotification:resultNotification];
            
        }
        else{
            NSLog(@"JSON data not valid");
            NSDictionary *userInfo = @{@"error": NSLocalizedString(@"Invalid JSON data", @"Invalid JSON data")};
            NSNotification *notification = [NSNotification notificationWithName:kFinishedLoadingRoute object:self userInfo:userInfo];
            [[NSNotificationCenter defaultCenter] postNotification:notification];
            
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Error when retrieving route: %@", [error description]);
        NSDictionary *userInfo = @{@"error":error};
        NSNotification *notification = [NSNotification notificationWithName:kFinishedLoadingRoute object:self userInfo:userInfo];
        [[NSNotificationCenter defaultCenter] postNotification:notification];
        
    }];
    [self enqueueHTTPRequestOperation:op];
}




@end
