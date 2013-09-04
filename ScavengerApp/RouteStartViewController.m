//
//  RouteStartViewController.m
//  ScavengerApp
//
//  Created by Giovanni Maggini on 5/15/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "RouteStartViewController.h"
#import "CompassViewController.h"
#import "LocationDetailTableViewController.h"
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

@interface RouteStartViewController () <FBLoginViewDelegate>

{
    int receivedFileNotifications;
    int expectedNotifications;
    BOOL isFacebookLoggedIn;
    BOOL routeComplete;
}

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
    
    //set some variables useful for managing the view
    [self refresh];
    
    //Styling
    UIView *tablebgView = [[[NSBundle mainBundle] loadNibNamed:@"TableBackground" owner:self options:nil] objectAtIndex:0];
    [self.tableView setBackgroundView:tablebgView];
    [self updateNavigationButtons];

}

- (void)viewDidAppear:(BOOL)animated
{
    [self refresh];

    
    if(showRewardOnAppear)
    {
        [self viewReward];
        showRewardOnAppear = FALSE;
        return;
    }
    
    [self updateNavigationButtons];
    
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
//    NSDictionary *nextWaypoint = [[AppState sharedInstance] nextCheckinForRoute:[[_route objectForKey:@"id"] intValue]];
    if (!routeComplete)
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

- (void)refresh
{
    //first check if route is complete and Facebook logged in
    routeComplete = [[AppState sharedInstance] isRouteFinished:[[AppState sharedInstance] currentRoute]];
    isFacebookLoggedIn = (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded || FBSession.activeSession.state == FBSessionStateOpen);
    
    //update UI accordingly to the new values
    [self updateNavigationButtons];
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rows = 0;
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            rows = 1;
            break;
        case 1:
        {
            if(routeComplete == YES)
                rows = 0;
            else
                rows = 1;
        }
        break;
        default:
            rows = [[[[AppState sharedInstance] currentRoute] GHwaypoints] count];
            break;
    }
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GHRoute *route = [[AppState sharedInstance] currentRoute];

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
            
//            NSString *imageUrl = [[_route objectForKey:@"image"] objectForKey:@"url"];
//            [cell.routeImage setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"no-picture"]];
            cell.routeImage.image = [UIImage imageWithData:[FileUtilities imageDataForRoute:route]];
            cell.routeTitleLabel.text = [route GHname];
            cell.routeHighlightsLabel.text = [route GHdescription];
            
            return cell;
        }
            break;
        case 1:
        {
//            static NSString *CellIdentifier = @"ButtonCell";
//            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//            if (cell == nil) {
//                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
//            }
            UITableViewCell *cell = cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ButtonCell"];
            cell.selectionStyle = UITableViewCellEditingStyleNone;
            cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];

            
            //button with gradient
            UIButton *startHikeCellButton = [UIButton buttonWithType:UIButtonTypeCustom];
            startHikeCellButton.frame = cell.contentView.frame;
            [startHikeCellButton setFrame:CGRectMake(0, 0, cell.contentView.bounds.size.width-20, 44)];
            [startHikeCellButton setCenter:cell.center];
