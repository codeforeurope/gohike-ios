//
//  SettingsViewController.m
//  GoHikeAmsterdam
//
//  Created by Giovanni on 9/10/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "SettingsViewController.h"
#import <FacebookSDK/FacebookSDK.h>
#import <QuartzCore/QuartzCore.h>
#import "SSKeychain.h"
#import "SVProgressHUD.h"

@interface SettingsViewController ()
{
    NSArray *footers;
    NSArray *headers;
    
    BOOL isFacebookLoggedIn;
    NSString* facebookUsername;
}

@end

@implementation SettingsViewController

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
 
    //Styling
    UIView *tablebgView = [[[NSBundle mainBundle] loadNibNamed:@"TableBackground" owner:self options:nil] objectAtIndex:0];
    [self.tableView setBackgroundView:tablebgView];
    self.title = NSLocalizedString(@"settings_title", @"Settings");
    
    footers = @[NSLocalizedString(@"footer_cache_settings", @"Inform user they can delete data by pressing button"),
                         NSLocalizedString(@"footer_social_settings", @"Inform the user they can disconnect from Facebook")];

    headers = @[NSLocalizedString(@"header_cache_settings", @"Cache Settings"), NSLocalizedString(@"header_social_settings", @"Social Network Settings")];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
//    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonTapped:)];
    self.navigationItem.rightBarButtonItem = doneButton;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self checkFacebookStatus];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)checkFacebookStatus
{
    isFacebookLoggedIn = (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded || FBSession.activeSession.state == FBSessionStateOpen);
    facebookUsername = [SSKeychain passwordForService:kServiceNameForKeychain account:kAccountNameForKeychainFacebook];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return 2;
            break;
        default:
            return 0;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    
    return [headers objectAtIndex:section];

}

- (NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    return [footers objectAtIndex:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    switch (indexPath.section) {
        case 0:
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"A"];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            cell.backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
            
            
            UIButton *clearCacheButton = [self makeButtonForCell:cell];
            [clearCacheButton setTitle:NSLocalizedString(@"settings_clear_data", @"Clear downloaded data") forState:UIControlStateNormal];
            [clearCacheButton addTarget:self action:@selector(clearCacheButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:clearCacheButton];
        }
            break;
        case 1:
        {

            switch (indexPath.row) {
                case 0:
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"B"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    if (isFacebookLoggedIn) {
                        cell.textLabel.text = facebookUsername;
                    }
                    else{
                        cell.detailTextLabel.text = NSLocalizedString(@"settings_not_connected", @"Not linked with Facebook");
                    }
                }
                    break;
                case 1:
                {
                    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"C"];
                    cell.selectionStyle = UITableViewCellSelectionStyleNone;
                    cell.backgroundColor = [UIColor clearColor];

                    //logout
                    UIButton *logoutButton = [self makeButtonForCell:cell];
                    [logoutButton setTitle:NSLocalizedString(@"settings_unlink", @"Unlink") forState:UIControlStateNormal];
                    if(isFacebookLoggedIn){
                        [logoutButton setEnabled:YES];
                    }
                    else{
                        [logoutButton setEnabled:NO];
                    }
                    [logoutButton addTarget:self action:@selector(logoutButtonWasPressed:) forControlEvents:UIControlEventTouchUpInside];
                    [cell addSubview:logoutButton];
                }
                    break;  
                default:
                    break;
            }

        }
            break;
        default:
            break;
    }
    
    return cell;
}

- (UIButton*)makeButtonForCell:(UITableViewCell*)cell
{
    //button with gradient
    UIButton *startHikeCellButton = [UIButton buttonWithType:UIButtonTypeCustom];
    startHikeCellButton.frame = cell.contentView.frame;
    [startHikeCellButton setFrame:CGRectMake(0, 0, cell.contentView.bounds.size.width-20, 44)];
    [startHikeCellButton setCenter:cell.center];
    
    
    // Draw a custom gradient
    UIColor *color = [Utilities appColor];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = startHikeCellButton.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[color colorWithAlphaComponent:0.9].CGColor,
                       (id)[color colorWithAlphaComponent:1.0].CGColor,
                       nil];
    [startHikeCellButton.layer insertSublayer:gradient atIndex:0];
    startHikeCellButton.layer.cornerRadius = 6;
    startHikeCellButton.layer.masksToBounds = YES;
    
    [startHikeCellButton.titleLabel setAdjustsFontSizeToFitWidth:YES];
    
    return startHikeCellButton;
}

- (void)doneButtonTapped:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - button actions

- (void)logoutButtonWasPressed:(id)sender
{
    //close the FBSession
    [FBSession.activeSession closeAndClearTokenInformation];
    //Remove the data we stored (the name of user)
    [SSKeychain setPassword:nil forService:kServiceNameForKeychain account:kAccountNameForKeychainFacebook];
    //refresh the status of facebook in this view
    [self checkFacebookStatus];
    //reload the tableview
    [self.tableView reloadData];
}

- (void)clearCacheButtonTapped:(id)sender
{
    NSLog(@"Clear cache button tapped");
    [SVProgressHUD show];
//    //delete all data in cache folder
    [Utilities clearDownloadedData];
    [SVProgressHUD showSuccessWithStatus:nil];
}

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

@end
