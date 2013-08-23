//
//  AppDelegate.m
//  ScavengerApp
//
//  Created by Giovanni Maggini on 5/15/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "AppDelegate.h"
#import "SelectionViewController.h"
#import "RouteStartViewController.h"
#import "CompassViewController.h"
#import "AFNetworking.h"
#import "Secret.h"
#import "SSKeychain.h"
#import <AdSupport/AdSupport.h>
#import "CitySelectionViewController.h"
#import "CannotPlayViewController.h"

#define kGOHIKEAPIURL @"http://gohike.herokuapp.com"

#define kAppHasFinishedContentUpdate @"AppHasFinishedContentUpdate"

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
      [UIFont fontWithName:@"HelveticaNeue" size:24.0],
      UITextAttributeFont,
      nil]];
    
    UIImage *backButton = [[UIImage imageNamed:@"back.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 14, 0, 4)];
    
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:backButton forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];

    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    
#if !TARGET_IPHONE_SIMULATOR
    //TestFlight
#warning Check that the following lines are commented out for submission to App Store
//    if([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0)
//    [TestFlight setDeviceIdentifier:[[UIDevice currentDevice] uniqueIdentifier]];

    [TestFlight takeOff:kTestFlightAPIKey];
#endif
    
    [self customizeAppearance];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];    
    
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
        if(!error){
        [[AppState sharedInstance] setGame:[downloadedGameData dictionaryRepresentation]];
        }
        else{
            //delete content.json in document folder, as it may be corrupt
            [[NSFileManager defaultManager] removeItemAtPath: filePath error: &error];
            //then load the data from the content.json bundled
            gameData = [GHGameData modelObjectWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:0 error:&error]];
            [[AppState sharedInstance] setGame:[gameData dictionaryRepresentation]];
        }
    }
    else{
        gameData = [GHGameData modelObjectWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:0 error:&error]];
        [[AppState sharedInstance] setGame:[gameData dictionaryRepresentation]];
    }
    
    //Start updating location
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLocationFailure:) name:kLocationServicesFailure object:nil];
    [[AppState sharedInstance] startLocationServices];
    

    
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
        rvc.route = [[AppState sharedInstance] currentRoute];
        CompassViewController *cvc = [[CompassViewController alloc] init];
        self.navigationController = [[UINavigationController alloc] initWithRootViewController:selectCharacterVC];
        [self.navigationController pushViewController:rvc animated:NO];
        [self.navigationController pushViewController:cvc animated:NO];
        
    }
    else{
        // We were not in compass view, so first we have to check if the user has a selected city
        if([[AppState sharedInstance] currentCity] != nil){
            //if the city is not nil, means the player is already in game
            SelectionViewController *selectCharacterVC = [[SelectionViewController alloc] initWithNibName:@"SelectionViewController" bundle:nil];
            self.navigationController = [[UINavigationController alloc] initWithRootViewController:selectCharacterVC];

        }
        else{
            //player has to select a city
            CitySelectionViewController *cvc = [[CitySelectionViewController alloc] initWithStyle:UITableViewStylePlain];
            self.navigationController = [[UINavigationController alloc] initWithRootViewController:cvc];
        }
    }

    //Tell AFNetworking to use the Network Activity Indicator
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
    
    // Update
    [self updateContent];
    
    
    //Start app
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
//    NSLog(@"Resigned active, setup fence");
    //TODO: setup geofencing, notifications, etc.
    //This method is called also when the user clicks on the "lock" screen on the iPhone
    
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
    [self pushCheckins];
    
//    NSLog(@"back to active, delete fence");
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    // We already save everywhere in the app, so not using this
    
    [[AppState sharedInstance] stopLocationServices];
}


#pragma mark - Handlers

-(void)handleLocationFailure:(NSNotification*)notification
{
    NSLog(@"Cannot use LocationServices!");

    CannotPlayViewController *cvc = [[CannotPlayViewController alloc] initWithNibName:@"CannotPlayViewController" bundle:nil];
    cvc.messageLabel.text = NSLocalizedString(@"No location available. Please turn on location in Settings", @"No location available. Please turn on location in Settings");
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:cvc];
    self.window.rootViewController = self.navigationController;

}

