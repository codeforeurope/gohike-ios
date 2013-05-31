//
//  DestinationRadarView.m
//  ScavengerApp
//
//  Created by Lodewijk Loos on 31-05-13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "DestinationRadarView.h"

#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@implementation DestinationRadarView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.destinations = nil;
        self.currentLocation = nil;
        self.activeDestination = nil;
        self.radius = 5000;
        self.checkinRadiusInMeters = 10;
        self.checkinRadiusInPixels = 200;
        self.backgroundColor = [UIColor clearColor];
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{

    //active destination allways has to be "in line" with the arrow
    //give it always an angle of -PI/2 
    if(self.currentLocation && self.activeDestination)
    {
        
        
        float zeroAngle = -M_PI / 2;
        
        float lat1 = [[self.activeDestination objectForKey:@"latitude"] floatValue];
        float lon1 = [[self.activeDestination objectForKey:@"longitude"] floatValue];
        CLLocation *activeDestintationLocation = [[CLLocation alloc] initWithLatitude:lat1 longitude:lon1];
        CLLocationDirection activeDestintationAngle = [activeDestintationLocation directionToLocation:self.currentLocation];
        float activeDestintationRad = DEGREES_TO_RADIANS(activeDestintationAngle);
        
        for(NSDictionary *waypoint in self.destinations)
        {
            float latitude = [[waypoint objectForKey:@"latitude"] floatValue];
            float longitude = [[waypoint objectForKey:@"longitude"] floatValue];
            CLLocation *destintation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
            CLLocationDistance dist = [destintation distanceFromLocation:self.currentLocation];
            CLLocationDirection a = [destintation directionToLocation:self.currentLocation];
            float rad = DEGREES_TO_RADIANS(a) - activeDestintationRad + zeroAngle;
            
            
            
            if(self.activeDestination == waypoint)
            {
                [[UIColor greenColor] setFill];
            }
            else
            {
                
                [[UIColor colorWithWhite:0.9 alpha:1] setFill];
            }
            
            float pixR = 0;
            if(dist > self.checkinRadiusInMeters) //if a point is outside the mid circle, use the border of the circle as "zero"
            {
                float pixPerMeter = ((self.bounds.size.width / 2) - self.checkinRadiusInPixels) / self.radius;
                pixR = self.checkinRadiusInPixels + pixPerMeter * dist;
            }
            else //use the center as "zero"
            {
                float pixPerMeter = self.checkinRadiusInPixels / self.checkinRadiusInMeters;
                pixR = pixPerMeter * dist;
            }
            
            float x = pixR * cos(rad) + self.bounds.size.width / 2;
            float y = pixR * sin(rad) + self.bounds.size.height / 2;
            
            UIBezierPath *bezier = [UIBezierPath bezierPathWithArcCenter:CGPointMake(x, y) radius:10 startAngle:0 endAngle:M_PI * 2 clockwise:true];
            [[UIColor colorWithWhite:0.3 alpha:0.5] setStroke];
            [bezier fill];
            [bezier stroke];            
        }
    }

}



@end
