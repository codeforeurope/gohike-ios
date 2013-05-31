//
//  CloudView.h
//  ScavengerApp
//
//  Created by Lodewijk Loos on 30-05-13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CloudView : UIView
{
    NSTimer *timer;
    float maxCloudHeight;
    float totalShift;
    float smoothSpeed;
    int noUpdateCnt;
}

@property (nonatomic) double speed;

- (void)startAnimation;
- (void)stopAnimation;


@end