#pragma mark - Network actions

-(void)updateContent
{
    NSURL *url = [NSURL URLWithString:kGOHIKEAPIURL];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    NSString *currentVersion = [[[AppState sharedInstance] game] objectForKey:@"version"];
    
    if ([httpClient networkReachabilityStatus] != AFNetworkReachabilityStatusNotReachable) {
        //We try to download new content only if we are on wifi
        NSDictionary *versionDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:currentVersion, @"version", nil];
        [httpClient postPath:@"/api/ping" parameters:versionDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
            __autoreleasing NSError* pingError = nil;
            NSDictionary *r = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingAllowFragments error:&pingError];
#if DEBUG
            NSLog(@"Current Content Status: %@", [r objectForKey:@"status"]);
#endif
            if([[r objectForKey:@"status"] isEqualToString:@"update"])
            {
                NSMutableURLRequest *contentRequest = [httpClient requestWithMethod:@"GET" path:@"/api/content" parameters:nil];
                
                AFJSONRequestOperation *contentOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:contentRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
                    NSLog(@"New game version %@", [JSON objectForKey:@"version"]);
                    NSString *docsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                    NSString *filePath = [docsPath stringByAppendingPathComponent: @"content.json"];
                    NSURL *filePathUrl = [NSURL fileURLWithPath:filePath];
                    __autoreleasing NSError* contentError = nil;
                    
                    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:JSON
                                                                       options:kNilOptions
                                                                         error:&contentError];
                    if([jsonData writeToURL:filePathUrl atomically:YES])
                    {
                        NSLog(@"Updated ok");
                        //set to exclude file from iCloud backup
                        [self addSkipBackupAttributeToItemAtURL:filePathUrl];
   
                        [[AppState sharedInstance] setGame:[NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&contentError]];
                        [[NSNotificationCenter defaultCenter] postNotificationName:kAppHasFinishedContentUpdate object:nil];
                        
                    }
                    
                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
                    NSLog(@"Download of new content failed with error: %@", [error description]);
                }];
                [contentOperation start];
            }
            else
            {
                NSLog(@"Already on latest content version");
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"Update request failed with error: %@", [error description]);
        }];
        
    }
}

-(void)pushCheckins
{
    NSURL *url = [NSURL URLWithString:kGOHIKEAPIURL];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    
    // Get device UDID
    // getting the unique key (if present ) from keychain , assuming "your app identifier" as a key
    NSString *deviceID = [SSKeychain passwordForService:kServiceNameForKeychain account:@"user"];
    if (deviceID == nil) { // if this is the first time app lunching , create key for device
        NSString *uuid  = [self createNewUUID];
        // save newly created key to Keychain
        [SSKeychain setPassword:uuid forService:kServiceNameForKeychain account:@"user"];
        // this is the one time process
        deviceID = uuid;
    }
   
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
        if([checkinsToPush count] > 0)
        {
            NSDictionary *checkinsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:deviceID, @"identifier", checkinsToPush, @"checkins", nil];
            
            __autoreleasing NSError *checkinsError;
            NSData *postBodyData = [NSJSONSerialization dataWithJSONObject:checkinsDictionary options:NSJSONWritingPrettyPrinted error:&checkinsError];
            NSMutableURLRequest *checkinRequest = [httpClient requestWithMethod:@"POST" path:@"/api/checkin" parameters:nil];
            
            [checkinRequest addValue:kAPISecret forHTTPHeaderField:@"Take-A-Hike-Secret"];
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
}

- (NSString *)createNewUUID {
    
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}


- (BOOL)addSkipBackupAttributeToItemAtURL:(NSURL *)URL
{
    assert([[NSFileManager defaultManager] fileExistsAtPath: [URL path]]);
    
    NSError *error = nil;
    BOOL success = [URL setResourceValue: [NSNumber numberWithBool: YES]
                                  forKey: NSURLIsExcludedFromBackupKey error: &error];
    if(!success){
        NSLog(@"Error excluding %@ from backup %@", [URL lastPathComponent], error);
        __autoreleasing NSError *deleteError;
        [[NSFileManager defaultManager] removeItemAtURL:URL error:&deleteError];
    }
    return success;
}

@end
