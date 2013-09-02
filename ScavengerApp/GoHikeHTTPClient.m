//
//  GoHikeHTTPClient.m
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/25/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "GoHikeHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "AFImageRequestOperation.h"
#import "SSKeychain.h"
#import "Secret.h"


NSString* const kGOHIKE_BASEURL = @"http://www.gotakeahike.nl";

NSString* const kFinishedLoadingCatalog = @"kFinishedLoadingCatalog";
NSString* const kFinishedLoadingRoute = @"kFinishedLoadingRoute";
NSString* const kFinishedLoadingCities = @"kFinishedLoadingCities";
NSString* const kFinishedDownloadingFile = @"kFinishedDownloadingFile";

@implementation GoHikeHTTPClient

+ (id)sharedClient {
    static GoHikeHTTPClient *__instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *baseUrl = [NSURL URLWithString:kGOHIKE_BASEURL];
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
        NSNotification *notification = [NSNotification notificationWithName:kFinishedLoadingCities object:self userInfo:userInfo];
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
        
        
        if([NSJSONSerialization isValidJSONObject:JSON]){
            [AppState sharedInstance].cities = (GHCities*)JSON;
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
    
    GHCatalog* existingCatalog = [FileUtilities loadCatalogFromFileWithId:cityID];
    if(existingCatalog){
        NSDate *lastModifiedDate = [FileUtilities lastModifiedDateForCatalogWithId:cityID];
        if( abs([lastModifiedDate timeIntervalSinceNow]) > 60*60*24)
        {
            //need to redownload catalog
            //continue execution
        }
        else{
            //catalog is recent enough
            [[AppState sharedInstance] setCurrentCatalog:existingCatalog];
            [[AppState sharedInstance] save];
            NSDictionary *userInfo = @{ @"expectedFiles" : @0};
            [[NSNotificationCenter defaultCenter] postNotificationName:kFinishedLoadingCatalog object:nil userInfo:userInfo];
            return;
        }

    }
    
    NSString *locale = [Utilities getCurrentLocale];
    NSString *path = [NSString stringWithFormat:@"/api/%@/catalog/%d", locale, cityID];
    NSMutableURLRequest *catalogRequest = [self requestWithMethod:@"GET" path:path parameters:nil];
    [catalogRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:catalogRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if([NSJSONSerialization isValidJSONObject:JSON]){ 
            
            GHCatalog *catalog = (GHCatalog*)JSON;

            int expected = [[FileUtilities picturesInCatalog:catalog] count];
#if DEBUG
            NSLog(@"For catalog %d expected %d pictures", cityID, expected);
#endif
            NSDictionary *userInfo = @{ @"expectedFiles" : [NSNumber numberWithInt:expected]};
            [[NSNotificationCenter defaultCenter] postNotificationName:kFinishedLoadingCatalog object:nil userInfo:userInfo];
            
            [FileUtilities saveCatalog:catalog WithId:cityID];
            [[AppState sharedInstance] setCurrentCatalog:catalog];
            [[AppState sharedInstance] save];
            
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


- (void)getRoute:(NSInteger)routeId
{
    NSString *path = [NSString stringWithFormat:@"/api/route/%d", routeId];
    NSMutableURLRequest *routeRequest = [self requestWithMethod:@"GET" path:path parameters:nil];
    [routeRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:routeRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if([NSJSONSerialization isValidJSONObject:JSON]){
            
            GHRoute *route = (GHRoute*)JSON;
            
            [[AppState sharedInstance] setCurrentRoute:route];
            
            int expected = [[FileUtilities picturesInRoute:route] count];
#if DEBUG
            NSLog(@"For route %d expected %d pictures", routeId, expected);
#endif
            NSDictionary *userInfo = @{ @"expectedFiles" : [NSNumber numberWithInt:expected]};
            [[NSNotificationCenter defaultCenter] postNotificationName:kFinishedLoadingRoute object:nil userInfo:userInfo];
            [FileUtilities saveRoute:route writeRouteFile:YES];

            
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


- (void)downloadFileWithUrl:(NSString*)fileUrl savePath:(NSString*)savePath
{
    if(![[NSFileManager defaultManager] fileExistsAtPath:savePath]){
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:fileUrl]];
        AFImageRequestOperation *operation;
        operation = [AFImageRequestOperation imageRequestOperationWithRequest:request imageProcessingBlock:^UIImage *(UIImage *image) {
            return image;
        } success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
            NSData *data = UIImagePNGRepresentation(image);
            NSDictionary *userInfo = @{@"file" : savePath};
            [[NSNotificationCenter defaultCenter] postNotificationName:kFinishedDownloadingFile object:nil userInfo:userInfo];
            BOOL success = [data writeToFile:savePath atomically:YES];
            if(!success)
                NSLog(@"Failed writing downloaded file to file %@", savePath);
        } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            [[NSNotificationCenter defaultCenter] postNotificationName:kFinishedDownloadingFile object:nil userInfo:nil];
        }];
        [self enqueueHTTPRequestOperation:operation];
    }
    else{
        //If file exists, it's as if it was downloaded already
        [[NSNotificationCenter defaultCenter] postNotificationName:kFinishedDownloadingFile object:nil userInfo:nil];
    }
}

-(void)pushCheckins
{
    // Get device UDID
    // getting the unique key (if present ) from keychain , assuming "your app identifier" as a key
    NSString *deviceID = [SSKeychain passwordForService:kServiceNameForKeychain account:@"user"];
    if (deviceID == nil) { // if this is the first time app lunching , create key for device
        NSString *uuid  = [Utilities createNewUUID];
        // save newly created key to Keychain
        [SSKeychain setPassword:uuid forService:kServiceNameForKeychain account:@"user"];
        // this is the one time process
        deviceID = uuid;
    }
    
    if(self.networkReachabilityStatus != AFNetworkReachabilityStatusNotReachable)
    {
        // Get the indexes of the checkins that have not been uploaded yet
        NSIndexSet *indexes = [[[AppState sharedInstance] checkins] indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return ((Checkin*)obj).uploaded == NO;
        }];
        // Prepare an empty array
        NSMutableArray *checkinsToPush = [[NSMutableArray alloc] init];
        
        //Get the dictionary representation of all check-ins
        [[[[AppState sharedInstance] checkins] objectsAtIndexes:indexes] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {

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
            NSMutableURLRequest *checkinRequest = [self requestWithMethod:@"POST" path:@"/api/checkin" parameters:nil];
            
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
            
            [self enqueueHTTPRequestOperation:checkinOperation];
        }
        
    }
}

@end
