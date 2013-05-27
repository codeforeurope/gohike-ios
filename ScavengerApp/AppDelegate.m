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

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    NSString * language = [[AppState sharedInstance] language];
    NSLog(@"The app was started with the language: %@", language);
    

    
    //Load Game Data
    __autoreleasing NSError* error = nil;
    GHGameData *gameData;

    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"content" ofType:@"json"];
    NSData* data = [NSData dataWithContentsOfFile:bundlePath];
//    NSString *gameDataChecksum = [data MD5];
    
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

    
    //Restore game state
    [[AppState sharedInstance] restore];
    NSLog(@"Restored the active Profile: %d", [[AppState sharedInstance] activeProfileId]);
    NSLog(@"Stored checkins: %@", [[AppState sharedInstance] checkins]);
    if ([[AppState sharedInstance] playerIsInCompass]) {
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
        SelectionViewController *selectCharacterVC = [[SelectionViewController alloc] initWithNibName:@"SelectionViewController" bundle:nil];
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:selectCharacterVC];
    }

    
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
    
    // We already save everywhere in the app, so I am not using this
}

@end
