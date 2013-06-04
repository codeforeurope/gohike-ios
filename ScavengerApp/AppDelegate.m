//
//  AppDelegate.m
//  ScavengerApp
//
//  Created by Giovanni on 5/15/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "AppDelegate.h"

#import "SelectionViewController.h"

#import "RouteStartViewController.h"

#import "CompassViewController.h"

#import "AFNetworking.h"

#import "Secret.h"

    //@"http://10.1.11.148:3000"
#define kGOHIKEAPIURL @"http://gohike.herokuapp.com"



@implementation AppDelegate

- (void)customizeAppearance
{
    // Create resizable images
    UIImage *topNavbarImage = [[UIImage imageNamed:@"navigation-top-background.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
//    UIImage *gradientImage44 = [[UIImage imageNamed:@"surf_gradient_textured_44"]
//                                resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
//    UIImage *gradientImage32 = [[UIImage imageNamed:@"surf_gradient_textured_32"]
//                                resizableImageWithCapInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    // Set the background image for *all* UINavigationBars
    [[UINavigationBar appearance] setBackgroundImage:topNavbarImage
                                       forBarMetrics:UIBarMetricsDefault];
//    [[UINavigationBar appearance] setBackgroundImage:gradientImage32
//                                       forBarMetrics:UIBarMetricsLandscapePhone];
    
    // Customize the title text for *all* UINavigationBars
    [[UINavigationBar appearance] setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
      UITextAttributeTextColor,
      //[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8],
      //UITextAttributeTextShadowColor,
      //[NSValue valueWithUIOffset:UIOffsetMake(0, -1)],
      //UITextAttributeTextShadowOffset,
      [UIFont fontWithName:@"HelveticaNeue" size:0.0],
      UITextAttributeFont,
      nil]];
    
    
//    UIImage *buttonBack30 = [[UIImage imageNamed:@"button_back_textured_30"]
//                             resizableImageWithCapInsets:UIEdgeInsetsMake(0, 13, 0, 5)];
//    UIImage *buttonBack24 = [[UIImage imageNamed:@"button_back_textured_24"]
//                             resizableImageWithCapInsets:UIEdgeInsetsMake(0, 12, 0, 5)];
//    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:buttonBack30
//                                                      forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
//    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:buttonBack24
//                                                      forState:UIControlStateNormal barMetrics:UIBarMetricsLandscapePhone];

}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self customizeAppearance];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    
    // load the secret
    __autoreleasing NSError* secretError = nil;
    NSString *secretPath = [[NSBundle mainBundle] pathForResource:@"secret" ofType:@""];
    [[AppState sharedInstance] setSecret:[NSString stringWithContentsOfFile:secretPath encoding:NSUTF8StringEncoding error:&secretError]];
    
    // Get device UDID
    NSString *deviceID = [[UIDevice currentDevice] uniqueIdentifier];  // <-- deprecated
    //TODO: This works and is safe because iOS "fakes" the UUID and does not return the true UUID of the phone, but it's deprecated, so get a proper device ID

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
#if DEBUG
    NSLog(@"Restored the active Profile: %d", [[AppState sharedInstance] activeProfileId]);
    NSLog(@"Stored checkins count: %d", [[[AppState sharedInstance] checkins] count]);
#endif
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
    
    NSURL *url = [NSURL URLWithString:kGOHIKEAPIURL];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSString *currentVersion = [[[AppState sharedInstance] game] objectForKey:@"version"];
    NSLog(@"current version %@", currentVersion);
    
    if ([httpClient networkReachabilityStatus] != AFNetworkReachabilityStatusNotReachable) {
        //We try to download new content only if we are on wifi
        NSDictionary *versionDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:currentVersion, @"version", nil];
        [httpClient postPath:@"/api/ping" parameters:versionDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
            __autoreleasing NSError* pingError = nil;
            NSDictionary *r = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&pingError];
            NSLog(@"Status: %@", [r objectForKey:@"status"]);
            if([[r objectForKey:@"status"] isEqualToString:@"update"])
            {
                NSMutableURLRequest *contentRequest = [httpClient requestWithMethod:@"GET" path:@"/api/content" parameters:nil];
                
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
                    NSLog(@"Download of new content failed with error: %@", [error description]);
                }];
                [contentOperation start];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Update request failed with error: %@", [error description]);
        }];

        
