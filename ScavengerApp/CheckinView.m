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
#define BUTTON_WIDTH 120


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
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 20, self.bounds.size.width, [@"A" sizeWithFont:titleFont].height)];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = titleFont;
        [self addSubview:titleLabel];
        
        
        //button
        UIButton *checkinButton = [UIButton buttonWithType:UIButtonTypeCustom];
        checkinButton.frame = CGRectMake((self.bounds.size.width - BUTTON_WIDTH)/2, self.bounds.size.height - BUTTON_HEIGHT - 10, BUTTON_WIDTH, BUTTON_HEIGHT);
        checkinButton.titleLabel.text = @"CHECK IN";
        checkinButton.layer.borderColor = [UIColor whiteColor].CGColor;
        checkinButton.layer.borderWidth = 2;
        checkinButton.layer.cornerRadius = 3;
        [checkinButton setTitle:NSLocalizedString(@"CHECK IN", nil) forState:UIControlStateNormal];
        [checkinButton addTarget:self action:@selector(onButton:) forControlEvents:UIControlEventTouchDown];
        [self addSubview:checkinButton];
        
        //body
        CGRect remainder = CGRectMake(0, CGRectGetMaxY(titleLabel.frame), self.bounds.size.width, CGRectGetMinY(checkinButton.frame) - CGRectGetMaxY(titleLabel.frame));
        bodyTextView = [[UITextView alloc] initWithFrame:CGRectInset(remainder, 10, 10)];
        bodyTextView.backgroundColor = [UIColor clearColor];
        bodyTextView.textColor = [UIColor whiteColor];
        [self addSubview:bodyTextView];
        
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
