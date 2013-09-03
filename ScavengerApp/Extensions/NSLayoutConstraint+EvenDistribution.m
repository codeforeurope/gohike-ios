//
//  NSLayoutConstraint+EvenDistribution.m
//  GoHikeAmsterdam
//
//  Created by Giovanni on 9/3/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "NSLayoutConstraint+EvenDistribution.h"

@implementation NSLayoutConstraint (EvenDistribution)

+(NSArray *)constraintsForEvenDistributionOfItems:(NSArray *)views
                           relativeToCenterOfItem:(id)toView vertically:(BOOL)vertically
{
    NSMutableArray *constraints = [NSMutableArray new];
    NSLayoutAttribute attr = vertically ? NSLayoutAttributeCenterY : NSLayoutAttributeCenterX;
    
    for (NSUInteger i = 0; i < [views count]; i++) {
        id view = views[i];
        CGFloat multiplier = (2*i + 2) / (CGFloat)([views count] + 1);
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:view
                                                                      attribute:attr
                                                                      relatedBy:NSLayoutRelationEqual
                                                                         toItem:toView
                                                                      attribute:attr
                                                                     multiplier:multiplier
                                                                       constant:0];
        [constraints addObject:constraint];
    }
    
    return constraints;
}

@end