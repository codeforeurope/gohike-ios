//
//  CatalogViewController.m
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/22/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "CatalogViewController.h"
#import "SelectionCell.h"
#import "UIImageView+AFNetworking.h"
#import "CatalogViewCollectionHeader.h"
#import "RouteStartViewController.h"
#import "SVProgressHUD.h"
#import "CustomBarButtonViewLeft.h"
#import "OverlayView.h"
#import "HelpView.h"
#import "SIAlertView.h"


#define kSELECTION_CELL_IDENTIFIER @"SelectionCell"
#define kSECTION_HEADER_IDENTIFIER @"CatalogViewCollectionHeader"

@interface CatalogViewController ()
{
    int receivedFileNotifications;
    int expectedNotifications;
}

@property (nonatomic, strong) OverlayView *overlayView;

@end

@implementation CatalogViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    //I set the catalog of the file as the app currentCatalog
//    _catalog = [[AppState sharedInstance] currentCatalog];
    
    [_collectionView setBackgroundColor:[UIColor clearColor]];
    [_collectionView setBackgroundView:[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"viewbackground"]]];
    
    //Register cells
    [self.collectionView registerNib:[UINib nibWithNibName:kSELECTION_CELL_IDENTIFIER bundle:nil] forCellWithReuseIdentifier:kSELECTION_CELL_IDENTIFIER];
    [self.collectionView registerNib:[UINib nibWithNibName:kSECTION_HEADER_IDENTIFIER bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kSECTION_HEADER_IDENTIFIER];
    
        
    //buttons
    [self updateNavigationButtons];
    
//Load catalog
    [self loadCatalogForCity:[[AppState sharedInstance] currentCity].GHid];
}

- (void)viewWillAppear:(BOOL)animated
{
    //How to play screen
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"howtoplay_displayed"] == nil) {
        
        [self onHelpButton];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"howtoplay_displayed"];
    }
}

- (void)updateNavigationButtons
{
    CustomBarButtonViewLeft *backButton = [[CustomBarButtonViewLeft alloc] initWithFrame:CGRectMake(0, 0, 32, 32)
                                                                               imageName:@"icon-back"
                                                                                    text:NSLocalizedString(@"Cities", @"Cities")
                                                                                  target:self
                                                                                  action:@selector(onBackButton)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    CustomBarButtonViewLeft *helpButton = [[CustomBarButtonViewLeft alloc] initWithFrame:CGRectMake(0, 0, 32, 32)
                                                                               imageName:@"help2"
                                                                                    text:nil
                                                                                  target:self
                                                                                  action:@selector(onHelpButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:helpButton];
}

- (void)onBackButton
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - CollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [[[AppState sharedInstance] currentCatalog] count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    GHProfile *profile = [[[[AppState sharedInstance] currentCatalog] GHprofiles] objectAtIndex:section];
    return [[profile GHroutes] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GHRoute *route = [[[[[[AppState sharedInstance] currentCatalog] GHprofiles] objectAtIndex:indexPath.section ] GHroutes] objectAtIndex:indexPath.row];
    
    SelectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kSELECTION_CELL_IDENTIFIER forIndexPath:indexPath];
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:kSELECTION_CELL_IDENTIFIER owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }
    
//    cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"cellbackground1"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch]];
//    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"cellbackground2"]  resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch]];
//    cell.backgroundColor = [UIColor redColor];

    
//    [cell.profileImage setImageWithURL:[NSURL URLWithString:[[route GHicon] GHurl]]];
    cell.profileImage.image = [UIImage imageWithData:[FileUtilities iconDataForRoute:route]];
    cell.profileLabel.text = [route GHname];
    cell.bottomLabel.text = @"";
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        CatalogViewCollectionHeader *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kSECTION_HEADER_IDENTIFIER forIndexPath:indexPath];
        if(headerView== nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:kSECTION_HEADER_IDENTIFIER owner:self options:nil];
            headerView = [nib objectAtIndex:0];

        }
//        GHProfile *profile = [GHProfile modelObjectWithDictionary:[_catalog objectAtIndex:indexPath.section]];
        GHProfile *profile = [[[[AppState sharedInstance] currentCatalog] GHprofiles] objectAtIndex:indexPath.section];
        headerView.headerLabel.text = [profile GHname];
//        [headerView.headerImage setImageWithURL:[NSURL URLWithString:profile.image.GHurl]];
        headerView.headerImage.image = [UIImage imageWithData:[FileUtilities imageDataForProfile:profile]];
        headerView.headerBackgroundImage.image  = [[UIImage imageNamed:@"collectionviewheader"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch];
        
        reusableview = headerView;
    }
    
    return reusableview;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    GHProfile *profile = [[[[AppState sharedInstance] currentCatalog] GHprofiles] objectAtIndex:indexPath.section];
    GHRoute *selectedRoute = [[profile GHroutes] objectAtIndex:indexPath.row];
    [AppState sharedInstance].currentRoute = selectedRoute;

    
    GHRoute *existingRoute = [FileUtilities loadRouteFromFileWithId:[selectedRoute GHid]];
    if(existingRoute)
    {
        if([[existingRoute GHpublished_key] isEqualToString:[selectedRoute GHpublished_key]] != YES)
        {
            //the publish keys differ. Means the route in the catalog is more updated than the one we have on the file. Mark the downloaded route as "To Update"
            NSMutableDictionary *d = [existingRoute mutableCopy];
            [d setObject:[NSNumber numberWithBool:YES] forKey:@"update_available"];
            existingRoute = [d copy];
            //TODO: how to persist the fact that we need to update between app restarts? 
        }
        [AppState sharedInstance].currentRoute = existingRoute;
        [[AppState sharedInstance] save];

    }
    
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    RouteStartViewController *rvc = [[RouteStartViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [self.navigationController pushViewController:rvc animated:YES];
    
    
}

#pragma mark - Actions

- (void)loadCatalogForCity:(int)city
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadCatalogCompleted:) name:kFinishedLoadingCatalog object:nil];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Updating routes to play", @"Updating routes to play") maskType:SVProgressHUDMaskTypeBlack];
    [[GoHikeHTTPClient sharedClient] getCatalogForCity:city];
}

