//
//  AppDelegate.m
//  ScavengerApp
//
//  Created by Giovanni on 5/15/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "AppDelegate.h"

#import "SelectionViewController.h"

#import "NSData+MD5.h"

#import "RouteStartViewController.h"

#import "CompassViewController.h"

#import "AFNetworking.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    
    // load the secret
    __autoreleasing NSError* secretError = nil;
    NSString *secretPath = [[NSBundle mainBundle] pathForResource:@"secret" ofType:@""];
    [[AppState sharedInstance] setSecret:[NSString stringWithContentsOfFile:secretPath encoding:NSUTF8StringEncoding error:&secretError]];
    
    // Get device UDID
    NSString *deviceID = [[UIDevice currentDevice] uniqueIdentifier];  // <-- deprecated
    

    // Load Game Data
    __autoreleasing NSError* error = nil;
    GHGameData *gameData;

    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"content" ofType:@"json"];
    NSData* data = [NSData dataWithContentsOfFile:bundlePath];

    
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [docsPath stringByAppendingPathComponent: @"content.json"];
    NSMutableData *downloadedData = [[NSMutableData alloc] initWithContentsOfFile:filePath];
    if(downloadedData)
    {
        GHGameData *downloadedGameData = [GHGameData modelObjectWithDictionary:[NSJSONSerialization JSONObjectWithData:downloadedData options:0 error:&error]];
        [[AppState sharedInstance] setGame:[downloadedGameData dictionaryRepresentation]];
    }
    else{
        gameData = [GHGameData modelObjectWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:0 error:&error]];
        [[AppState sharedInstance] setGame:[gameData dictionaryRepresentation]];
    }

    
    // Restore game state
    [[AppState sharedInstance] restore];
    NSLog(@"Restored the active Profile: %d", [[AppState sharedInstance] activeProfileId]);
    NSLog(@"Stored checkins: %@", [[AppState sharedInstance] checkins]);
    if ([[AppState sharedInstance] playerIsInCompass] == YES) {
        
        // We were in compass view when we quit, we restore the navigation controller and reopen the compass view
        SelectionViewController *selectCharacterVC = [[SelectionViewController alloc] initWithNibName:@"SelectionViewController" bundle:nil];
        RouteStartViewController *rvc = [[RouteStartViewController alloc] initWithNibName:@"RouteStartViewController" bundle:nil];
        rvc.route = [[AppState sharedInstance] activeRoute];
        CompassViewController *cvc = [[CompassViewController alloc] init];
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:selectCharacterVC];
        [self.navigationController pushViewController:rvc animated:NO];
        [self.navigationController pushViewController:cvc animated:NO];
        
    }
    else{
        // We were not in compass view, so just load first screen
        SelectionViewController *selectCharacterVC = [[SelectionViewController alloc] initWithNibName:@"SelectionViewController" bundle:nil];
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:selectCharacterVC];
    }

    // Update
    
    NSURL *url = [NSURL URLWithString:@"http://gohike.herokuapp.com/api"];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSString *currentVersion = [[[AppState sharedInstance] game] objectForKey:@"version"];
    NSLog(@"current version %@", currentVersion);
    
    if ([httpClient networkReachabilityStatus] == AFNetworkReachabilityStatusReachableViaWiFi) {
        //We try to download new content only if we are on wifi
        NSMutableURLRequest *pingRequest = [httpClient requestWithMethod:@"POST" path:@"/ping" parameters:[NSDictionary dictionaryWithObjectsAndKeys:currentVersion, @"version", nil]];
        [pingRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:pingRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
            NSLog(@"Status: %@", [JSON objectForKey:@"status"]);
            if([[JSON objectForKey:@"status"] isEqualToString:@"update"])
            {
                NSMutableURLRequest *contentRequest = [httpClient requestWithMethod:@"GET" path:@"/content" parameters:nil];
            
                AFJSONRequestOperation *contentOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:contentRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                    NSLog(@"New game version %@", [JSON objectForKey:@"version"]);
                    NSLog(@"Saving new data to disk");
                    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                    NSString *filePath = [docsPath stringByAppendingPathComponent: @"content.json"];
                    __autoreleasing NSError* contentError = nil;
                   
                    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:JSON
                                                                       options:kNilOptions
                                                                         error:&contentError];
                    if([jsonData writeToFile:filePath atomically:YES])
                    {
                        NSLog(@"Updated ok");
                    }
                    
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                    NSLog(@"Download of new content failed");
                }];
                [contentOperation start];
            }
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
            NSLog(@"Update request failed with error: %@", [error description]);
        }];
        [operation start];
    }
    
    // Try to push checkins, if network is reachable

    if(httpClient.networkReachabilityStatus != AFNetworkReachabilityStatusNotReachable)
    {
        NSIndexSet *indexes = [[[AppState sharedInstance] checkins] indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return ((Checkin*)obj).uploaded == NO;
        }];
        NSArray *checkinsToPush = [[[AppState sharedInstance] checkins] objectsAtIndexes:indexes];
        if([checkinsToPush count] > 0)
        {
            NSMutableURLRequest *checkinRequest = [httpClient requestWithMethod:@"POST" path:@"/checkin" parameters:[NSDictionary dictionaryWithObjectsAndKeys:deviceID, @"identifier", checkinsToPush, @"checkins", nil]];
            [checkinRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [checkinRequest setValue:[[AppState sharedInstance] secret] forHTTPHeaderField:@"Take-A-Hike-Secret"];
            AFJSONRequestOperation *checkinOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:checkinRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                NSLog(@"Pushed checkins OK!");
                // Set checkin to uploaded
                [[[AppState sharedInstance] checkins] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    ((Checkin*)obj).uploaded = YES;
                }];
                
            } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                NSLog(@"Failed to update checkins: %@",[error description]);
            }];
            
            [httpClient enqueueHTTPRequestOperation:checkinOperation];
        }

    }
    //Start app
    
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    // We already save everywhere in the app, so not using this
}

//static NSString *serviceName = @"net.codeforeurope.gohike";
//[[NSBundle mainBundle] bundleIdentifier]

@end
