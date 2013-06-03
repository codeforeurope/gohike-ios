//
//  RouteStartViewController.m
//  ScavengerApp
//
//  Created by Giovanni on 5/15/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "RouteStartViewController.h"

#import "CompassViewController.h"

#import "LocationDetailViewController.h"

#import "RouteDetailTitleCell.h"

#import "RewardViewController.h"

#import "CustomBarButtonView.h"

@interface RouteStartViewController ()

//@property (nonatomic, strong) NSArray *checkins;

@property (nonatomic, assign) BOOL routeComplete;

@end

@implementation RouteStartViewController

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
        
    UIView *tablebgView = [[[NSBundle mainBundle] loadNibNamed:@"TableBackground" owner:self options:nil] objectAtIndex:0];
    [self.tableView setBackgroundView:tablebgView];
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated
{
    //change back button
    CustomBarButtonView *backButton = [[CustomBarButtonView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)
                                                                       imageName:@"icon-back"
                                                                            text:@"Back"
                                                                          target:self
                                                                          action:@selector(onBackButton)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    //set the right button to lead to compass or reward
    NSDictionary *nextWaypoint = [[AppState sharedInstance] nextCheckinForRoute:[[_route objectForKey:@"id"] intValue]];
    if (nextWaypoint)
    {
        // Route is not complete, put "go hike" button
        CustomBarButtonView *goHikeButton = [[CustomBarButtonView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)
                                                                             imageName:@"icon-compass"
                                                                                  text:nil
                                                                                target:self
                                                                                action:@selector(onGoHikeButton)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:goHikeButton];
       
    }
    else
    {
        // Route is complete, put reward button
        CustomBarButtonView *goHikeButton = [[CustomBarButtonView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)
                                                                             imageName:@"icon-trophy"
                                                                                  text:nil
                                                                                target:self
                                                                                action:@selector(onViewRewardButton)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:goHikeButton];
    }
    
    //update the table
    [self.tableView reloadData];
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
            number = 1;
            break;
        default:
            number = [[_route objectForKey:@"waypoints"] count];
            break;
    }
    return number;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
   
    NSString *langKey = [[AppState sharedInstance] language];
    switch (indexPath.section) {
        case 0:
        {
            static NSString *CellIdentifier = @"GHRouteDetailTitleCell";
            RouteDetailTitleCell  *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"RouteDetailTitleCell" owner:self options:nil];
                cell = [nib objectAtIndex:0];
            }
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            
            cell.routeImage.image = [UIImage imageWithData:[NSData dataWithBase64EncodedString:[_route objectForKey:@"image_data"]]];
            cell.routeTitleLabel.text = [_route objectForKey:[NSString stringWithFormat:@"name_%@",langKey]];
            
            return cell;
        }
            break;
        case 1:
        {
            static NSString *CellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
                       
            NSDictionary *waypoint = [[[AppState sharedInstance] waypointsWithCheckinsForRoute:[[_route objectForKey:@"id"] integerValue]] objectAtIndex:indexPath.row];
            NSLog(@"cell wp %@",waypoint);
            
            if([[waypoint objectForKey:@"visited"] boolValue] == YES) {
                //Means that the player checked in already
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.imageView.image = [UIImage imageNamed:@"target-checked"];
            }
            else{
                cell.imageView.image = [UIImage imageNamed:@"target"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.textLabel.text = [waypoint objectForKey:[NSString stringWithFormat:@"name_%@",langKey]];
            return cell;
        }
            break;
        default:
            break;
    }
    return  [[UITableViewCell alloc] init]; //fix compiler warning
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section ==1){
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 289;
    }
    else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}


//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    NSString *retString;
//    switch (section) {
//        case 0:
//            retString =  NSLocalizedString(@"Route Information", nil);
//            break;
//        case 1:
//            retString =  NSLocalizedString(@"Locations in Route", nil);
//            break;
//        default:
//            break;
//    }
//    
//    return retString;
//}

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
    if(indexPath.section == 1)
    {
        NSDictionary *waypoint = [[[AppState sharedInstance] waypointsWithCheckinsForRoute:[[_route objectForKey:@"id"] integerValue]] objectAtIndex:indexPath.row];
        if([[waypoint objectForKey:@"visited"] boolValue] == YES) {
            //Means that the player checked in already
            LocationDetailViewController *lvc = [[LocationDetailViewController alloc] initWithNibName:@"LocationDetailViewController" bundle:nil];
            lvc.location = waypoint;
            [self.navigationController pushViewController:lvc animated:YES];
        }
        else{
            
        }
   
    }
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     DetailViewController *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - Actions

- (void)startRoute
{
    NSDictionary *nextWaypoint = [[AppState sharedInstance] nextCheckinForRoute:[[_route objectForKey:@"id"] intValue]];
    
    if(nextWaypoint)
    {
        [[AppState sharedInstance] setActiveRouteId: [[nextWaypoint objectForKey:@"route_id"] intValue]];
        [[AppState sharedInstance] setActiveTargetId:[[nextWaypoint objectForKey:@"location_id"] intValue]];
        [[AppState sharedInstance] save];
        
        NSLog(@"Active Target ID = %d",[[AppState sharedInstance] activeTargetId]);
        
        CompassViewController *compass = [[CompassViewController alloc] init];
        compass.delegate = self;
        [self.navigationController pushViewController:compass animated:YES];
    }
    else
    {
        @throw [NSException exceptionWithName:@"no waypoint" reason:@"no waypoints found/left on route" userInfo:nil];
    }
    
//    if([waypoints count] > 0)
//    {
//        NSDictionary *waypoint = [waypoints objectAtIndex:0];
//        [[AppState sharedInstance] setActiveRouteId: [[waypoint objectForKey:@"route_id"] intValue]];
//        [[AppState sharedInstance] setActiveTargetId:[[waypoint objectForKey:@"location_id"] intValue]];
//        [[AppState sharedInstance] save];
//        
//        NSLog(@"Active Target ID = %d",[[AppState sharedInstance] activeTargetId]);
//        
//        CompassViewController *compass = [[CompassViewController alloc] init];
//        [self.navigationController pushViewController:compass animated:YES];
//        
//    }
    
//    [[AppState sharedInstance] setActiveRoute:_currentRoute];
//    Location *target = [_currentRoute.locations objectAtIndex:0]; //this is OK only if we start from first location
//    [[AppState sharedInstance] setActiveTarget:target];
//    [[AppState sharedInstance] setActiveTargetId:target.locationId];
//    [[AppState sharedInstance] setPlayerIsInCompass:YES];
    
//    CompassViewController *compass = [[CompassViewController alloc] init];
//    [self.navigationController pushViewController:compass animated:YES];
    
}


- (void)viewReward
{
    //TODO: finish the display of the reward!
    RewardViewController *rvc = [[RewardViewController alloc] initWithNibName:@"RewardViewController" bundle:nil];
    [self.navigationController pushViewController:rvc animated:YES];
}

#pragma mark - CustomButtonHandlers
- (void)onBackButton
{
    [self.navigationController popViewControllerAnimated:true];
}

- (void)onMapButton
{
    NSLog(@"show map");
}

- (void)onGoHikeButton
{
    [self startRoute];
}

- (void)onViewRewardButton
{
    [self viewReward];
}

#pragma mark - CompassViewControllerDelegate

- (void)onRouteFinished
{
    [self viewReward];    
}


@end
