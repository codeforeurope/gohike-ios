//
//  MapViewController.m
//  ScavengerApp
//
//  Created by Lodewijk Loos on 04-06-13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "MapViewController.h"
#import "CustomBarButtonViewLeft.h"
#import "CLLocation+measuring.h"
#import "MapPoint.h"

@interface MapViewController ()

@end

@implementation MapViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //custom back button
    CustomBarButtonViewLeft *backButton = [[CustomBarButtonViewLeft alloc] initWithFrame:CGRectMake(0, 0, 32, 32)
                                                                       imageName:@"icon-back"
                                                                        text:NSLocalizedString(@"Back",nil)
                                                                          target:self
                                                                          action:@selector(onBackButton)];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    //map view
    map = [[MKMapView alloc] initWithFrame:self.view.bounds];
    map.showsUserLocation = YES;
    map.delegate = self;
    [self.view addSubview:map];    
}

- (void)viewDidAppear:(BOOL)animated
{
    //bounding rect containing waypoint locations and user location
    NSMutableArray *locations = [[NSMutableArray alloc] initWithCapacity:0];
    CLLocation *currentDestination = nil;
    
    for(NSDictionary *waypoint in self.waypoints)
    {
        //add destinations to array
        float latitude = [[waypoint objectForKey:@"latitude"] floatValue];
        float longitude = [[waypoint objectForKey:@"longitude"] floatValue];
        CLLocation *destintation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        [locations addObject:destintation];
        
        //add annotation pins
        MapPoint *pin = [[MapPoint alloc] init];
        NSString *langKey = [[AppState sharedInstance] language];
        [pin setTitle:[waypoint objectForKey:[NSString stringWithFormat:@"name_%@", langKey]]];
        pin.coordinate = destintation.coordinate;
        if ([[waypoint objectForKey:@"rank"] intValue] == [[[[AppState sharedInstance] activeWaypoint] objectForKey:@"rank" ] intValue])
        {
            pin.current = YES;
            currentDestination = destintation;
        }
        else
        {
            pin.current = NO;
        }
        if ([[waypoint objectForKey:@"rank"] intValue] > [[[[AppState sharedInstance] activeWaypoint] objectForKey:@"rank" ] intValue])
        {
            pin.visited = NO;
        }
        else
        {
            pin.visited = YES;
        }
        
        //only add current and visited locations
        if(pin.visited || pin.current)
        {
            [map addAnnotation:pin];
        }        
    }
    
    if(map.userLocation.location && currentDestination)
    {
        //make span big enough to contain current destination, use current location as center
        CLLocationDegrees spanLat = 2.5 * fabs(map.userLocation.location.coordinate.latitude - currentDestination.coordinate.latitude);
        CLLocationDegrees spanLon = 2.5 * fabs(map.userLocation.location.coordinate.longitude - currentDestination.coordinate.longitude);
        MKCoordinateSpan span = MKCoordinateSpanMake(spanLat, spanLon);
        [map setRegion:MKCoordinateRegionMake(map.userLocation.location.coordinate, span)];
        [map setCenterCoordinate:map.userLocation.location.coordinate];
    }
    else if([locations count])
    {
        CLCoordinateRect mapBounds = [CLLocation boundingBoxContainingLocations:locations];
        CLLocationDegrees spanLat = 2.2 * fabs(mapBounds.topLeft.latitude - mapBounds.bottomRight.latitude);
        CLLocationDegrees spanLon = 2.2 * fabs(mapBounds.topLeft.longitude - mapBounds.bottomRight.longitude);
        MKCoordinateSpan span = MKCoordinateSpanMake(spanLat, spanLon);
        CLLocationDegrees centerLat = (mapBounds.topLeft.latitude + mapBounds.bottomRight.latitude) / 2;
        CLLocationDegrees centerLon = (mapBounds.topLeft.longitude + mapBounds.bottomRight.longitude) / 2;
        [map setRegion:MKCoordinateRegionMake(map.userLocation.location.coordinate, span)];
        [map setCenterCoordinate:CLLocationCoordinate2DMake(centerLat, centerLon)];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)onBackButton
{
    [self.navigationController popViewControllerAnimated:TRUE];
}

#pragma mark - Mapview delegates

-(MKAnnotationView*)mapView:(MKMapView *)mapView viewForAnnotation:(id<GHAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;  //return nil to use default blue dot view
    
    if([annotation isKindOfClass:[MapPoint class]])
    {
        MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithFrame:CGRectMake(0, 0, 0 , 0)];
        annotationView.canShowCallout = YES;
        annotationView.annotation = annotation;
        
        if ([annotation current] == YES)
        {
            annotationView.image = [UIImage imageNamed:@"target"];
        }
        else if ([annotation visited] == YES)
        {
            annotationView.image = [UIImage imageNamed:@"target-checked"];
        }
        return annotationView;
    }
    return nil;
}




//Required method
- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
{
    
}


@end
