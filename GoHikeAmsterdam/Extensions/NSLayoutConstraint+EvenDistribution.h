//
//  NSLayoutConstraint+EvenDistribution.h
//  GoHikeAmsterdam
//
//  Created by Giovanni on 9/3/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSLayoutConstraint (EvenDistribution)

/**
 * Returns constraints that will cause a set of views to be evenly distributed horizontally
 * or vertically relative to the center of another item. This is used to maintain an even
 * distribution of subviews even when the superview is resized.
 */
+ (NSArray *) constraintsForEvenDistributionOfItems:(NSArray *)views
                             relativeToCenterOfItem:(id)toView
                                         vertically:(BOOL)vertically;

@end

