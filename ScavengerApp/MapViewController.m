//
//  MapViewController.m
//  ScavengerApp
//
//  Created by Lodewijk Loos on 04-06-13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "MapViewController.h"
#import "CustomBarButtonView.h"
#import "CLLocation+measuring.h"


@interface MapViewController ()

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //custom back button
    CustomBarButtonView *backButton = [[CustomBarButtonView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)
                                                                       imageName:@"icon-back"
                                                                            text:@"Back"
                                                                          target:self
                                                                          action:@selector(onBackButton)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    //map view
    map = [[MKMapView alloc] initWithFrame:self.view.bounds];
    //map.userTrackingMode = MKUserTrackingModeFollowWithHeading;
    
    
    
    
    [self.view addSubview:map];
    
    
    
    //NSLog(@"s %@",NSStringFromCGRect(self.view.bounds));
    
}

- (void)viewDidAppear:(BOOL)animated
{
    //bounding rect containing waypoint locations and user location
    NSArray *waypoints = [[AppState sharedInstance] waypointsWithCheckinsForRoute: [[AppState sharedInstance] activeRouteId]];
    NSMutableArray *locations = [[NSMutableArray alloc] initWithCapacity:0];
    if(map.userLocation.location)
    {
        [locations addObject:map.userLocation.location];
    }
    for(NSDictionary *waypoint in waypoints)
    {
        float latitude = [[waypoint objectForKey:@"latitude"] floatValue];
        float longitude = [[waypoint objectForKey:@"longitude"] floatValue];
        CLLocation *destintation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        [locations addObject:destintation];
        
        //TODO: color pin for active dest
        MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
        pin.coordinate = destintation.coordinate;
        [map addAnnotation:pin];
    }
    CLCoordinateRect mapBounds = [CLLocation boundingBoxContainingLocations:locations];
    
    //coordinate span for setting zoom level
    CLLocationDegrees spanLat = fabs(mapBounds.topLeft.latitude - mapBounds.bottomRight.latitude);
    CLLocationDegrees spanLon = fabs(mapBounds.topLeft.longitude - mapBounds.bottomRight.longitude);
    MKCoordinateSpan span = MKCoordinateSpanMake(spanLat, spanLon);
    
    if(map.userLocation.location)
    {
        [map setRegion:MKCoordinateRegionMake(map.userLocation.location.coordinate, span)];
    }
    else
    {
        [map setRegion:MKCoordinateRegionMake(map.userLocation.location.coordinate, span)];
        [map setCenterCoordinate:((CLLocation*)[locations objectAtIndex:0]).coordinate];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onBackButton
{
    [self.navigationController popViewControllerAnimated:TRUE];
}

- (CGRect)boundsFittingAvailableScreenSpace;
{
    // start with applicationFrame's bounds
    CGRect bounds = [[UIScreen mainScreen] applicationFrame];
    bounds.origin.y = 0;
    
    // subtract space taken by navigation controller
    if (self.navigationController) {
        if (self.navigationController.navigationBarHidden == NO) {
            bounds.size.height -= self.navigationController.navigationBar.bounds.size.height;
        }
        if (self.navigationController.toolbarHidden == NO) {
            bounds.size.height -= self.navigationController.toolbar.bounds.size.height;
        }
    }
    
    // subtract space taken by tab bar controller
    if (self.tabBarController) {
        bounds.size.height -= self.tabBarController.tabBar.bounds.size.height;
    }
    
    return bounds;
}

@end
