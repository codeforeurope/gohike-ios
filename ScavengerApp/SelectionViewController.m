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
    UIView *tablebgView = [[[NSBundle mainBundle] loadNibNamed:@"TableBackground" owner:self options:nil] objectAtIndex:0];
    [self.collectionView setBackgroundView:tablebgView];
 
    [self loadData];
    
//    Use only with default collectionviewcells
//    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CollectionViewCell"];
//    [self.collectionView registerClass:[SelectionCell class] forCellWithReuseIdentifier:@"SelectionCell"];
    [self.collectionView registerNib:[UINib nibWithNibName:@"SelectionCell" bundle:nil] forCellWithReuseIdentifier:@"SelectionCell"];
    
}


-(void) viewDidAppear:(BOOL)animated
{
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
    if (cell == nil) {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
        
    }

    NSDictionary *profile = [_profiles objectAtIndex:indexPath.row];

    cell.profileImage.image = [UIImage imageWithData:[NSData dataWithBase64EncodedString:[profile objectForKey:@"image_data"]]];
    NSString *nameKey = [NSString stringWithFormat:@"name_%@", [[AppState sharedInstance] language]];
    cell.profileLabel.text = [profile objectForKey:nameKey];
    cell.bottomLabel.text = [NSString stringWithFormat:@"%d Routes", [[profile objectForKey:@"routes"] count]]; //[NSString stringWithFormat:NSLocalizedString(@"%@ Routes",nil), [[profile objectForKey:@"routes"] count]];
    cell.backgroundColor = [UIColor whiteColor];

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
    return UIEdgeInsetsMake(30, 20, 30, 20);
}


#pragma mark - UICollectionView actions

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *selectedProfile = [_profiles objectAtIndex:indexPath.row];
    [AppState sharedInstance].activeProfileId = [[selectedProfile objectForKey:@"id"] integerValue];
    [[AppState sharedInstance] save];
    
    NSArray *routes = [selectedProfile objectForKey:@"routes"];
    if ([routes count] > 0) {
        RouteStartViewController *rvc = [[RouteStartViewController alloc] init];
        rvc.route = [routes objectAtIndex:0];
        [self.navigationController pushViewController:rvc animated:YES];
    }
    else{
        NSLog(@"No routes for selected profile!!");
    }
    

}






@end
