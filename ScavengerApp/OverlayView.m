//
//  OverlayViewController.m
//  ScavengerApp
//
//  Created by Giovanni on 5/15/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "OverlayView.h"

#import <QuartzCore/QuartzCore.h>

#import "HelpView.h"

//RGB color macro
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

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
    
    
    

    _playButton.titleLabel.text = NSLocalizedString(@"Let's play!", nil);
    // Draw a custom gradient
    UIColor *blueColor = UIColorFromRGB(0x83CEE4);
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = _playButton.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[blueColor colorWithAlphaComponent:0.9].CGColor,
                       (id)[blueColor colorWithAlphaComponent:1.0].CGColor,
                       nil];
    
    [_playButton.layer insertSublayer:gradient atIndex:0];
    _playButton.layer.cornerRadius = 5;
    _playButton.layer.masksToBounds = YES;

    
}

- (IBAction)closeButtonPressed:(id)sender
{
    
    [UIView transitionWithView:self.superview
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [self removeFromSuperview];
                    }
                    completion:nil];
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


@end
