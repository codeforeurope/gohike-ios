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

    self.title = NSLocalizedString(@"Where do you want to play?", @"Where do you want to play?");
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //Tableview background
    UIView *tablebgView = [[[NSBundle mainBundle] loadNibNamed:@"TableBackground" owner:self options:nil] objectAtIndex:0];
    [self.tableView setBackgroundView:tablebgView];


    //register the UITableViewCell
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
            
    //add RefreshControl to TableView
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]
                                        init];
    [refreshControl addTarget:self action:@selector(loadCities) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = [UIColor grayColor];
    self.refreshControl = refreshControl;
    
    //maybe we have it already, restored from before
    _cities = [[AppState sharedInstance] cities];
}

- (void)viewWillAppear:(BOOL)animated
{
    //Get the location, then load the cities
    [self getLocation];
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
            return [[_cities GHwithin] count];
            break;
        case 1:
            return  [[_cities GHother] count];
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
            cell.textLabel.text =  [[[_cities GHwithin] objectAtIndex:indexPath.row] GHname]; 
        }
            break;
        case 1:
        {
            //cities other
            cell.textLabel.text = [[[_cities GHother] objectAtIndex:indexPath.row] GHname];
        }
            break;
        default:
            break;
    }
    
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:16.0];
    
    return cell;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return NSLocalizedString(@"Nearby cities", @"Section title for cities the player is within");
            break;
        case 1:
            return NSLocalizedString(@"All playable cities", @"Section title for other cities outside of player range");
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    GHCity *city;
    
    switch (indexPath.section) {
        case 0:
        {
            //within
            city = [[_cities GHwithin] objectAtIndex:indexPath.row];
        }
            break;
        case 1:
        {
            //others
            city = [[_cities GHother] objectAtIndex:indexPath.row];
        }
            break;
        default:
            break;
    }

    [[AppState sharedInstance] setCurrentCity:city];
    [[AppState sharedInstance] save];
    [self pushNewController];
    
}

#pragma mark - Actions

- (void)getLocation
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLocationUpdate:) name:kLocationServicesGotBestAccuracyLocation object:nil];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Getting position", @"Getting position") maskType:SVProgressHUDMaskTypeBlack];
    [[AppState sharedInstance] startLocationServices];
}

- (void)loadCities
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadCitiesCompleted:) name:kFinishedLoadingCities object:nil];
    //Hide the refresh control
    [self.refreshControl endRefreshing];
    
    AFNetworkReachabilityStatus status = [[GoHikeHTTPClient sharedClient] networkReachabilityStatus];
    if(status == AFNetworkReachabilityStatusNotReachable)
    {
        [SVProgressHUD dismiss];
        NSLog(@"Not reachable, not loading cities");
        return;
    }
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Getting cities", @"Getting cities") maskType:SVProgressHUDMaskTypeBlack];
    
    [[GoHikeHTTPClient sharedClient] locate];
}

#pragma mark - Notification handlers

- (void)handleLocationUpdate:(NSNotification*)notification
{
    [[AppState sharedInstance] stopLocationServices];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLocationServicesGotBestAccuracyLocation object:nil];

    if ([[notification userInfo] objectForKey:@"error"]) {
        NSLog(@"Error in updating location: %@", [[[notification userInfo] objectForKey:@"error"] description]);
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Could not get location at this time", @"Could not get location at this time")];
    }
    else{
        [self loadCities];
    }
}

- (void)pushNewController
{
    CatalogViewController *cvc = [[CatalogViewController alloc] initWithNibName:@"CatalogViewController" bundle:nil];
    [self.navigationController pushViewController:cvc animated:YES];
}

- (void)handleLoadCitiesCompleted:(NSNotification*)notification
{
    if([[notification userInfo] objectForKey:@"error"])
    {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Error loading cities", @"Error loading cities")];
    }
    else{
        [SVProgressHUD showSuccessWithStatus:nil];
        _cities = [[AppState sharedInstance] cities];
        [self.tableView reloadData];
    }
}

@end
