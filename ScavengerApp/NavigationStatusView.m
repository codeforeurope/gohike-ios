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
#define CHECKIN_IMAGE_PADDING 5
#define CHECKIN_VIEW_PADDING 10
#define CHECKIN_VIEW_VERTICAL_OFFSET -5

@interface NavigationStatusView()
//    @property(nonatomic,retain) UILabel * distanceLabel;
    @property(nonatomic,retain) IBOutlet UIView * checkinsView;//just a container view
@end

@implementation NavigationStatusView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
//        //add background
//        UIImage *backgroundImage = [UIImage imageNamed:@"navigation-bottom-background"];
//        UIImageView *background = [[UIImageView alloc] initWithImage:backgroundImage];
//        background.contentMode = UIViewContentModeScaleToFill;
//        [background setFrame:self.bounds];
//        [self addSubview:background];
    
//        
//        CGRect checkinsRect = CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height-CHECKIN_VIEW_PADDING);
//        CGPoint viewCenter = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2+CHECKIN_VIEW_VERTICAL_OFFSET);
//        NSLog(@"bounds: %@", NSStringFromCGRect(self.bounds));
//        NSLog(@"center: %@", NSStringFromCGPoint(viewCenter));
//        self.checkinsView = [[UIView alloc] initWithFrame:checkinsRect];
//        [self.checkinsView setCenter:viewCenter];
//        
//        [self addSubview:self.checkinsView];
        
    }
    return self;
}

//update the displayed information about the current target
//-(void) update:(NSString *)locationName withDistance:(double)distance
//{
//    [self.distanceLabel setText:[NSString stringWithFormat:@"%@",locationName]];
//}

//update the collection of completed checkins
-(void)setCheckinsCompleteWithArray:(NSArray*)array
{
    UIImage * targetImage = [UIImage imageNamed:@"target-white-small.png"];
    UIImage * targetCompleteImage = [UIImage imageNamed:@"target-checked-white-small.png"];
    
    float side = self.checkinsView.bounds.size.height - CHECKIN_IMAGE_PADDING; //should scale proportionally?
    
    //clear all
    for(UIView * aView in self.checkinsView.subviews)
    {
        [aView removeFromSuperview];
    }
    
    int total = [array count];
    //add subviews
    for(int i = 0; i < total; i++)
    {
        CGRect targetRect = CGRectMake(i * (side + SPACER), 2, side, side);
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
        
        image.frame = targetRect;
        image.contentMode = UIViewContentModeScaleAspectFit;
        [self.checkinsView addSubview:image];
    }
    
    CGSize checkinsSize = CGSizeMake(total * (side + SPACER), self.bounds.size.height/2);
    [self.checkinsView sizeThatFits:checkinsSize];
    
    //resize and center checkinsView
//    CGPoint viewCenter = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2+CHECKIN_VIEW_VERTICAL_OFFSET);
//    [self.checkinsView setCenter:viewCenter];
//    CGRect checkinsRect = CGRectMake(0,0,self.bounds.size.width,self.bounds.size.height-CHECKIN_VIEW_PADDING);
//    CGRect checkinsRect = CGRectMake(0,self.bounds.size.height/2,total * (side + SPACER),self.bounds.size.height/2);
//    self.checkinsView.frame = checkinsRect;
//    self.checkinsView.center = viewCenter;
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
