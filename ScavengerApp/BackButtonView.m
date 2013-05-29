//
//  BackButtonView.m
//  ScavengerApp
//
//  Created by Lodewijk Loos on 29-05-13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "BackButtonView.h"

@implementation BackButtonView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //add icon vertical mid
        UIImageView *backImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon-back"]];
        backImage.center = CGPointMake(backImage.center.x, frame.size.height / 2);
        [self addSubview:backImage];
        
        //add text vertical mid after 
        NSString *labelText = @"Back";
        float padding = 10;
        UIFont *font = [UIFont systemFontOfSize:[UIFont systemFontSize]];
        CGSize labelSize = [labelText sizeWithFont:font];
        UILabel *backLabel = [[UILabel alloc] initWithFrame:CGRectMake(backImage.frame.size.width + padding, (frame.size.height - labelSize.height) / 2, labelSize.width, labelSize.height)];
        backLabel.font = font;
        backLabel.text = labelText;
        backLabel.textColor = [UIColor whiteColor];
        backLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:backLabel];
        
    }
    
    return self;
}



@end
