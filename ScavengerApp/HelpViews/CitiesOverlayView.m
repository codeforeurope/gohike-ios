//
//  CitiesOverlayView.m
//  GoHikeAmsterdam
//
//  Created by Giovanni on 9/4/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "CitiesOverlayView.h"
#import <QuartzCore/QuartzCore.h>

@implementation CitiesOverlayView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    // Draw a custom gradient
    UIColor *color = [Utilities appColor];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = _playButton.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[color colorWithAlphaComponent:0.9].CGColor,
                       (id)[color colorWithAlphaComponent:1.0].CGColor,
                       nil];
    
    [_playButton.layer insertSublayer:gradient atIndex:0];
    _playButton.layer.cornerRadius = 5;
    _playButton.layer.masksToBounds = YES;
}


- (IBAction)playButtonPressed:(id)sender
{

        [UIView transitionWithView:self.superview
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [self removeFromSuperview];
                        }
                        completion:nil];

}

- (IBAction)dismissButtonPressed:(id)sender
{
    [UIView transitionWithView:self.superview
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self removeFromSuperview];
                    }
                    completion:nil];
}

@end
