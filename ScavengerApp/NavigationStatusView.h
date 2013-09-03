//
//  NavigationStatusView.h
//  ScavengerApp
//
//  Created by Taco van Dijk on 5/28/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface NavigationStatusView : UIView
//-(void) update:(NSString *)locationName withDistance:(double)distance;//update the view
-(void)setCheckinsCompleteWithArray:(NSArray*)array;
@end
