//
//  OverlayViewController.m
//  ScavengerApp
//
//  Created by Giovanni Maggini on 5/15/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "OverlayView.h"

#import <QuartzCore/QuartzCore.h>

#import "HelpView.h"

@interface OverlayView ()

@end

@implementation OverlayView

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    self.modalView.layer.shadowColor = [UIColor blackColor].CGColor;
    self.modalView.layer.shadowOffset = CGSizeMake(0, 0);
    self.modalView.layer.shadowOpacity = 1;
    self.modalView.layer.shadowRadius = 2.0;


    
    
    // Draw a custom gradient
    UIColor *blueColor = [UIColor colorWithRed:0.386 green:0.720 blue:0.834 alpha:1.000];
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = _playButton.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[blueColor colorWithAlphaComponent:0.9].CGColor,
                       (id)[blueColor colorWithAlphaComponent:1.0].CGColor,
                       nil];
    
    [_playButton.layer insertSublayer:gradient atIndex:0];
    _playButton.layer.cornerRadius = 5;
    _playButton.layer.masksToBounds = YES;
    
}

- (void)scrollToPage:(int)page
{
    CGRect frame = self.scrollView.frame;
    frame.origin.x = frame.size.width * page;
    frame.origin.y = 0;
    [self.scrollView scrollRectToVisible:frame animated:YES];
}


- (IBAction)playButtonPressed:(id)sender
{
    CGFloat pageWidth = self.scrollView.frame.size.width;
    int page = floor((self.scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    if(page < 3)
    {
        [self scrollToPage:page+1];
    }
    else{
        [UIView transitionWithView:self.superview
                          duration:0.5
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [self removeFromSuperview];
                        }
                        completion:nil];
    }
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
