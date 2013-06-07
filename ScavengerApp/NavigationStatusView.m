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
#define SPACER 5

@interface NavigationStatusView()
    @property(nonatomic,retain) UILabel * distanceLabel;
    @property(nonatomic,retain) UIView * checkinsView;//just a container view
@end

@implementation NavigationStatusView
@synthesize distanceLabel;
@synthesize checkinsView;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //[self setBackgroundColor:[UIColor redColor]];
        
        //add background
        UIImage *backgroundImage = [UIImage imageNamed:@"navigation-bottom-background"];
        UIImageView *background = [[UIImageView alloc] initWithImage:backgroundImage];
        background.contentMode = UIViewContentModeScaleToFill;
        [background setFrame:self.bounds];
        [self addSubview:background];
        
        //add divider as rectangle, maybe use coregraphics later instead?
        int insetY = (self.bounds.size.height/2) - 1;
        CGRect dividerRect = CGRectInset(self.bounds, insetY, insetY);
        dividerRect.origin.y = dividerRect.origin.y + 1;
        UIView * divider = [[UIView alloc] initWithFrame:dividerRect];
        [divider setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:divider];
        
        //frame of the distance label is the top half
        CGRect distanceRect = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height/2);
        distanceRect.origin.y = distanceRect.origin.y + 2;
        self.distanceLabel = [[UILabel alloc] initWithFrame:distanceRect];
        [self.distanceLabel setTextAlignment:NSTextAlignmentCenter];
        [self.distanceLabel setText:@""];
        [self.distanceLabel setBackgroundColor:[UIColor clearColor]];
        [self.distanceLabel setTextColor:[UIColor whiteColor]];
        [self.distanceLabel setFont:[UIFont fontWithName:@"HelveticaNeue" size:16]];
        
        CGRect checkinsRect = CGRectMake(0,self.bounds.size.height/2,self.bounds.size.width,self.bounds.size.height/2);
        self.checkinsView = [[UIView alloc] initWithFrame:checkinsRect];
        //[self.checkinsView setBackgroundColor:[UIColor yellowColor]];
        
        [self addSubview:self.checkinsView];
        [self addSubview:self.distanceLabel];
        
    }
    return self;
}

//update the displayed information about the current target
-(void) update:(NSString *)locationName withDistance:(double)distance
{
//    [self.distanceLabel setText:[NSString stringWithFormat:@"Next: %@ (%.0f m.)",locationName,distance]];
    [self.distanceLabel setText:[NSString stringWithFormat:@"Next: %@",locationName]];
}

//update the collection of completed checkins
-(void) setCheckinsComplete:(int)complete ofTotal:(int)total
{
    UIImage * targetImage = [UIImage imageNamed:@"target-white-small.png"];
    UIImage * targetCompleteImage = [UIImage imageNamed:@"target-checked-white-small.png"];
    
    float side = self.checkinsView.bounds.size.height - 2;
    
    //clear all
    for(UIView * aView in self.checkinsView.subviews)
    {
        [aView removeFromSuperview];
    }
    
    //add subviews
    for(int i = 0; i < total; i++)
    {
        CGRect targetRect = CGRectMake(i * (side + SPACER), 2, side, side);
        UIImageView * image;
        
        if(i < complete)
        {
            //draw a completed icon
             image = [[UIImageView alloc] initWithImage:targetCompleteImage];
        }
        else
        {
            //draw an open icon
            image = [[UIImageView alloc] initWithImage:targetImage];
        }
        
        image.frame = targetRect;
        image.contentMode = UIViewContentModeScaleAspectFit;
        [self.checkinsView addSubview:image];
    }
    
    //resize and center checkinsView
    CGRect checkinsRect = CGRectMake(0,self.bounds.size.height/2,total * (side + SPACER),self.bounds.size.height/2);
    self.checkinsView.frame = checkinsRect;
    self.checkinsView.center = CGPointMake(self.center.x, self.checkinsView.center.y);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
