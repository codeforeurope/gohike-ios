//
//  RouteStartViewController.m
//  ScavengerApp
//
//  Created by Giovanni Maggini on 5/15/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "RouteStartViewController.h"
#import "CompassViewController.h"
#import "LocationDetailViewController.h"
#import "RouteDetailTitleCell.h"
#import "RewardViewController.h"
#import "CustomBarButtonViewLeft.h"
#import "CustomBarButtonViewRight.h"
#import "SIAlertView.h"
#import "UIImageView+AFNetworking.h"
#import "SVProgressHUD.h"

#import <QuartzCore/QuartzCore.h>

#define download_warning_alertview_tag 100

#define BUTTON_HEIGHT 32
#define BUTTON_WIDTH 200

@interface RouteStartViewController ()

//@property (nonatomic, strong) NSArray *checkins;

@property (nonatomic, assign) BOOL routeComplete;

@property (nonatomic, strong) UIImage *routeProfileImage;

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
        
//    UIView *tablebgView = [[[NSBundle mainBundle] loadNibNamed:@"TableBackground" owner:self options:nil] objectAtIndex:0];
//    [self.tableView setBackgroundView:tablebgView];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"viewbackground"]];

    [self updateNavigationButtons];
    
    UIColor *blueColor = [UIColor colorWithRed:0.386 green:0.720 blue:0.834 alpha:1.000];
    [[SIAlertView appearance] setMessageFont:[UIFont systemFontOfSize:14]];
    [[SIAlertView appearance] setTitleColor:blueColor];
    [[SIAlertView appearance] setMessageColor:blueColor];
    [[SIAlertView appearance] setCornerRadius:12];
    [[SIAlertView appearance] setShadowRadius:20];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    
    if(showRewardOnAppear)
    {
        [self viewReward];
        showRewardOnAppear = FALSE;
        return;
    }
    
    [self updateNavigationButtons];
    
    //update the table so that the "Go Hike" button won't be displayed
    [self.tableView reloadData];
}

- (void)updateNavigationButtons
{
    //change back button
    CustomBarButtonViewLeft *backButton = [[CustomBarButtonViewLeft alloc] initWithFrame:CGRectMake(0, 0, 32, 32)
                                                                               imageName:@"icon-back"
                                                                                    text:NSLocalizedString(@"Back", nil)
                                                                                  target:self
                                                                                  action:@selector(onBackButton)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    //set the right button to lead to compass or reward
    NSDictionary *nextWaypoint = [[AppState sharedInstance] nextCheckinForRoute:[[_route objectForKey:@"id"] intValue]];
    if (nextWaypoint)
    {
        // Route is not complete, put "go hike" button
        CustomBarButtonViewRight *goHikeButton = [[CustomBarButtonViewRight alloc] initWithFrame:CGRectMake(0, 0, 100, 32)
                                                                             imageName:@"icon-compass"
                                                                              text:NSLocalizedString(@"Go Hike!", nil)
                                                                                target:self
                                                                                          action:@selector(onGoHikeButton:)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:goHikeButton];
        
    }
    else
    {
        // Route is complete, put reward button
        _routeComplete = YES;

        CustomBarButtonViewRight *showTrophyButton = [[CustomBarButtonViewRight alloc] initWithFrame:CGRectMake(0, 0, 140, 32)
                                                                             imageName:@"icon-trophy"
                                                                              text:NSLocalizedString(@"View Reward", nil)
                                                                                target:self
                                                                                action:@selector(onViewRewardButton)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:showTrophyButton];
    }
    
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
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows;
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            rows = 1;
            break;
        case 1:
        {
            if(_routeComplete == YES)
                rows = 0;
            else
                rows = 1;
        }
        break;
        default:
            rows = [[_route GHwaypoints] count];
            break;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
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
            
            NSString *imageUrl = [[_route objectForKey:@"image"] objectForKey:@"url"];
            [cell.routeImage setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"no-picture"]];
            cell.routeTitleLabel.text = [_route GHname]; //[Utilities getTranslatedStringForKey:@"name" fromDictionary:_route];
            cell.routeHighlightsLabel.text = [_route GHname]; //[Utilities getTranslatedStringForKey:@"description" fromDictionary:_route];
            
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
            cell.selectionStyle = UITableViewCellEditingStyleNone;
            cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];

            
            //button with gradient
            UIButton *startHikeCellButton = [UIButton buttonWithType:UIButtonTypeCustom];
            startHikeCellButton.frame = cell.contentView.frame;
            [startHikeCellButton setFrame:CGRectMake(0, 0, cell.bounds.size.width-20, 44)];

            
