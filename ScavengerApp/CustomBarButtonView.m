//
//  CustomBarButtonView.m
//  ScavengerApp
//
//  Created by Lodewijk Loos on 30-05-13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//
#import "CustomBarButtonView.h"
#import <QuartzCore/QuartzCore.h>

@implementation CustomBarButtonView

- (id)initWithFrame:(CGRect)frame imageName:(NSString*)imageName textRight:(NSString*)textRight textLeft:(NSString*)textLeft target:(id)aTarget action:(SEL)aAction
{
    self = [super initWithFrame:frame];
    if (self) {
        //add icon vertical mid
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        image.center = CGPointMake(image.center.x, frame.size.height / 2);
        [self addSubview:image];
        
        //add text vertical mid on the left of image
        if(textLeft)
        {
            NSString *labelText = textLeft;
            float padding = 10;
            UIFont *font =  [UIFont fontWithName:@"HelveticaNeue" size:[UIFont systemFontSize]];
            CGSize labelSize = [labelText sizeWithFont:font];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0-padding-labelSize.width, (frame.size.height - labelSize.height) / 2, labelSize.width, labelSize.height)];
            label.font = font;
            label.text = labelText;
            label.textColor = [UIColor whiteColor];
            label.backgroundColor = [UIColor clearColor];
            [self addSubview:label];
        }
        
        //add text vertical mid on the right of image
        if(textRight)
        {
            NSString *labelText = textRight;
            float padding = 10;
            UIFont *font =  [UIFont fontWithName:@"HelveticaNeue" size:[UIFont systemFontSize]];
            CGSize labelSize = [labelText sizeWithFont:font];
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(image.frame.size.width+padding, (frame.size.height - labelSize.height) / 2, labelSize.width, labelSize.height)];
            label.font = font;
            label.text = labelText;
            label.textColor = [UIColor whiteColor];
            label.backgroundColor = [UIColor clearColor];
            [self addSubview:label];
        }
        
        //set calback handler
        self.target = aTarget;
        self.action = aAction;
        
        //add tap
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)onTap
{
    for(UIView *subview in self.subviews)
    {
        subview.layer.opacity = 0.5;
    }
    [self.target performSelector:self.action withObject:nil afterDelay:0.1];
}

@end
