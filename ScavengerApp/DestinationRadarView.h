//
//  DestinationRadarView.h
//  ScavengerApp
//
//  Created by Lodewijk Loos on 31-05-13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLLocation+measuring.h"

@interface DestinationRadarView : UIView

@property (nonatomic,strong) NSArray *destinations; //array of waypoints (dictionaries)
@property (nonatomic,strong) NSDictionary *activeDestination; //array of waypoints (dictionaries)
@property (nonatomic,strong) CLLocation *currentLocation; 
@property (nonatomic) float radius; //radius of this view in meters
@property (nonatomic) float checkinRadiusInMeters;
@property (nonatomic) float checkinRadiusInPixels;


@end
