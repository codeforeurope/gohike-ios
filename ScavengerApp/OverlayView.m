//
//  OverlayViewController.m
//  ScavengerApp
//
//  Created by Giovanni on 5/15/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "OverlayView.h"

#import <QuartzCore/QuartzCore.h>

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

@end
