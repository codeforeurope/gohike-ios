//
//  LocationDetailViewController.m
//  ScavengerApp
//
//  Created by Giovanni Maggini on 5/28/13.
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
    NSData* imageData = [FileUtilities imageDataForWaypoint:_location];
    if(imageData != nil)
        _locationImageView.image = [UIImage imageWithData:imageData];
    else{
        _locationImageView.image = [UIImage imageNamed:@"no-picture"];
    }
    _locationDescriptionLabel.text = [_location GHdescription]; 
    _locationTitleLabel.text =  [_location GHname];
    _locationText.text = [_location GHdescription];
    
    
    //If user pinches on picture, enlarge it fullscreen
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
    
    
    
    //adjust the textview size
    CGRect frame = _locationText.frame;
    frame.size.height = _locationText.contentSize.height;
    _locationText.frame = frame;
////    [_locationText setAutoResizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth];
//
//    CGRect viewFrame = self.view.bounds;
//    viewFrame.size.height = viewFrame.size.height +  _locationText.contentSize.height;
//    [self.scrollView setContentSize:CGSizeMake(20000, 20000)];
//    
//    CGRect visibleRect;
//    visibleRect.origin = [_scrollView contentOffset];
//    visibleRect.size = [_scrollView bounds].size;
//    [_scrollView setNeedsDisplayInRect:visibleRect];
    
    CGSize s = _scrollView.frame.size;
    s.height = _locationText.frame.size.height + _locationImageView.frame.size.height + _locationTitleLabel.frame.size.height + 20;
    [_scrollView setContentSize:s];
    [_scrollView setContentOffset:CGPointMake(0, 0)];
    [_scrollView setNeedsDisplayInRect:self.view.bounds];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)replayLocation
{
    NSArray *waypoints = [[[AppState sharedInstance] currentRoute] GHwaypoints];
    GHWaypoint *thisWayPoint;
    
    NSUInteger index = [waypoints indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [obj GHlocation_id] == [_location GHlocation_id];
    }];
    if (index == NSNotFound) {
        
    }
    else {
        thisWayPoint = [waypoints objectAtIndex:index];
    }
    
    if([waypoints count] > 0)
    {
        [[AppState sharedInstance] setActiveRouteId: [_location GHroute_id]];
        [[AppState sharedInstance] setActiveTargetId: [_location GHlocation_id]];
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
    mvc.title = [_location GHname];
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

- (void)handlePanFrom:(id)sender
{
    UIPanGestureRecognizer *recognizer = (UIPanGestureRecognizer*)sender;
//    CGPoint translation = [recognizer translationInView:recognizer.view];
//    CGPoint velocity = [recognizer velocityInView:recognizer.view];
//    NSLog(@"Translation: %@ velocity %@", NSStringFromCGPoint(translation), NSStringFromCGPoint(velocity));

    if (recognizer.state == UIGestureRecognizerStateBegan) {
    } else if (recognizer.state == UIGestureRecognizerStateChanged) {
            //track movement
    } else if (recognizer.state == UIGestureRecognizerStateEnded) {
            //animate to final position
    }
    
    if (((UIPanGestureRecognizer *)sender).view == _locationImageView) {
//        NSLog(@"PanGesture in locationImageView");
    } else {
//        NSLog(@"PanGesture");
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
    
    UIPanGestureRecognizer* panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanFrom:)];


    _fullScreenImageView.userInteractionEnabled = YES;
    _fullScreenImageView.multipleTouchEnabled = YES;
    [_fullScreenImageView addGestureRecognizer:pinchGesture];
    [_fullScreenImageView addGestureRecognizer:tapGesture];
    [_fullScreenImageView addGestureRecognizer:panGestureRecognizer];

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
