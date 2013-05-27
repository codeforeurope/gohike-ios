//
//  SelectionViewController.m
//  ScavengerApp
//
//  Created by Giovanni on 5/15/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "SelectionViewController.h"
#import "RouteStartViewController.h"
#import "OverlayView.h"
#import "DataModels.h"
#import "SelectionCell.h"

@interface SelectionViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
//@property (nonatomic, strong) GameData *routeProfiles;
@property (nonatomic, strong) NSArray *profiles;


@end

@implementation SelectionViewController

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
    // Do any additional setup after loading the view from its nib.
    self.title = NSLocalizedString(@"Choose profile", nil);
    
    [self loadData];
    
//    Use only with default collectionviewcells
//    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CollectionViewCell"];
//    [self.collectionView registerClass:[SelectionCell class] forCellWithReuseIdentifier:@"SelectionCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"SelectionCell" bundle:nil] forCellWithReuseIdentifier:@"SelectionCell"];
    
    
    //How to play screen
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"howtoplay_displayed"] == nil) {
        OverlayView *overlayView = [[NSBundle mainBundle] loadNibNamed:@"OverlayView"owner:self options:nil][0];
        
        [UIView transitionWithView:self.view
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [self.view addSubview:overlayView];
                        }
                        completion:nil];
//        [[NSUserDefaults standardUserDefaults] setObject:YES forKey:@"howtoplay_displayed"];
    }

}


- (void)loadData
{
    
    
    _profiles = [[[AppState sharedInstance] game] objectForKey:@"profiles"];
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"routeprofiles" ofType:@"json"];
//    NSData* data = [NSData dataWithContentsOfFile:path];
//    __autoreleasing NSError* error = nil;
//    _routeProfiles = [GameData modelObjectWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:0 error:&error]];
//    
//    if (!error) {
//        dispatch_async(dispatch_get_main_queue(), ^{
//            _routeProfiles.profiles = [_routeProfiles.profiles sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
//                NSNumber *id1 = [NSNumber numberWithDouble: [[obj1 valueForKey:@"profileId"] doubleValue]];
//                NSNumber *id2 = [NSNumber numberWithDouble: [[obj2 valueForKey:@"profileId"] doubleValue]];
//                return [id1 compare:id2];
//            }];
//        });
//    }
//    
//    
//    NSLog(@"%@", _routeProfiles);
//    NSLog(@"%@", _routeProfiles.profiles);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionView Datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
//    return [_routeProfiles.profiles count];
    return [_profiles count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SelectionCell";

    
    SelectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
//    if (cell == nil) {
//        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
//        cell = [nib objectAtIndex:0];
//        
//    }
    
//    cell.profileImage.image = [UIImage imageNamed:@"default-profile"]; // = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default-profile.png"]];
//    cell.profileLabel.text = [NSString stringWithFormat: @"%@", [[_routeProfiles.profiles objectAtIndex:indexPath.row] name]];
//    cell.backgroundColor = [UIColor whiteColor];

    NSDictionary *profile = [_profiles objectAtIndex:indexPath.row];
    NSLog(@"profile: %@", profile);
    cell.profileImage.image = [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:[profile objectForKey:@"icon_data"]]]];
    NSString *nameKey = [NSString stringWithFormat:@"name_%@", [[AppState sharedInstance] language]];
    cell.profileLabel.text = [profile objectForKey:nameKey];

    return cell;

}


#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    CGSize retval = CGSizeMake(100, 100);
    retval.height += 35; retval.width += 35;
    return retval;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(50, 20, 50, 20);
}


#pragma mark - UICollectionView actions

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    Profiles *selectedProfile = [_routeProfiles.profiles objectAtIndex:indexPath.row];
    
//    NSString *path = [[NSBundle mainBundle] pathForResource:@"routes" ofType:@"json"];
//    NSData* data = [NSData dataWithContentsOfFile:path];
//    __autoreleasing NSError* error = nil;
//    NSArray *allRoutes = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
//    NSIndexSet *indexesOfProfileRoutes = [allRoutes indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
//        return ([[obj objectForKey:@"profileId"] integerValue] == selectedProfile.profileId);
//    }];
//    NSArray *routesForProfile = [allRoutes objectsAtIndexes:indexesOfProfileRoutes];
//    
//    if (!error) {
//        NSLog(@"%@", allRoutes);
//        NSLog(@"%@", routesForProfile);
//
//        [AppState sharedInstance].activeProfile = selectedProfile;       
//        
//        [[AppState sharedInstance] save]; 
//        
//        RouteStartViewController *routeStartVC = [[RouteStartViewController alloc] initWithNibName:@"RouteStartViewController" bundle:nil];
//        routeStartVC.currentRoute = [routesForProfile objectAtIndex:0];
//        [self.navigationController pushViewController:routeStartVC animated:YES];
//    }
//    else
//    {
//        NSLog(@"Error in parsing routes: %@", error.description);
//    }
    
    NSDictionary *selectedProfile = [_profiles objectAtIndex:indexPath.row];
    NSArray *routes = [selectedProfile objectForKey:@"routes"];
    if ([routes count] > 0) {
        RouteStartViewController *rvc = [[RouteStartViewController alloc] initWithNibName:@"RouteStartViewController" bundle:nil];
        rvc.route = [routes objectAtIndex:0];
        [self.navigationController pushViewController:rvc animated:YES];
        
    }
    else{
        NSLog(@"No routes for selected profile!!");
    }
    

}






@end
