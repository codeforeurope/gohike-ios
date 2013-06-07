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

@property (nonatomic,strong) NSArray *waypoints;
@property (nonatomic, assign) BOOL singleLocation; //This means we are showing only 1 pin on the map, not playing the game

@end
