//
//  LocationDetailTableViewController.m
//  GoHikeAmsterdam
//
//  Created by Giovanni on 9/1/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "LocationDetailTableViewController.h"
#import "CompassViewController.h"
#import "QuartzCore/CALayer.h"
#import "CustomBarButtonViewLeft.h"
#import "CustomBarButtonViewRight.h"
#import "MapViewController.h"


#import "LocationDetailTitleCell.h"
#import "LocationDetailPictureCell.h"
#import "LocationDetailBodyCell.h"


@interface LocationDetailTableViewController ()

@end

@implementation LocationDetailTableViewController

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
}

- (void)customizeButtons
{
    //custom back button
    CustomBarButtonViewLeft *backButton = [[CustomBarButtonViewLeft alloc] initWithFrame:CGRectMake(0, 0, 32, 32)
                                                                               imageName:@"icon-back"
                                                                                    text:NSLocalizedString(@"Back", nil)
                                                                                  target:self
                                                                                  action:@selector(onBackButton)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    //custom map button
    CustomBarButtonViewRight *mapButton = [[CustomBarButtonViewRight alloc] initWithFrame:CGRectMake(0, 0, 120, 32)
                                                                                imageName:@"icon-map"
                                                                                     text:NSLocalizedString(@"View Map", nil)
                                                                                   target:self
                                                                                   action:@selector(onMapButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:mapButton];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)replayLocation
{
    NSArray *waypoints = [[[AppState sharedInstance] currentRoute] GHwaypoints];
    GHWaypoint *thisWayPoint;
    
    NSUInteger index = [waypoints indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj GHlocation_id] == [_location GHlocation_id];
    }];
    if (index == NSNotFound) {
        
    }
    else {
        thisWayPoint = [waypoints objectAtIndex:index];
    }
    
    if([waypoints count] > 0)
    {
        [[AppState sharedInstance] setActiveRouteId: [_location GHroute_id]];
        [[AppState sharedInstance] setActiveTargetId: [_location GHlocation_id]];
        [[AppState sharedInstance] save];
        
        CompassViewController *compass = [[CompassViewController alloc] init];
        [self.navigationController pushViewController:compass animated:YES];
        
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    switch (indexPath.row) {
        case 0:
        {
            
        }
            break;
        case 1:
        {
            
        }
            break;
        case 2:
        {
            
        }
            break;

            
        default:
            break;
    }
    
    return cell;
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
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - Actions

- (void)onMapButton
{
    MapViewController *mvc = [[MapViewController alloc] init];
    mvc.waypoints = [NSArray arrayWithObject:self.location];
    mvc.singleLocation = YES;
    mvc.title = [_location GHname];
    [self.navigationController pushViewController:mvc animated:YES];
}

- (void)onBackButton
{
    [self.navigationController popViewControllerAnimated:TRUE];
}



@end
