//
//  MapPoint.h
//  GoHikeAmsterdam
//
//  Created by Giovanni Maggini on 6/5/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <MapKit/MapKit.h>

@protocol GHAnnotation <MKAnnotation>

@property (nonatomic, assign) BOOL visited;
@property (nonatomic, assign) BOOL current;

@end

@interface MapPoint : MKPointAnnotation <GHAnnotation>

@property (nonatomic, assign) BOOL visited;
@property (nonatomic, assign) BOOL current;

@end
