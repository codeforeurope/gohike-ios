//
//  RouteDetailTitleCell.h
//  ScavengerApp
//
//  Created by Giovanni Maggini on 5/28/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RouteDetailTitleCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIImageView *routeImage;
@property (nonatomic, weak) IBOutlet UILabel *routeTitleLabel;
@property (nonatomic, weak) IBOutlet UILabel *routeHighlightsLabel;
@property (nonatomic, weak) IBOutlet UILabel *routeDuratioLabel;

@end
