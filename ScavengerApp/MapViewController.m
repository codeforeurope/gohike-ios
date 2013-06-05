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
#import "MapPoint.h"

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
    [map setShowsUserLocation:YES];
    map.delegate = self;
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
        
        MapPoint *pin = [[MapPoint alloc] init];
        NSString *langKey = [[AppState sharedInstance] language];
        [pin setTitle:[waypoint objectForKey:[NSString stringWithFormat:@"title_%@", langKey]]];
        pin.coordinate = destintation.coordinate;
        if ([[waypoint objectForKey:@"rank"] intValue] == [[[[AppState sharedInstance] activeWaypoint] objectForKey:@"rank" ] intValue]) {
            pin.current = YES;
        }
        else{
            pin.current = NO;
        }
        if ([[waypoint objectForKey:@"rank"] intValue] > [[[[AppState sharedInstance] activeWaypoint] objectForKey:@"rank" ] intValue]) {
            pin.visited = NO;
        }
        else{
            pin.visited = YES;
        }
        
        
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


#pragma mark - Mapview delegates

-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<GHAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;  //return nil to use default blue dot view
    
    //create annotation
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:@"pinView"];
    if (!pinView) {
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinView"];
        pinView.animatesDrop = FALSE;
        pinView.canShowCallout = YES;

        
        //details button
        //UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        //pinView.rightCalloutAccessoryView = rightButton;
        
    } else {
        pinView.annotation = annotation;
    }
    
    //Color
    if ([annotation current] == YES) {
        pinView.pinColor = MKPinAnnotationColorRed;
    }
    else{
        if ([annotation visited] == YES) {
            pinView.pinColor = MKPinAnnotationColorGreen;
        }
        else{
            pinView.pinColor = MKPinAnnotationColorPurple;
        }
    }
    
    return pinView;
}


//Required method
- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
{
    
}


@end