#pragma mark - Notification handlers

- (void)handleLoadCatalogCompleted:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFinishedLoadingCatalog object:nil];
    
    
    if([[notification userInfo] objectForKey:@"error"])
    {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Error loading catalog", @"Error loading catalog")];
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
            [SVProgressHUD showSuccessWithStatus:@""];
            
            [self reloadCollectionView];
        }
        
    }
    
}

- (void)handleDownloadFileCompleted:(NSNotification*)notification
{
    receivedFileNotifications+=1;
    if(receivedFileNotifications >= expectedNotifications)
    {
        [SVProgressHUD showProgress:100/100 status:NSLocalizedString(@"Updating pictures", @"Updating pictures") maskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showSuccessWithStatus:@""];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kFinishedDownloadingFile object:nil];
        [self reloadCollectionView];
        
    }
    else
    {
        [SVProgressHUD showProgress:((receivedFileNotifications*100.0)/expectedNotifications)/100.0+(10.0/100) status:NSLocalizedString(@"Updating pictures", @"Updating pictures") maskType:SVProgressHUDMaskTypeBlack];
    }
}


- (void)reloadCollectionView
{
    [self.collectionView reloadData];
    if([[[[AppState sharedInstance] currentCatalog] GHprofiles] count ] < 1)
    {
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"EmptyCatalogAlertViewTitle", @"No routes!") andMessage:NSLocalizedString(@"EmptyCatalogAlertViewMessage", @"Looks like this city has no routes to play. Please go back and pick another one!")];
        [alertView addButtonWithTitle:NSLocalizedString(@"EmptyCatalogAlertViewNo",@"Ok, got it")
                                 type:SIAlertViewButtonTypeCancel
                              handler:^(SIAlertView *alertView) {
                                  [alertView dismissAnimated:YES];
                              }];
        alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
        alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;

        [alertView show];
    }
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGSize retval = CGSizeMake(100, 100);
    retval.height += 35; retval.width += 35;
    return retval;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(30, 20, 30, 20);
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    // Update the page when more than 50% of the previous/next page is visible
    CGFloat pageWidth = _overlayView.scrollView.frame.size.width;
    int page = floor((_overlayView.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _overlayView.pageControl.currentPage = page;
    if (page < 3) {
        [_overlayView.playButton setTitle:NSLocalizedString(@"Next", nil) forState:UIControlStateNormal];
    }
    else{
        [_overlayView.playButton setTitle:NSLocalizedString(@"Let's play!", nil) forState:UIControlStateNormal];
    }
}

#pragma mark - Buttons

- (void)onHelpButton
{
    void (^jobFinished)(void) = ^{
        // We need the view to be reloaded by the main thread
        dispatch_async(dispatch_get_main_queue(),^{
            
            [UIView transitionWithView:self.view
                              duration:0.5
                               options:UIViewAnimationOptionTransitionCrossDissolve
                            animations:^{
                                [self.view addSubview:_overlayView];
                            }
                            completion:nil];        });
    };

    // create the async job
    NSBlockOperation *job = [NSBlockOperation blockOperationWithBlock:^{ [self setupHelpView]; }];
    [job setCompletionBlock:jobFinished];
    
    // put it in the queue for execution
    [[NSOperationQueue mainQueue] addOperation:job];
    
}

- (void)setupHelpView
{
    //Setup help views
    _overlayView = [[NSBundle mainBundle] loadNibNamed:@"OverlayView"owner:self options:nil][0];
    
    NSArray *subvArray = [NSArray arrayWithObjects:
                          [NSDictionary dictionaryWithObjectsAndKeys:@"help1",@"image",NSLocalizedString(@"Choose your route", nil), @"label", nil],
                          [NSDictionary dictionaryWithObjectsAndKeys:@"help2",@"image",NSLocalizedString(@"Follow the arrow", nil), @"label", nil],
                          [NSDictionary dictionaryWithObjectsAndKeys:@"help3",@"image",NSLocalizedString(@"Find places", nil), @"label", nil],
                          [NSDictionary dictionaryWithObjectsAndKeys:@"help4",@"image",NSLocalizedString(@"Get reward!", nil), @"label", nil],
                          nil];
    
    //Set the content size of our scrollview according to the total width of our imageView objects.
    _overlayView.scrollView.contentSize = CGSizeMake(_overlayView.scrollView.frame.size.width * 4, _overlayView.scrollView.frame.size.height);
    [_overlayView.playButton setTitle:NSLocalizedString(@"Next", nil) forState:UIControlStateNormal];

    
    for (int i = 0; i < 4; i++) {
        //We'll create a view object in every 'page' of our scrollView.
        CGRect frame;
        frame.origin.x = _overlayView.scrollView.frame.size.width * i;
        frame.origin.y = 0;
        frame.size = _overlayView.scrollView.frame.size;
        
        HelpView *help1 = [[NSBundle mainBundle] loadNibNamed:@"HelpView"owner:self options:nil][0]; //[[HelpView alloc] initWithFrame:frame];
        [help1 setFrame:frame];
        help1.label.text = [[subvArray objectAtIndex:i] objectForKey:@"label"];
        help1.imageView.image = [UIImage imageNamed:[[subvArray objectAtIndex:i] objectForKey:@"image"]];
        
        [_overlayView.scrollView addSubview:help1];
    }
}

@end
