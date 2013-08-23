//
//  CitySelectionViewController.m
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/21/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "CitySelectionViewController.h"
#import "CatalogViewController.h"
#import "SVProgressHUD.h"
#import "AFNetworking.h"

#define base_url @"http://www.gotakeahike.nl/"

@interface CitySelectionViewController ()

@property (nonatomic, strong) NSDictionary *cities;


@end

@implementation CitySelectionViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadCatalogCompleted:) name:kFinishedLoadingCatalog object:nil];
    
    //register the UITableViewCell
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    //add RefreshControl to TableView
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]
                                        init];
    [refreshControl addTarget:self action:@selector(loadCities) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = [UIColor grayColor];
    self.refreshControl = refreshControl;
    
    //load the cities
    _cities = [[NSDictionary alloc] init];
    [self getLocation];
    
}

- (void)getLocation
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Getting position", @"Getting position")];
     [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadCities) name:kLocationServicesGotBestAccuracyLocation object:nil];
}

- (void)gotLocation
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadCities
{
    //Hide the refresh control
    [self.refreshControl endRefreshing];


    [SVProgressHUD showWithStatus:NSLocalizedString(@"Getting cities", @"Getting cities")];
//    NSDictionary *requestBody = @{@"latitude": @52.3702157, @"longitude":@4.8951679 };
    NSNumber *latitude = [NSNumber numberWithDouble: [[AppState sharedInstance] currentLocation].coordinate.latitude];
    NSNumber *longitude = [NSNumber numberWithDouble: [[AppState sharedInstance] currentLocation].coordinate.longitude];
    NSDictionary *requestBody = @{@"latitude": latitude,
                                  @"longitude": longitude};
    
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:base_url]];
    [httpClient setParameterEncoding:AFJSONParameterEncoding];

    __autoreleasing NSError *error;
    NSMutableURLRequest *locationRequest = [httpClient requestWithMethod:@"POST" path:@"/api/locate" parameters:nil];
    [locationRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [locationRequest setHTTPBody:[NSJSONSerialization dataWithJSONObject:requestBody options:0 error:&error]];
    
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:locationRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {

        NSLog(@"JSON: %@", JSON);

        if([NSJSONSerialization isValidJSONObject:JSON]){
            _cities = (NSDictionary*)JSON;
            
        [self.tableView reloadData];
            [SVProgressHUD showSuccessWithStatus:nil];
        }
        else{
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Cannot load cities", @"Cannot load cities")];
            NSLog(@"JSON data not valid");
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Error when retrieving cities: %@", [error description]);
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Error loading cities", @"Error loading cities")];
    }];
    [httpClient enqueueHTTPRequestOperation:op];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return [[_cities objectForKey:@"within"] count];
            break;
        case 1:
            return [[_cities objectForKey:@"other"] count];
            break;
        default:
            break;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0:
        {
            //cities within
            cell.textLabel.text = [[[_cities objectForKey:@"within"] objectAtIndex:indexPath.row] objectForKey:@"name"];
        }
            break;
        case 1:
        {
            //cities other
            cell.textLabel.text = [[[_cities objectForKey:@"other"] objectAtIndex:indexPath.row] objectForKey:@"name"];
        }
            break;
        default:
            break;
    }
    
    
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return NSLocalizedString(@"Within", @"Section title for cities the player is within");
            break;
        case 1:
            return NSLocalizedString(@"Other", @"Section title for other cities outside of player range");
            break;
        default:
            break;
    }
    return nil;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //TODO: go to the screen where we display the routes
    switch (indexPath.section) {
        case 0:
        {
            //within
            int city = [[[[_cities objectForKey:@"within"] objectAtIndex:indexPath.row] objectForKey:@"id"] integerValue];
            [self getCatalogForCity:city];
        }
            break;
        case 1:
        {
            //others
            int city = [[[[_cities objectForKey:@"other"] objectAtIndex:indexPath.row] objectForKey:@"id"] integerValue];
            [self getCatalogForCity:city];
        }
            break;
        default:
            break;
    }
}

- (void)getCatalogForCity:(int)cityID
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Getting content", @"Getting content")];
    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:base_url]];
    [httpClient setParameterEncoding:AFJSONParameterEncoding];
    
    
    NSString *locale = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    NSString *path = [NSString stringWithFormat:@"/api/%@/catalog/%d", locale, cityID];
    NSMutableURLRequest *catalogRequest = [httpClient requestWithMethod:@"GET" path:path parameters:nil];
    [catalogRequest setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    AFJSONRequestOperation *op = [AFJSONRequestOperation JSONRequestOperationWithRequest:catalogRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        NSLog(@"got a response: %@", response);
        NSLog(@"JSON: %@", JSON);
        if([NSJSONSerialization isValidJSONObject:JSON]){
            GHCatalog *catalog = (GHCatalog*)JSON;
            
            NSDictionary *userInfo =  @{@"catalog":catalog};
            NSNotification *resultNotification = [NSNotification notificationWithName:kFinishedLoadingCatalog object:self userInfo:userInfo];
            [SVProgressHUD showSuccessWithStatus:nil];

            [[NSNotificationCenter defaultCenter] postNotification:resultNotification];
            
        }
        else{
            [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Cannot load catalog", @"Cannot load catalog")];
            NSLog(@"JSON data not valid");
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Error when retrieving cities: %@", [error description]);
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Error loading catalog", @"Error loading catalog")];
    }];
    [httpClient enqueueHTTPRequestOperation:op];
    

    
}

- (void)handleLoadCatalogCompleted:(NSNotification*)notification
{

    NSLog(@"Finished loading catalog");
    CatalogViewController *cvc = [[CatalogViewController alloc] initWithNibName:@"CatalogViewController" bundle:nil];
    cvc.catalog =  [notification.userInfo objectForKey:@"catalog"];;
    [self.navigationController pushViewController:cvc animated:YES];
}


@end
