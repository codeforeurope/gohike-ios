//
//  RouteDetailTitleCell.m
//  ScavengerApp
//
//  Created by Giovanni Maggini on 5/28/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "RouteDetailTitleCell.h"
#import "QuartzCore/CALayer.h"

@implementation RouteDetailTitleCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    _routeImage.layer.shadowColor = [UIColor blackColor].CGColor;
    _routeImage.layer.shadowOffset = CGSizeMake(0, 2);
    _routeImage.layer.shadowOpacity = 1;
    _routeImage.layer.shadowRadius = 1.0;
    _routeImage.clipsToBounds = NO;
    _routeImage.layer.shouldRasterize  = YES;
    _routeImage.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    _routeImage.layer.shadowPath = [UIBezierPath bezierPathWithRect:_routeImage.layer.bounds].CGPath;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
//
//-(UITableViewCellSelectionStyle)selectionStyle
//{
//    return UITableViewCellSelectionStyleNone;
//}

@end
