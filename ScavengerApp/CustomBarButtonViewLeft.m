//
//  CustomBarButtonView.m
//  ScavengerApp
//
//  Created by Lodewijk Loos on 30-05-13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//
#import "CustomBarButtonViewLeft.h"
#import <QuartzCore/QuartzCore.h>

@implementation CustomBarButtonViewLeft

- (id)initWithFrame:(CGRect)frame imageName:(NSString*)imageName text:(NSString*)text target:(id)aTarget action:(SEL)aAction
{
    self = [super initWithFrame:frame];
    if (self) {
        //add icon vertical mid
        UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        image.frame = CGRectMake(0, 0, 22.0, 22.0);
        image.center = CGPointMake(image.center.x, frame.size.height / 2);
        image.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:image];
                
        //add text vertical mid on the right of image
        if(text)
        {
            NSString *labelText = text;
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
//    for(UIView *subview in self.subviews)
//    {
//        subview.layer.opacity = 0.5;
//    }
    
    
    for(UIView *subview in self.subviews)
    {
        //This animates the fading
        [UIView transitionWithView:self
                          duration:0.4
                           options:UIViewAnimationOptionTransitionNone
                        animations:^{
                            [subview.layer setOpacity:0.5];

                            [subview.layer setOpacity:1.0];
                        }
                        completion:nil];
    }
    
    [self.target performSelector:self.action withObject:nil afterDelay:0.1];

}

@end
