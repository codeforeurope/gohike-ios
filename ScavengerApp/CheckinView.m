//
//  CheckinView.m
//  ScavengerApp
//
//  Created by Taco van Dijk on 5/23/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "CheckinView.h"
#import <QuartzCore/QuartzCore.h>

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
        
        float pad = 5;
        UIImageView *closeButton = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"closebox"]];
        closeButton.center = CGPointMake(self.bounds.size.width - closeButton.bounds.size.width/2 - pad,
                                         closeButton.bounds.size.height/2 + pad);
        closeButton.userInteractionEnabled = true;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onClose:)];
        [closeButton addGestureRecognizer:tap];
        [self addSubview:closeButton];
        
    }
    return self;
}

- (void)onClose:(id)something
{
    if(self.target)
    {
        [self.target performSelector:self.action withObject:nil afterDelay:0];
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
