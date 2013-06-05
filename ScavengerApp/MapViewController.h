//
//  MapViewController.h
//  ScavengerApp
//
//  Created by Lodewijk Loos on 04-06-13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface MapViewController : UIViewController <MKMapViewDelegate>
{
    MKMapView *map;
}

@end
