//
//  LocationDetailViewController.m
//  ScavengerApp
//
//  Created by Giovanni on 5/28/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "LocationDetailViewController.h"
#import "CompassViewController.h"
#import "QuartzCore/CALayer.h"
#import "CustomBarButtonViewLeft.h"
#import "CustomBarButtonViewRight.h"
#import "MapViewController.h"

@interface LocationDetailViewController ()

@property (nonatomic, strong) UIImageView *fullScreenImageView;

@end

@implementation LocationDetailViewController

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
    
    //route info
    NSString *langKey = [[AppState sharedInstance] language];
    if([_location objectForKey:@"image_data"])
        _locationImageView.image = [UIImage imageWithData:[NSData dataWithBase64EncodedString:[_location objectForKey:@"image_data"]]];
    else{
        _locationImageView.image = [UIImage imageNamed:@"no-picture"];
    }
//    _locationText.text = [_location objectForKey:[NSString stringWithFormat:@"description_%@",langKey]];
    _locationDescriptionLabel.text = [_location objectForKey:[NSString stringWithFormat:@"description_%@",langKey]];
    _locationTitleLabel.text = [_location objectForKey:[NSString stringWithFormat:@"name_%@", langKey]];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)] ;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGesture.numberOfTapsRequired = 2;
    _locationImageView.userInteractionEnabled = YES;
    _locationImageView.multipleTouchEnabled = YES;
    [_locationImageView addGestureRecognizer:pinchGesture];
    [_locationImageView addGestureRecognizer:tapGesture];

    
    _locationImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    _locationImageView.layer.shadowOffset = CGSizeMake(0, 2);
    _locationImageView.layer.shadowOpacity = 1;
    _locationImageView.layer.shadowRadius = 1.0;
    _locationImageView.clipsToBounds = NO;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)replayLocation
{
    NSArray *waypoints = [[[AppState sharedInstance] activeRoute] objectForKey:@"waypoints"];
    NSDictionary *thisWayPoint;
    
    NSUInteger index = [waypoints indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [[obj objectForKey:@"location_id"] integerValue] == [[_location objectForKey:@"location_id"] intValue];
    }];
    if (index == NSNotFound) {
        
    }
    else {
        thisWayPoint = [waypoints objectAtIndex:index];
    }
    
    if([waypoints count] > 0)
    {
        [[AppState sharedInstance] setActiveRouteId: [[_location objectForKey:@"route_id"] intValue]];
        [[AppState sharedInstance] setActiveTargetId: [[_location objectForKey:@"location_id"] intValue]];
        [[AppState sharedInstance] save];
                
        CompassViewController *compass = [[CompassViewController alloc] init];
        [self.navigationController pushViewController:compass animated:YES];
        
    }
}

- (void)onMapButton
{
    MapViewController *mvc = [[MapViewController alloc] init];
    mvc.waypoints = [NSArray arrayWithObject:self.location];
    mvc.singleLocation = YES;
    NSString *langKey = [[AppState sharedInstance] language];
    mvc.title = [_location objectForKey:[NSString stringWithFormat:@"name_%@", langKey]];
    [self.navigationController pushViewController:mvc animated:YES];
}

- (void)onBackButton
{
    [self.navigationController popViewControllerAnimated:TRUE];
}

#pragma mark - Pinch to zoom imageview

- (void)handlePinchGesture:(id)sender
{
    if (((UIPinchGestureRecognizer *)sender).state == UIGestureRecognizerStateEnded) {
        if(((UIPinchGestureRecognizer *)sender).view == _locationImageView)
        {
            if (((UIPinchGestureRecognizer *)sender).scale > 1) {
                [self showTitleImageFullScreen];
            }
        } else {
            if (((UIPinchGestureRecognizer *)sender).scale < 1) {
                [self closeTitleImageFullScreen];
            }
        }
    }
}
- (void)handleTap:(id)sender
{
    if (((UITapGestureRecognizer *)sender).view == _locationImageView) {
        [self showTitleImageFullScreen];
    } else {
        [self closeTitleImageFullScreen];
    }
}

- (void)showTitleImageFullScreen
{
    //TODO: Show a UIScrollView
    
    CGRect newRect = [_locationImageView convertRect:_locationImageView.bounds toView:[self.splitViewController.view superview]];
    UIImage *image = _locationImageView.image;
    _fullScreenImageView =[[UIImageView alloc] initWithImage:image];
    
    UIPinchGestureRecognizer *pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)] ;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tapGesture.numberOfTapsRequired = 2;

    _fullScreenImageView.userInteractionEnabled = YES;
    _fullScreenImageView.multipleTouchEnabled = YES;
    [_fullScreenImageView addGestureRecognizer:pinchGesture];
    [_fullScreenImageView addGestureRecognizer:tapGesture];

    _fullScreenImageView.contentMode = UIViewContentModeScaleAspectFit;
    _fullScreenImageView.frame = newRect;
    _fullScreenImageView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_fullScreenImageView];

    CGRect splitViewRect = self.view.frame;
    [UIView animateWithDuration:0.5 animations:^{
        _fullScreenImageView.backgroundColor = [UIColor blackColor];
        _fullScreenImageView.frame = splitViewRect;
    }];
    
}


- (void)closeTitleImageFullScreen
{
    CGRect newRect = [_locationImageView convertRect:_locationImageView.bounds toView:self.view];
    [UIView animateWithDuration:0.5
                     animations:^{
                         _fullScreenImageView.backgroundColor = [UIColor clearColor];
                         _fullScreenImageView.frame = newRect;
                     }
                     completion:^(BOOL finished) {
                         [_fullScreenImageView removeFromSuperview];
                         _fullScreenImageView = nil;
                     }];
}

@end