//            checkinButton.titleLabel.text = NSLocalizedString(@"Go Hike!", nil);
            // Draw a custom gradient
            UIColor *blueColor = [UIColor colorWithRed:0.386 green:0.720 blue:0.834 alpha:1.000];
            CAGradientLayer *gradient = [CAGradientLayer layer];
            gradient.frame = startHikeCellButton.bounds;
            gradient.colors = [NSArray arrayWithObjects:(id)[blueColor colorWithAlphaComponent:0.9].CGColor,
                               (id)[blueColor colorWithAlphaComponent:1.0].CGColor,
                               nil];
            [startHikeCellButton.layer insertSublayer:gradient atIndex:0];
            startHikeCellButton.layer.cornerRadius = 6;
            startHikeCellButton.layer.masksToBounds = YES;
            if([_route GHwaypoints]){
                [startHikeCellButton setTitle:NSLocalizedString(@"Go Hike!", @"Go Hike!") forState:UIControlStateNormal];
            }
            else{
                [startHikeCellButton setTitle:NSLocalizedString(@"Download this route!", @"Download this route!") forState:UIControlStateNormal];
            }
            [startHikeCellButton addTarget:self action:@selector(onGoHikeButton:) forControlEvents:UIControlEventTouchUpInside];
            
            
            startHikeCellButton.layer.shadowColor = [UIColor blackColor].CGColor;
            startHikeCellButton.layer.shadowOffset = CGSizeMake(0, 1);
            startHikeCellButton.layer.shadowOpacity = 0.8;
            startHikeCellButton.layer.shadowRadius = 0.9;
            startHikeCellButton.clipsToBounds = NO;
            
            [cell.contentView addSubview:startHikeCellButton];
            
            return cell;


        }
            break;
        case 2:
        {
            static NSString *CellIdentifier = @"Cell";
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
            }
                       
            NSDictionary *waypoint = [[[AppState sharedInstance] waypointsWithCheckinsForRoute:[[_route objectForKey:@"id"] integerValue]] objectAtIndex:indexPath.row];
            
            if([[waypoint objectForKey:@"visited"] boolValue] == YES) {
                //Means that the player checked in already
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.imageView.image = [UIImage imageNamed:@"target-checked"];
            }
            else{
                cell.imageView.image = [UIImage imageNamed:@"target"];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }

            NSDictionary *wpNameLocales = [waypoint objectForKey:@"name"];


            cell.textLabel.text = [Utilities getStringForCurrentLocaleFromDictionary:wpNameLocales];
            [cell setSelectionStyle:UITableViewCellSelectionStyleGray];
            
            return cell;
        }
            break;
        default:
            break;
    }
    return  nil;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section ==2){
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0];
    }
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 320;
    }
    else {
        return [super tableView:tableView heightForRowAtIndexPath:indexPath];
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.section == 2)
    {
        NSDictionary *waypoint = [[[AppState sharedInstance] waypointsWithCheckinsForRoute:[[_route objectForKey:@"id"] integerValue]] objectAtIndex:indexPath.row];
        if([[waypoint objectForKey:@"visited"] boolValue] == YES) {
            //Means that the player checked in already
            LocationDetailViewController *lvc = [[LocationDetailViewController alloc] initWithNibName:@"LocationDetailViewController" bundle:nil];
            lvc.location = waypoint;
            [self.navigationController pushViewController:lvc animated:YES];
        }
        else{
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"RouteAlertViewTitle", nil) andMessage:NSLocalizedString(@"RouteAlertViewMessage", nil)];
            [alertView addButtonWithTitle:NSLocalizedString(@"RouteAlertViewNo",nil)
                                     type:SIAlertViewButtonTypeCancel
                                  handler:^(SIAlertView *alertView) {
                                  }];
            [alertView addButtonWithTitle:NSLocalizedString(@"RouteAlertViewYes", nil)
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alertView) {
                                    [alertView dismissAnimated:NO];
                                    [self startRoute];
                                  }];
            alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
            alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
            alertView.didDismissHandler = ^(SIAlertView *alertView) {
            };
            [alertView show];
        }
    }
   
}

