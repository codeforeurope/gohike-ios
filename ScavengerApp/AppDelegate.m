//
//  AppDelegate.m
//  ScavengerApp
//
//  Created by Giovanni Maggini on 5/15/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "AppDelegate.h"
#import "RouteStartViewController.h"
#import "CompassViewController.h"
#import "AFNetworking.h"
#import "Secret.h"
#import "SSKeychain.h"
#import <AdSupport/AdSupport.h>
#import "CitySelectionViewController.h"
#import "CannotPlayViewController.h"
#import "CatalogViewController.h"
#import "SIAlertView.h"

@implementation AppDelegate

- (void)customizeAppearance
{
    // Create resizable images
    UIImage *topNavbarImage = [[UIImage imageNamed:@"navigation-top-background.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];

    // Set the background image for *all* UINavigationBars
    [[UINavigationBar appearance] setBackgroundImage:topNavbarImage
                                       forBarMetrics:UIBarMetricsDefault];
    
    // Customize the title text for *all* UINavigationBars
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
      UITextAttributeTextColor,
      //[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8],
      //UITextAttributeTextShadowColor,
      //[NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
      //UITextAttributeTextShadowOffset,
      [UIFont fontWithName:@"HelveticaNeue" size:18.0],
      UITextAttributeFont,
      nil]];
    
    UIImage *backButton = [[UIImage imageNamed:@"back.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 4)];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButton forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];


    //Set SIAlertView appearance
    UIColor *blueColor = [UIColor colorWithRed:0.386 green:0.720 blue:0.834 alpha:1.000];
    [[SIAlertView appearance] setMessageFont:[UIFont systemFontOfSize:14]];
    [[SIAlertView appearance] setTitleColor:blueColor];
    [[SIAlertView appearance] setMessageColor:blueColor];
    [[SIAlertView appearance] setCornerRadius:12];
    [[SIAlertView appearance] setShadowRadius:20];
    
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
#if DEBUG
    NSLog(@"Received local notification");
#endif
}


// FBSample logic
// If we have a valid session at the time of openURL call, we handle Facebook transitions
// by passing the url argument to handleOpenURL; see the "Just Login" sample application for
// a more detailed discussion of handleOpenURL
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    // attempt to extract a token from the url
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                    fallbackHandler:^(FBAppCall *call) {
//                        NSLog(@"In fallback handler");
                    }];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
#if DEBUG
    NSLog(@"Launchoptions: %@", launchOptions);
#endif
    
#if !TARGET_IPHONE_SIMULATOR
    //TestFlight
#warning Check that the following lines are commented out for submission to App Store
//    if([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
//    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];

    [TestFlight takeOff:kTestFlightAPIKey];
#endif
    
    //Customize appearance iOS5
    [self customizeAppearance];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];    
    
    //perform cleanup of previous version's data
    if(![[NSUserDefaults standardUserDefaults] boolForKey:@"cleanup_done"])
    {
        [self performCleanupOldVersion];
    }


    
    //Start updating location
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLocationForbidden:) name:kLocationServicesForbidden object:nil];
    [[AppState sharedInstance] startLocationServices];
    

    // Restore game state
    [[AppState sharedInstance] restore];
#if DEBUG
    NSLog(@"Stored checkins count: %d", [[[AppState sharedInstance] checkins] count]);
#endif
    if ([[AppState sharedInstance] playerIsInCompass] == YES) {
        
        // We were in compass view when we quit, we restore the navigation controller and reopen the compass view

        CitySelectionViewController *cityVC = [[CitySelectionViewController alloc] initWithStyle:UITableViewStyleGrouped];
        CatalogViewController *catalogVC = [[CatalogViewController alloc] initWithNibName:@"CatalogViewController" bundle:nil];
        RouteStartViewController *rvc = [[RouteStartViewController alloc] initWithStyle:UITableViewStyleGrouped];
//        rvc.route = [[AppState sharedInstance] currentRoute];
        CompassViewController *cvc = [[CompassViewController alloc] initWithNibName:@"CompassViewController" bundle:nil];
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:cityVC];
        [self.navigationController pushViewController:catalogVC animated:NO];
        [self.navigationController pushViewController:rvc animated:NO];
        [self.navigationController pushViewController:cvc animated:NO];
        
    }
    else{
        // We were not in compass view, so first we have to check if the user has a selected city
        if([[AppState sharedInstance] currentCity] != nil){
            //if the city is not nil, means the player is already in game
            CitySelectionViewController *cityVC = [[CitySelectionViewController alloc] initWithStyle:UITableViewStyleGrouped];
            CatalogViewController *catalogVC = [[CatalogViewController alloc] initWithNibName:@"CatalogViewController" bundle:nil];
            self.navigationController = [[UINavigationController alloc] initWithRootViewController:cityVC];
            [self.navigationController pushViewController:catalogVC animated:NO];

        }
        else{
            //player has to select a city
            CitySelectionViewController *cvc = [[CitySelectionViewController alloc] initWithStyle:UITableViewStyleGrouped];
            cvc.cities = [[AppState sharedInstance] cities];
            self.navigationController = [[UINavigationController alloc] initWithRootViewController:cvc];
        }
    }

    //Tell AFNetworking to use the Network Activity Indicator
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    // Update
//    [self updateContent];
    
    
    //Start app
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    //This method is called also when the user clicks on the "lock" screen on the iPhone
    if([[AppState sharedInstance] playerIsInCompass])
        [[AppState sharedInstance]  startMonitoringForDestination];


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
    [[GoHikeHTTPClient sharedClient] pushCheckins];
    [FBAppCall handleDidBecomeActive];
//    [[AppState sharedInstance] stopMonitoringForDestination];

}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    // We already save everywhere in the app, so not using this
    
    [[AppState sharedInstance] stopLocationServices];
    [FBSession.activeSession close];
    
    //If the user closes the app, we don't want to monitor for regions anymore. It's game over!
    [[AppState sharedInstance] stopMonitoringForDestination];
}

- (void)performCleanupOldVersion
{
    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [docsPath stringByAppendingPathComponent: @"content.json"];
    __autoreleasing NSError* contentError = nil;
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&contentError];
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"cleanup_done"];
    }
}

#pragma mark - Notification Handlers

-(void)handleLocationForbidden:(NSNotification*)notification
{
    NSLog(@"Cannot use LocationServices!");

    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLocationServicesForbidden object:nil];
    [[AppState sharedInstance] stopLocationServices];
    
    CannotPlayViewController *cvc = [[CannotPlayViewController alloc] initWithNibName:@"CannotPlayViewController" bundle:nil];
    cvc.messageLabel.text = NSLocalizedString(@"No location available. Please turn on location in Settings", @"No location available. Please turn on location in Settings");
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:cvc];
    self.window.rootViewController = self.navigationController;

}

#pragma mark - Location Manager

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
    NSLog(@"Did enter region %@", region);
}

@end
