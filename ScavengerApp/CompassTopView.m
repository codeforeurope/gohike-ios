//
//  CompassTopView.m
//  GoHikeAmsterdam
//
//  Created by Giovanni Maggini on 6/7/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "CompassTopView.h"

@implementation CompassTopView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)awakeFromNib
{
//    [self setBackgroundColor:[UIColor blackColor]];
//    [self setOpaque:YES];
//    [self setAlpha:1];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)updateDistance:(double)distance
{
    if(distance > 1000){
        _label.text = [NSString stringWithFormat:@"%.2f Km",distance/1000];
    }
    else{
        _label.text = [NSString stringWithFormat:@"%.0f m",distance];
    }
}
@end
