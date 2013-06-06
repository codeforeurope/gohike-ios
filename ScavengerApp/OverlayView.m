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

@interface OverlayView ()

@end

@implementation OverlayView

//-(id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self)
//    {
//        NSArray *subvArray = [NSArray arrayWithObjects:
//                              [NSDictionary dictionaryWithObjectsAndKeys:@"help1",@"image",NSLocalizedString(@"Choose your route", nil), @"label", nil],
//                              [NSDictionary dictionaryWithObjectsAndKeys:@"help2",@"image",NSLocalizedString(@"Follow the arrow", nil), @"label", nil],
//                              [NSDictionary dictionaryWithObjectsAndKeys:@"help3",@"image",NSLocalizedString(@"Check-in to places", nil), @"label", nil],
//                              [NSDictionary dictionaryWithObjectsAndKeys:@"help4",@"image",NSLocalizedString(@"Get reward!", nil), @"label", nil],
//                              nil];
//        
//        for (int i = 0; i < 4; i++) {
//            //We'll create an imageView object in every 'page' of our scrollView.
//            CGRect frame;
//            frame.origin.x = _overlayView.scrollView.frame.size.width * i;
//            frame.origin.y = 0;
//            frame.size = _overlayView.scrollView.frame.size;
//            
//            NSLog(@"%@",NSStringFromCGRect(frame));
//            
//            HelpView *help1 = [[HelpView alloc] initWithFrame:frame];
//            help1.label.text = [[subvArray objectAtIndex:i] objectForKey:@"label"];
//            help1.imageView.image = [UIImage imageNamed:[[subvArray objectAtIndex:i] objectForKey:@"image"]];
//            
//            //        HelpView *help2 = [[HelpView alloc] initWithFrame:frame];
//            //        help2.label.text = NSLocalizedString(@"Follow the arrow", nil);
//            //        help2.imageView.image = [UIImage imageNamed:@"help2"];
//            //
//            //        HelpView *help3 = [[HelpView alloc] initWithFrame:frame];
//            //        help3.label.text = NSLocalizedString(@"Check-in to places", nil);
//            //        help3.imageView.image = [UIImage imageNamed:@"help3"];
//            //
//            //        HelpView *help4 = [[HelpView alloc] initWithFrame:frame];
//            //        help4.label.text = NSLocalizedString(@"Get reward!", nil);
//            //        help4.imageView.image = [UIImage imageNamed:@"help4"];
//            
//            
//            [_overlayView.scrollView addSubview:help1];
//            //        [_overlayView.scrollView addSubview:help2];
//            //        [_overlayView.scrollView addSubview:help3];
//            //        [_overlayView.scrollView addSubview:help4];
//        }
//        //Set the content size of our scrollview according to the total width of our imageView objects.
//        _overlayView.scrollView.contentSize = CGSizeMake(_overlayView.scrollView.frame.size.width * 4, _overlayView.scrollView.frame.size.height);
//    }
//    return self;
//}

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