//            UIColor *blueColor = [UIColor colorWithRed:0.386 green:0.720 blue:0.834 alpha:1.000];
//            [startHikeCellButton setBackgroundColor:blueColor];


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
            
            [startHikeCellButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
            if([route GHwaypoints]){
                if([[route objectForKey:@"update_available"] boolValue] == YES)
                {
                    [startHikeCellButton setTitle:NSLocalizedString(@"Update Available!", @"Update Available!") forState:UIControlStateNormal];
                }
                else{
                    [startHikeCellButton setTitle:NSLocalizedString(@"Go Hike!", @"Go Hike!") forState:UIControlStateNormal];
                }
            }
            else{
                // See if the app has a valid token for the current state.
                if (isFacebookLoggedIn == YES) {
                    // To-do, show logged in view
                    [startHikeCellButton setTitle:NSLocalizedString(@"Download this route!", @"Download this route!") forState:UIControlStateNormal];
                } else {
                    // No, display the login page.
                    [startHikeCellButton setTitle:NSLocalizedString(@"Login to Facebook to Download!", @"Login to Facebook to Download!") forState:UIControlStateNormal];
                }
            }
            [startHikeCellButton addTarget:self action:@selector(onGoHikeButton:) forControlEvents:UIControlEventTouchUpInside];
            
            
//            startHikeCellButton.layer.shadowColor = [UIColor blackColor].CGColor;
//            startHikeCellButton.layer.shadowOffset = CGSizeMake(0, 1);
//            startHikeCellButton.layer.shadowOpacity = 0.8;
//            startHikeCellButton.layer.shadowRadius = 0.9;
//            startHikeCellButton.clipsToBounds = NO;
//            startHikeCellButton.layer.shadowPath =
//            [UIBezierPath bezierPathWithRect:startHikeCellButton.layer.bounds].CGPath;
            
            [cell addSubview:startHikeCellButton];
            
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
                       
            NSDictionary *waypoint = [[[AppState sharedInstance] waypointsWithCheckinsForRoute:[[route objectForKey:@"id"] integerValue]] objectAtIndex:indexPath.row];
            
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
    GHRoute *route = [[AppState sharedInstance] currentRoute];

    if(indexPath.section == 2)
    {
        GHWaypoint *waypoint = [[[AppState sharedInstance] waypointsWithCheckinsForRoute:[[route objectForKey:@"id"] integerValue]] objectAtIndex:indexPath.row];
        if([[waypoint objectForKey:@"visited"] boolValue] == YES) {
            //Means that the player checked in already
            UIImage *image = [UIImage imageWithData:[FileUtilities imageDataForWaypoint:waypoint]];
            LocationDetailTableViewController *lvc = [[LocationDetailTableViewController alloc] initWithImage:image ];
            lvc.location = waypoint;
            [self.navigationController pushViewController:lvc animated:YES];
        }
        else{
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"RouteAlertViewTitle", @"Not found yet!") andMessage:NSLocalizedString(@"RouteAlertViewMessage", @"Go Hike now?")];
            [alertView addButtonWithTitle:NSLocalizedString(@"RouteAlertViewNo",@"Later")
                                     type:SIAlertViewButtonTypeCancel
                                  handler:^(SIAlertView *alertView) {
                                  }];
            [alertView addButtonWithTitle:NSLocalizedString(@"RouteAlertViewYes", @"Yes!")
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alertView) {
                                    [alertView dismissAnimated:NO];
                                    [self startRouteWithWaypoint:waypoint];
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

- (void)startButtonTapped
{

    GHRoute *route = [[AppState sharedInstance] currentRoute];

    if([route GHwaypoints]){ //The presence of waypoints is a guarantee that we have the full route, not only the one from catalog
        
        NSDictionary *nextWaypoint = [[AppState sharedInstance] nextCheckinForRoute:[route GHid] startingFromWaypointRank:0];
        
        if(nextWaypoint)
        {
            
            if([[route objectForKey:@"update_available"] boolValue] == YES)
            {
                //there is an update, first we prompt the user to download it!
                SIAlertView *a = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"New content available!", @"New content available!") andMessage:NSLocalizedString(@"There is new content available for this route. Download it now?", @"There is new content available for this route. Download it now?")];
                [a addButtonWithTitle:NSLocalizedString(@"Later", nil) type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) { [alertView dismissAnimated:YES];
                    [self startRouteWithWaypoint:nextWaypoint];
                }];
                [a addButtonWithTitle:NSLocalizedString(@"Yes!", nil) type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) { [self downloadRoute];  }];
                a.transitionStyle = SIAlertViewTransitionStyleBounce;
                a.backgroundStyle = SIAlertViewBackgroundStyleSolid;
                [a show];
            }
            else{
                [self startRouteWithWaypoint:nextWaypoint];
            }
        }
        else
        {
            @throw [NSException exceptionWithName:@"no waypoint" reason:@"no waypoints found/left on route" userInfo:nil];
        }
    }
    else{
        // See if the app has a valid token for the current state.
        if (isFacebookLoggedIn) {
            // To-do, show logged in view
            double size = [[route objectForKey:@"size"] doubleValue] /1024;
            if(size > 0){
            SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Heads up!", @"Heads up!") andMessage:[NSString stringWithFormat:NSLocalizedString(@"You are about to download %.0f Kb of data, is that ok?", @"You are about to download %f bytes of data, ok?"),size ]];
            [alertView addButtonWithTitle:NSLocalizedString(@"RouteAlertViewNo",@"Later")
                                     type:SIAlertViewButtonTypeCancel
                                  handler:^(SIAlertView *alertView) {
                                  }];
            [alertView addButtonWithTitle:NSLocalizedString(@"RouteAlertViewYes", @"Yes!")
                                     type:SIAlertViewButtonTypeDefault
                                  handler:^(SIAlertView *alertView) {
                                      [alertView dismissAnimated:NO];
                                      [self downloadRoute];
                                  }];
            alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
            alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
            alertView.didDismissHandler = ^(SIAlertView *alertView) {
            };
            [alertView show];
            }
            else{
                //if size is 0, makes no sense to display the confirmation
                [self downloadRoute];
            }

        } else {
            // No, display the login page.
            [self openSession];
        }
    }

}

- (void)startRouteWithWaypoint:(GHWaypoint*)nextWaypoint
{
    [[AppState sharedInstance] setActiveRouteId: [[nextWaypoint objectForKey:@"route_id"] intValue]];
    [[AppState sharedInstance] setActiveTargetId:[[nextWaypoint objectForKey:@"location_id"] intValue]];
    [[AppState sharedInstance] save];
#if DEBUG
    NSLog(@"Active Target ID = %d",[[AppState sharedInstance] activeTargetId]);
#endif
    CompassViewController *compass = [[CompassViewController alloc] initWithNibName:@"CompassViewController" bundle:nil];
    compass.delegate = self;
    [self.navigationController pushViewController:compass animated:YES];
}


