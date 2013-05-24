//
//  RouteStartViewController.m
//  ScavengerApp
//
//  Created by Giovanni on 5/15/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "RouteStartViewController.h"
#import "CompassViewController.h"
#import "LocationDetailsViewController.h"

@interface RouteStartViewController ()

@end

@implementation RouteStartViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
        Location *loc1 = [[Location alloc] init];
        loc1.locationId = 1;
        loc1.locationName = @"Rembrandtoren";
        loc1.locationPicture = @"";
        loc1.latitude = 52.34444;
        loc1.longitude = 4.91667;
        
        Location *loc2 = [[Location alloc] init];
        loc2.locationId = 2;
        loc2.locationName = @"RAI Congress Center";
        loc2.locationPicture = @"";
        loc2.latitude = 52.34123;
        loc2.longitude = 4.92;
        
        [AppState sharedInstance].locations = [NSArray arrayWithObjects:loc1, loc2, nil];
        _currentRoute.locations = [NSArray arrayWithObjects:loc1, loc2, nil];
        [AppState sharedInstance].activeTarget = [[AppState sharedInstance].locations objectAtIndex:0];
        [AppState sharedInstance].activeTargetId = [AppState sharedInstance].activeTarget.locationId;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    UIBarButtonItem *startRouteButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Start Route", nil) style:UIBarButtonItemStylePlain target:self action:@selector(StartRoute)];
    self.navigationItem.rightBarButtonItem = startRouteButton;


    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    int number;
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            number = 2;
            break;
        default:
            number = [_currentRoute.locations count];
            break;
    }
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
        
    switch (indexPath.section) {
        case 0:
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = _currentRoute.name;
                    break;
                case 1:
                    cell.textLabel.text = _currentRoute.description;
                default:
                    break;
            }
            break;
        case 1:
        {
            Location *loc = [_currentRoute.locations objectAtIndex:indexPath.row];
            cell.textLabel.text = loc.locationName;
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        }
            break;
        default:
            break;
    }
        
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *retString;
    switch (section) {
        case 0:
            retString =  NSLocalizedString(@"Route Information", nil);
            break;
        case 1:
            retString =  NSLocalizedString(@"Locations in Route", nil);
            break;
        default:
            break;
    }
    
    return retString;
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
    
    //TODO: open the location details (if it has already been visited)
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (void)StartRoute
{
    //TODO: handle the case when we are resuming the current route
    [[AppState sharedInstance] setActiveRoute:_currentRoute];
    Location *target = [_currentRoute.locations objectAtIndex:0]; //this is OK only if we start from first location
    [[AppState sharedInstance] setActiveTarget:target];
    [[AppState sharedInstance] setActiveTargetId:target.locationId];
    [[AppState sharedInstance] setPlayerIsInCompass:YES];
    
    CompassViewController *compass = [[CompassViewController alloc] init];
    [self.navigationController pushViewController:compass animated:YES];
    
    
}

@end
