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

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    

    //register the UITableViewCell
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
            
    //add RefreshControl to TableView
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc]
                                        init];
    [refreshControl addTarget:self action:@selector(loadCities) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = [UIColor grayColor];
    self.refreshControl = refreshControl;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    //maybe we have it already, restored from before
    _cities = [[AppState sharedInstance] cities];
    //load the cities
    [self getLocation];

}

- (void)getLocation
{
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Getting position", @"Getting position")];
    [[AppState sharedInstance] startLocationServices];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadCities) name:kLocationServicesGotBestAccuracyLocation object:nil];
}

- (void)gotLocation
{
    [[AppState sharedInstance] stopLocationServices];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)loadCities
{  
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadCitiesCompleted:) name:kFinishedLoadingCities object:nil];
    //Hide the refresh control
    [self.refreshControl endRefreshing];

    AFNetworkReachabilityStatus status = [[GoHikeHTTPClient sharedClient] networkReachabilityStatus];
    if(status == AFNetworkReachabilityStatusNotReachable || status == AFNetworkReachabilityStatusUnknown)
    {
        [SVProgressHUD dismiss];
        NSLog(@"Not reachable, not loading cities");
        return;
    }
    
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Getting cities", @"Getting cities") maskType:SVProgressHUDMaskTypeGradient];

    [[GoHikeHTTPClient sharedClient] locate];
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
            return [[_cities within] count]; //[[_cities objectForKey:@"within"] count];
            break;
        case 1:
            return  [[_cities other] count]; //[[_cities objectForKey:@"other"] count];
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
            cell.textLabel.text =  [[[_cities within] objectAtIndex:indexPath.row] name]; //[[[_cities objectForKey:@"within"] objectAtIndex:indexPath.row] objectForKey:@"name"];
        }
            break;
        case 1:
        {
            //cities other
            cell.textLabel.text = [[[_cities other] objectAtIndex:indexPath.row] name]; //[[[_cities objectForKey:@"other"] objectAtIndex:indexPath.row] objectForKey:@"name"];
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
    switch (indexPath.section) {
        case 0:
        {
            //within
            int city = [[[_cities within] objectAtIndex:indexPath.row] cityIdentifier]; //[[[[_cities objectForKey:@"within"] objectAtIndex:indexPath.row] objectForKey:@"id"] integerValue];
            [self getCatalogForCity:city];
        }
            break;
        case 1:
        {
            //others
            int city = [[[_cities other] objectAtIndex:indexPath.row] cityIdentifier]; //[[[[_cities objectForKey:@"other"] objectAtIndex:indexPath.row] objectForKey:@"id"] integerValue];
            [self getCatalogForCity:city];
        }
            break;
        default:
            break;
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)getCatalogForCity:(int)cityID
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadCatalogCompleted:) name:kFinishedLoadingCatalog object:nil];
    //if we got catalog > 24h ago, we redownload it anyway
    
    NSString* libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString *filePath = [libraryPath stringByAppendingPathComponent: [NSString stringWithFormat:@"%d",cityID]];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        __autoreleasing NSError *error;
        NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:&error];
        NSDate *fileDate =[attributes objectForKey:NSFileModificationDate];
        NSTimeInterval howRecent = [fileDate timeIntervalSinceNow];
        if (abs(howRecent) < 60*60*24 ) {
            //file is less than 24 hours old, use this file.
            GHCatalog *loadedCatalog = [GHCatalog arrayWithContentsOfFile:filePath];
            [AppState sharedInstance].currentCatalog = loadedCatalog;
            [[NSNotificationCenter defaultCenter] postNotificationName:kFinishedLoadingCatalog object:nil];
        }
        else{
            //file is older than 24 hours, download newer version it
            [SVProgressHUD showWithStatus:NSLocalizedString(@"Getting new content", @"Getting new content")];
            
            [[GoHikeHTTPClient sharedClient] getCatalogForCity:cityID];
        }
    }
    else{
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Getting new content", @"Getting new content")];

        [[GoHikeHTTPClient sharedClient] getCatalogForCity:cityID];
    }
    
}

- (void)handleLoadCatalogCompleted:(NSNotification*)notification
{
    NSLog(@"Finished loading catalog");
    if([[notification userInfo] objectForKey:@"error"])
    {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Error loading catalog", @"Error loading catalog")];
    }
    else{
        [SVProgressHUD showSuccessWithStatus:nil];
        
        CatalogViewController *cvc = [[CatalogViewController alloc] initWithNibName:@"CatalogViewController" bundle:nil];
        [self.navigationController pushViewController:cvc animated:YES];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFinishedLoadingCatalog object:nil];

}

- (void)handleLoadCitiesCompleted:(NSNotification*)notification
{
    NSLog(@"Finished loading cities");
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