- (void)downloadRoute
{
    GHRoute *route = [[AppState sharedInstance] currentRoute];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleRouteDownloaded:) name:kFinishedLoadingRoute object:nil];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Downloading route", @"Downloading route") maskType:SVProgressHUDMaskTypeBlack];
    [[GoHikeHTTPClient sharedClient] getRoute:[route GHid]];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(alertView.tag == download_warning_alertview_tag && buttonIndex == 1){
        [self downloadRoute];
    }
}

- (void)viewReward
{
    GHRoute *route = [[AppState sharedInstance] currentRoute];

    RewardViewController *rvc = [[RewardViewController alloc] initWithNibName:@"RewardViewController" bundle:nil];
    rvc.reward = [route GHreward];
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
        b.layer.shouldRasterize  = YES;
        b.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        b.layer.shadowPath = [UIBezierPath bezierPathWithRect:b.layer.bounds].CGPath;
    }
    [self startButtonTapped];
}

- (void)onViewRewardButton
{
    [self viewReward];
}

#pragma mark - CompassViewControllerDelegate

- (void)onRouteFinished
{
    //This is called when user exists from the route screen
    [TestFlight passCheckpoint:@"UserHasFinishedRoute"];
    showRewardOnAppear = TRUE;
}

#pragma mark - Notification handlers

- (void)handleRouteDownloaded:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFinishedLoadingRoute object:nil];
    if([[notification userInfo] objectForKey:@"error"])
    {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Download error", @"Download error")];
    }
    else{
        
        if([[[notification userInfo] objectForKey:@"expectedFiles"] integerValue] > 0)
        {
            [SVProgressHUD showProgress:10.0/100 status:NSLocalizedString(@"Updating pictures", @"Updating pictures") maskType:SVProgressHUDMaskTypeBlack];
            receivedFileNotifications = 0;
            expectedNotifications = [[[notification userInfo] objectForKey:@"expectedFiles"] integerValue];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDownloadFileCompleted:) name:kFinishedDownloadingFile object:nil];
        }
        else{
            [SVProgressHUD showSuccessWithStatus:nil];
            
            [self downloadFinished];
        }
    }
}

- (void)handleDownloadFileCompleted:(NSNotification*)notification
{
    receivedFileNotifications+=1;
    NSLog(@"received file %@", [[notification userInfo] objectForKey:@"file"]);
    if(receivedFileNotifications >= expectedNotifications)
    {
        [SVProgressHUD showProgress:100/100 status:NSLocalizedString(@"Updating pictures", @"Updating pictures") maskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showSuccessWithStatus:@""];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kFinishedDownloadingFile object:nil];
        
        [self downloadFinished];
    }
    else
    {
        [SVProgressHUD showProgress:((receivedFileNotifications*100.0)/expectedNotifications)/100.0+(10.0/100) status:NSLocalizedString(@"Updating pictures", @"Updating pictures") maskType:SVProgressHUDMaskTypeBlack];
    }
}

- (void)downloadFinished
{
    [self refresh];
    [self.tableView reloadData];
}

#pragma mark - Facebook

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen: {
            NSLog(@"facebook session open");
            isFacebookLoggedIn = YES;
            [self getUserDetails];
            
        }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            isFacebookLoggedIn = NO;
            [FBSession.activeSession closeAndClearTokenInformation];

            break;
        default:
            break;
    }
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:NSLocalizedString(@"Facebook Error", @"Facebook Error")
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}


- (void)getUserDetails
{
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary<FBGraphUser> *user,
           NSError *error) {
             if (!error) {
#if DEBUG
                 NSLog(@"we got user: %@", user);
#endif
                 @try {
                     NSString *username = user.first_name;
                     NSString *FBid = [NSString stringWithFormat:@"%@", user.id];
                     NSString *email = [user objectForKey:@"email"];
                     NSDate *expirationDate = FBSession.activeSession.accessTokenData.expirationDate;
                     NSString *token = FBSession.activeSession.accessTokenData.accessToken;
                     
                    [[GoHikeHTTPClient sharedClient] connectFBId:FBid name:username email:email token:token expDate:expirationDate];
                 }
                 @catch (NSException *exception) {
                     NSLog(@"%@", [exception description]);
                 }
                 @finally {
                     [self refresh];
                 }


             }
         }];
    }
}

- (void)openSession
{
    [FBSession openActiveSessionWithReadPermissions:@[@"email"]
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session,
       FBSessionState state, NSError *error) {
         [self sessionStateChanged:session state:state error:error];
     }];
}

@end
