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
    //Register for the loadingFinished notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadCatalogCompleted:) name:kFinishedLoadingCatalog object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadCitiesCompleted:) name:kFinishedLoadingCities object:nil];
    
    
    //load the cities
    _cities = [[NSDictionary alloc] init];
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
    //Hide the refresh control
    [self.refreshControl endRefreshing];

    [SVProgressHUD showWithStatus:NSLocalizedString(@"Getting cities", @"Getting cities")];

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

    [[GoHikeHTTPClient sharedClient] getCatalogForCity:cityID];
    
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

}

- (void)handleLoadCitiesCompleted:(NSNotification*)notification
{
    NSLog(@"Finished loading catalog");
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
