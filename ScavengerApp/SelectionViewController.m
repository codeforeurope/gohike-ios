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

@interface SelectionViewController () <UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, weak) IBOutlet UICollectionView *collectionView;
@property (nonatomic, strong) RouteProfiles *routeProfiles;


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
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"CollectionViewCell"];
    
    
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
    NSString *path = [[NSBundle mainBundle] pathForResource:@"routeprofiles" ofType:@"json"];
    NSData* data = [NSData dataWithContentsOfFile:path];
    __autoreleasing NSError* error = nil;
    _routeProfiles = [RouteProfiles modelObjectWithDictionary:[NSJSONSerialization JSONObjectWithData:data options:0 error:&error]];
    
    if (!error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _routeProfiles.profiles = [_routeProfiles.profiles sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                NSNumber *id1 = [NSNumber numberWithDouble: [[obj1 valueForKey:@"profileId"] doubleValue]];
                NSNumber *id2 = [NSNumber numberWithDouble: [[obj2 valueForKey:@"profileId"] doubleValue]];
                return [id1 compare:id2];
            }];
        });
    }
    
    
    NSLog(@"%@", _routeProfiles);
    NSLog(@"%@", _routeProfiles.profiles);

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
    return [_routeProfiles.profiles count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CollectionViewCell" forIndexPath:indexPath];

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
    return UIEdgeInsetsMake(50, 20, 50, 20);
}


#pragma mark - UICollectionView actions

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    RouteStartViewController *routeStartVC = [[RouteStartViewController alloc] initWithNibName:@"RouteStartViewController" bundle:nil];
    routeStartVC.routeID = 1;
    routeStartVC.routeTitle = @"The Green Trail";
    routeStartVC.routeDescription = @"Come with me explore Amsterdam!";
    [self.navigationController pushViewController:routeStartVC animated:YES];
}






@end
