//
//  CompassTopView.h
//  GoHikeAmsterdam
//
//  Created by Giovanni on 6/7/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CompassTopView : UIView

@property (nonatomic, weak) IBOutlet UILabel *label;

- (void)updateDistance:(double)distance;

@end
