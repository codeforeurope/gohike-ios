//
//  CheckinView.m
//  ScavengerApp
//
//  Created by Taco van Dijk on 5/23/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "CheckinView.h"
#import <QuartzCore/QuartzCore.h>

#define TITLE_FONT_SIZE 22
#define BUTTON_HEIGHT 30
#define BUTTON_WIDTH 200

//RGB color macro
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@implementation CheckinView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {              
        self.backgroundColor = [UIColor blackColor];
        self.layer.shadowColor = [UIColor blackColor].CGColor;
        self.layer.shadowOffset = CGSizeMake(0, 0);
        self.layer.shadowOpacity = 1;
        self.layer.shadowRadius = 2.0;
        self.layer.cornerRadius = 10;
        
        
        //title
        UIFont *titleFont = [UIFont fontWithName:@"HelveticaNeue" size:TITLE_FONT_SIZE];
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.bounds.size.width, [@"A" sizeWithFont:titleFont].height)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = titleFont;
        [self addSubview:titleLabel];
        
        
        
        //button with gradient
        UIButton *checkinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        checkinButton.frame = CGRectMake((self.bounds.size.width - BUTTON_WIDTH)/2, self.bounds.size.height - BUTTON_HEIGHT - 10, BUTTON_WIDTH, BUTTON_HEIGHT);
        checkinButton.titleLabel.text = NSLocalizedString(@"Found!", nil);
        // Draw a custom gradient
        UIColor *blueColor = UIColorFromRGB(0x83CEE4);
        CAGradientLayer *gradient = [CAGradientLayer layer];
        gradient.frame = checkinButton.bounds;
        gradient.colors = [NSArray arrayWithObjects:(id)[blueColor colorWithAlphaComponent:0.9].CGColor,
                                                    (id)[blueColor colorWithAlphaComponent:1.0].CGColor,
                                                    nil];
        [checkinButton.layer insertSublayer:gradient atIndex:0];
        checkinButton.layer.cornerRadius = 5;
        checkinButton.layer.masksToBounds = YES;
        [checkinButton setTitle:NSLocalizedString(@"Found!", nil) forState:UIControlStateNormal];
        [checkinButton addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:checkinButton];
        
        //body
        CGRect remainder = CGRectMake(0, CGRectGetMaxY(titleLabel.frame), self.bounds.size.width, CGRectGetMinY(checkinButton.frame) - CGRectGetMaxY(titleLabel.frame));
        bodyTextView = [[UITextView alloc] initWithFrame:CGRectInset(remainder, 10, 10)];
        bodyTextView.backgroundColor = [UIColor clearColor];
        bodyTextView.textColor = [UIColor whiteColor];
        [self addSubview:bodyTextView];
        
        //image
        CGRect imageRect = CGRectMake(0, 50, 240, 160 );
        destinationImageView = [[UIImageView alloc] initWithFrame:imageRect];
        destinationImageView.contentMode = UIViewContentModeScaleAspectFill;
        destinationImageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                                 UIViewAutoresizingFlexibleHeight);
        [destinationImageView setClipsToBounds:YES];

//        destinationImageView.frame = imageRect;
//        destinationImageView.center = CGPointMake(destinationImageView.center.x, frame.size.height / 2);
        destinationImageView.center = CGPointMake(self.center.x, self.center.y);
        [self addSubview:destinationImageView];
        
        //little close button in top right
        UIImageView *closeButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"closebox"]];
        closeButton.center = CGPointMake(self.bounds.size.width - closeButton.bounds.size.width/2 - 5,
                                         closeButton.bounds.size.height/2 + 5);
        closeButton.userInteractionEnabled = true;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClose:)];
        [closeButton addGestureRecognizer:tap];
        [self addSubview:closeButton];
        
        
    }
    return self;
}

- (void)setTitle:(NSString*)text
{
    titleLabel.text = text;
}

- (void)setBodyText:(NSString *)text
{
    bodyTextView.text = text;
}

- (void)setDestinationImage:(NSData*)data
{
    destinationImageView.image = [UIImage imageWithData:data];
}

- (void)onClose:(id)something
{
    if(self.closeTarget)
    {
        [self.closeTarget performSelector:self.closeAction withObject:nil afterDelay:0];
    }
    [self removeFromSuperview];
}

- (void)onButton:(UIButton*)button
{
    //User has found the place. Change the content of the textView, and change the button so that says "go to next destination"
    NSLog(@"Found button pressed");
    
    //Change content of textview
    NSString *langKey = [[AppState sharedInstance] language];

    titleLabel.text = [NSString stringWithFormat:NSLocalizedString(@"FoundPlaceTitle", nil), [[[AppState sharedInstance] activeWaypoint] objectForKey:[NSString stringWithFormat:@"name_%@",langKey]]];
    bodyTextView.text = [[[AppState sharedInstance] activeWaypoint] objectForKey:[NSString stringWithFormat:@"description_%@",langKey]];
    
    //make a "Continue" button
    [button removeFromSuperview]; //remove the previous button, make a new one

    UIButton *checkinButton = [UIButton buttonWithType:UIButtonTypeCustom];
    checkinButton.frame = CGRectMake((self.bounds.size.width - BUTTON_WIDTH)/2, self.bounds.size.height - BUTTON_HEIGHT - 10, BUTTON_WIDTH, BUTTON_HEIGHT);
    checkinButton.titleLabel.text = NSLocalizedString(@"Continue!", nil);
    // Draw a custom gradient
    UIColor *blueColor = UIColorFromRGB(0x83CEE4);
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = checkinButton.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[blueColor colorWithAlphaComponent:0.9].CGColor,
                       (id)[blueColor colorWithAlphaComponent:1.0].CGColor,
                       nil];

    [checkinButton.layer insertSublayer:gradient atIndex:0];
    checkinButton.layer.cornerRadius = 5;
    checkinButton.layer.masksToBounds = YES;
    [checkinButton setTitle:NSLocalizedString(@"Continue!", nil) forState:UIControlStateNormal];
    [checkinButton addTarget:self action:@selector(onContinueButton:) forControlEvents:UIControlEventTouchDown];
    [self addSubview:checkinButton];
    
}

- (void)onContinueButton:(UIButton*)button
{
    //This is where we dismiss the check-in view
    
    NSLog(@"Continue button pressed");
    if(self.buttonTarget)
    {
        [self.buttonTarget performSelector:self.buttonAction withObject:nil afterDelay:0];
    }
    [self removeFromSuperview];
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
