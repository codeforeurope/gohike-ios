//
//  NavigationStatusView.m
//  ScavengerApp
//
//  Created by Taco van Dijk on 5/28/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//
// Responsible for displaying the progress of the current route, and the distance to the current target
// intended to be controlled by the CompassViewController

#import "NavigationStatusView.h"

#define CHECKIN_SIZE 25

@interface NavigationStatusView()

@end

@implementation NavigationStatusView

//update the collection of completed checkins
-(void)setCheckinsCompleteWithArray:(NSArray*)array
{
    UIImage * targetImage = [UIImage imageNamed:@"target-white-small.png"];
    UIImage * targetCompleteImage = [UIImage imageNamed:@"target-checked-white-small.png"];
    
    //clear all
    for(UIView * aView in self.checkinsView.subviews)
    {
        [aView removeFromSuperview];
    }
    
    int total = [array count];
    //add subviews
    for(int i = 0; i < total; i++)
    {
        UIImageView * image;
        
        if([[[array objectAtIndex:i] objectForKey:@"visited"] boolValue] == YES)
        {
            //draw a completed icon
            image = [[UIImageView alloc] initWithImage:targetCompleteImage];
        }
        else
        {
            //draw an open icon
            image = [[UIImageView alloc] initWithImage:targetImage];
        }
        
        image.contentMode = UIViewContentModeScaleAspectFit;
        image.translatesAutoresizingMaskIntoConstraints = NO;
        [self.checkinsView addSubview:image];
        

    }
    
    NSArray *subvievs = [NSArray arrayWithArray:self.checkinsView.subviews];
    [self.checkinsView addConstraints:
     [NSLayoutConstraint constraintsForEvenDistributionOfItems:subvievs
                                        relativeToCenterOfItem:self.checkinsView
                                                    vertically:NO]];
    
}



@end