//        NSMutableURLRequest *pingRequest = [httpClient requestWithMethod:@"POST" path:@"/ping" parameters:versionDictionary];
//        [pingRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//
//        AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:pingRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//            NSLog(@"Status: %@", [JSON objectForKey:@"status"]);
//            if([[JSON objectForKey:@"status"] isEqualToString:@"update"])
//            {
//                NSMutableURLRequest *contentRequest = [httpClient requestWithMethod:@"GET" path:@"/content" parameters:nil];
//            
//                AFJSONRequestOperation *contentOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:contentRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
//                    NSLog(@"New game version %@", [JSON objectForKey:@"version"]);
//                    NSLog(@"Saving new data to disk");
//                    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//                    NSString *filePath = [docsPath stringByAppendingPathComponent: @"content.json"];
//                    __autoreleasing NSError* contentError = nil;
//                   
//                    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:JSON
//                                                                       options:kNilOptions
//                                                                         error:&contentError];
//                    if([jsonData writeToFile:filePath atomically:YES])
//                    {
//                        NSLog(@"Updated ok");
//                    }
//                    
//                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
//                    NSLog(@"Download of new content failed");
//                }];
//                [contentOperation start];
//            }
//        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
//            NSLog(@"Update request failed with error: %@", [error description]);
//        }];
//        [operation start];
    }
    
    // Try to push checkins, if network is reachable

    if(httpClient.networkReachabilityStatus != AFNetworkReachabilityStatusNotReachable)
    {
        // Get the indexes of the checkins that have not been uploaded yet
        NSIndexSet *indexes = [[[AppState sharedInstance] checkins] indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return ((Checkin*)obj).uploaded == NO;
        }];
        // Prepare an empty array
        NSMutableArray *checkinsToPush = [[NSMutableArray alloc] init];
        
        //Get the dictionary representation of all check-ins
        [[[[AppState sharedInstance] checkins] objectsAtIndexes:indexes] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//            [checkinsToPush addObject:[((Checkin*)obj) dictionaryRepresentation]];
            [checkinsToPush addObject:[((Checkin*)obj) dictionaryRepresentation]];
        }];
#if DEBUG
        NSLog(@"checkins data: %@", checkinsToPush);
#endif
        if(YES) //[checkinsToPush count] > 0
        {
            NSDictionary *checkinsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:deviceID, @"identifier", checkinsToPush, @"checkins", nil];
            
            
            
//            [httpClient postPath:@"/api/checkin" parameters:checkinsDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
//#if DEBUG
//                NSLog(@"Pushed checkins OK!");
//#endif
//                // Set all checkins to uploaded and save to disk
//                [[[AppState sharedInstance] checkins] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//                    ((Checkin*)obj).uploaded = YES;
//                }];
//                [[AppState sharedInstance] save];
//            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                NSLog(@"Failed to update checkins: %@",[error description]);
//            }];
            __autoreleasing NSError *checkinsError;
            NSData *postBodyData = [NSJSONSerialization dataWithJSONObject:checkinsDictionary options:NSJSONWritingPrettyPrinted error:&checkinsError];
            NSMutableURLRequest *checkinRequest = [httpClient requestWithMethod:@"POST" path:@"/api/checkin" parameters:nil];

            NSLog(@"Secret: %@",[[AppState sharedInstance] secret] );
            NSString *s = [NSString stringWithFormat:@"%@", [[AppState sharedInstance] secret]];
            NSString *t = [NSString stringWithFormat:@"%@",@"bla"];
            [checkinRequest addValue:kAPISecret forHTTPHeaderField:@"Take-A-Hike-Secret"];
            [checkinRequest addValue:t forHTTPHeaderField:@"b"];
            [checkinRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        
            [checkinRequest setHTTPBody:postBodyData];
            
            AFJSONRequestOperation *checkinOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:checkinRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
#if DEBUG
                NSLog(@"Pushed checkins OK!");
#endif
                // Set all checkins to uploaded and save to disk
                [[[AppState sharedInstance] checkins] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                    ((Checkin*)obj).uploaded = YES;
                }];
                [[AppState sharedInstance] save];
                
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
