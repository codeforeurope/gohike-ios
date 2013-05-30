//
//  CustomBarButtonView.m
//  ScavengerApp
//
//  Created by Lodewijk Loos on 30-05-13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "CustomBarButtonView.h"

@implementation CustomBarButtonView

- (id)initWithFrame:(CGRect)frame imageName:(NSString*)imageName text:(NSString*)text target:(id)target action:(SEL)selector
{
    self = [super initWithFrame:frame];
    if (self) {
        //add icon vertical mid
        UIImageView *backImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        backImage.center = CGPointMake(backImage.center.x, frame.size.height / 2);
        [self addSubview:backImage];
        
        //add text vertical mid after
        if(text)
        {
            NSString *labelText = NSLocalizedString(text, nil);
            float padding = 10;
            UIFont *font =  [UIFont fontWithName:@"HelveticaNeue" size:[UIFont systemFontSize]];
            CGSize labelSize = [labelText sizeWithFont:font];
            UILabel *backLabel = [[UILabel alloc] initWithFrame:CGRectMake(backImage.frame.size.width + padding, (frame.size.height - labelSize.height) / 2, labelSize.width, labelSize.height)];
            backLabel.font = font;
            backLabel.text = text;
            backLabel.textColor = [UIColor whiteColor];
            backLabel.backgroundColor = [UIColor clearColor];
            [self addSubview:backLabel];
        }
            
        //
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:target action:selector];
        [self addGestureRecognizer:tap];
    }
    
    return self;
}


@end
