//
//  SelectionCell.h
//  ScavengerApp
//
//  Created by Giovanni Maggini on 5/16/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SelectionCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UIImageView *profileImage;
@property (nonatomic, weak) IBOutlet UILabel *profileLabel;
@property (nonatomic, weak) IBOutlet UILabel *bottomLabel;

@end
