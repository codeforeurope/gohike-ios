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


#define kSELECTION_CELL_IDENTIFIER @"SelectionCell"
#define kSECTION_HEADER_IDENTIFIER @"CatalogViewCollectionHeader"

@interface CatalogViewController ()
{
    int receivedFileNotifications;
    int expectedNotifications;
}

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
    
    
//    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CollectionViewCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:kSELECTION_CELL_IDENTIFIER bundle:nil] forCellWithReuseIdentifier:kSELECTION_CELL_IDENTIFIER];
    [self.collectionView registerNib:[UINib nibWithNibName:kSECTION_HEADER_IDENTIFIER bundle:nil] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kSECTION_HEADER_IDENTIFIER];

    [self loadCatalogForCity:[[AppState sharedInstance] currentCity].GHid];
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
    
    cell.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"cellbackground1"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch]];
    cell.selectedBackgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"cellbackground2"]  resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch]];
    cell.backgroundColor = [UIColor redColor];

    
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
        headerView.headerBackgroundImage.image  = [[UIImage imageNamed:@"overlay-background.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5) resizingMode:UIImageResizingModeStretch];
        
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
        [AppState sharedInstance].currentRoute = existingRoute;
        [[AppState sharedInstance] save];

    }
//    //load the route from disk, if available
//    NSString* libraryPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
//    NSString *filePath = [libraryPath stringByAppendingPathComponent: [NSString stringWithFormat:@"route_%d", [[selectedRoute objectForKey:@"id"] integerValue]]];
//    
//    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
//    {
//        NSDictionary *route = [NSDictionary dictionaryWithContentsOfFile:filePath];
//        [AppState sharedInstance].currentRoute = route;
//    }
//    [[AppState sharedInstance] save];
//            
    RouteStartViewController *rvc = [[RouteStartViewController alloc] initWithStyle:UITableViewStyleGrouped];
//    rvc.route = selectedRoute;
    [self.navigationController pushViewController:rvc animated:YES];
    
    
}

#pragma mark - Actions

- (void)loadCatalogForCity:(int)city
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadCatalogCompleted:) name:kFinishedLoadingCatalog object:nil];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"Getting routes to play", @"Getting routes to play") maskType:SVProgressHUDMaskTypeBlack];
    [[GoHikeHTTPClient sharedClient] getCatalogForCity:city];
}

#pragma mark - Notification handlers

- (void)handleLoadCatalogCompleted:(NSNotification*)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kFinishedLoadingCatalog object:nil];
    
    
    NSLog(@"Finished loading catalog");
    if([[notification userInfo] objectForKey:@"error"])
    {
        [SVProgressHUD showErrorWithStatus:NSLocalizedString(@"Error loading catalog", @"Error loading catalog")];
    }
    else{
        
        if([[[notification userInfo] objectForKey:@"expectedFiles"] integerValue] > 0)
        {
            [SVProgressHUD showProgress:10.0/100 status:NSLocalizedString(@"Getting pictures", @"Getting pictures") maskType:SVProgressHUDMaskTypeBlack];
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
        [SVProgressHUD showProgress:100/100 status:NSLocalizedString(@"Getting pictures", @"Getting pictures") maskType:SVProgressHUDMaskTypeBlack];
        [SVProgressHUD showSuccessWithStatus:@""];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kFinishedDownloadingFile object:nil];
        [self reloadCollectionView];
        
    }
    else
    {
        [SVProgressHUD showProgress:((receivedFileNotifications*100)/expectedNotifications)/100+(10.0/100) status:NSLocalizedString(@"Getting pictures", @"Getting pictures") maskType:SVProgressHUDMaskTypeBlack];
    }
}


- (void)reloadCollectionView
{
//    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadData];
//    } completion:^(BOOL finished) {}];
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

@end