#pragma mark - Actions

- (void)startRoute
{

    if([_route GHwaypoints]){ //The presence of waypoints is a guarantee that we have the full route, not only the one from catalog
        
        NSDictionary *nextWaypoint = [[AppState sharedInstance] nextCheckinForRoute:[[_route objectForKey:@"id"] intValue]];
        
        if(nextWaypoint)
        {
            [[AppState sharedInstance] setActiveRouteId: [[nextWaypoint objectForKey:@"route_id"] intValue]];
            [[AppState sharedInstance] setActiveTargetId:[[nextWaypoint objectForKey:@"location_id"] intValue]];
            [[AppState sharedInstance] save];
#if DEBUG
            NSLog(@"Active Target ID = %d",[[AppState sharedInstance] activeTargetId]);
#endif
            CompassViewController *compass = [[CompassViewController alloc] init];
            compass.delegate = self;
            [self.navigationController pushViewController:compass animated:YES];
        }
        else
        {
            @throw [NSException exceptionWithName:@"no waypoint" reason:@"no waypoints found/left on route" userInfo:nil];
        }
    }
    else{
        double size = [[_route objectForKey:@"size"] doubleValue] /1024;
        UIAlertView *alertView =  [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Heads up!", @"Heads up!") message:[NSString stringWithFormat:NSLocalizedString(@"You are about to download %.0f Kb of data, is that ok?", @"You are about to download %f bytes of data, ok?"),size ] delegate:self cancelButtonTitle:NSLocalizedString(@"No", @"No")otherButtonTitles:NSLocalizedString(@"Go ahead", @"Go ahead"), nil];
        [alertView setTag:download_warning_alertview_tag];
        [alertView show];
    }
        

}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == download_warning_alertview_tag && buttonIndex == 1){
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRouteDownloaded:) name:kFinishedLoadingRoute object:nil];
        [SVProgressHUD showWithStatus:NSLocalizedString(@"Downloading route", @"Downloading route") maskType:SVProgressHUDMaskTypeBlack];
        [[GoHikeHTTPClient sharedClient] downloadRoute:[[[[AppState sharedInstance] currentRoute] objectForKey:@"id"] integerValue]];
    }
}

- (void)handleRouteDownloaded:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFinishedLoadingRoute object:nil];
    if([[notification userInfo] objectForKey:@"error"])
    {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Download error", @"Download error")];
    }
    else{
        [SVProgressHUD showSuccessWithStatus:nil];
        _route = [[notification userInfo] objectForKey:@"route"];
    }

    [self.tableView reloadData];

}

- (void)viewReward
{
    RewardViewController *rvc = [[RewardViewController alloc] initWithNibName:@"RewardViewController" bundle:nil];
    rvc.reward = [_route objectForKey:@"reward"];
    [self.navigationController pushViewController:rvc animated:YES];
}

#pragma mark - CustomButtonHandlers
- (void)onBackButton
{
    [self.navigationController popViewControllerAnimated:true];
}

- (void)onGoHikeButton:(id)sender
{
    if([sender isKindOfClass:[UIButton class]])
    {
        UIButton *b = (UIButton*)sender;
        b.layer.shadowColor = [UIColor blackColor].CGColor;
        b.layer.shadowOffset = CGSizeMake(0, 0);
        b.layer.shadowOpacity = 0;
        b.layer.shadowRadius = 0;
        b.clipsToBounds = NO;
    }
    [self startRoute];
}

- (void)onViewRewardButton
{
    [self viewReward];
}

#pragma mark - CompassViewControllerDelegate

- (void)onRouteFinished
{
    //TODO: check if it's called
    [TestFlight passCheckpoint:@"UserHasFinishedRoute"];
    showRewardOnAppear = TRUE;
}


@end
