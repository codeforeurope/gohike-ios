//
//  CloudView.m
//  ScavengerApp
//
//  Created by Lodewijk Loos on 30-05-13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "CloudView.h"

@implementation CloudView

@synthesize speed;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //add clouds
        UIImageView *cloud1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cloud1"]];
        cloud1.center = CGPointMake(cloud1.bounds.size.width * 0.25, self.bounds.size.height * 0.33);
        [self addSubview:cloud1];
        
        UIImageView *cloud2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cloud2"]];
        cloud2.center = CGPointMake(self.bounds.size.width - cloud2.bounds.size.width * 0.25, self.bounds.size.height * 0.66);
        [self addSubview:cloud2];
        
        self.speed = 0;
        timer = nil;
        totalShift = 0;
        smoothSpeed = 0;
        noUpdateCnt = 0;
        maxCloudHeight = MAX(cloud1.bounds.size.height, cloud2.bounds.size.height);
    }
    return self;
}

- (void)setSpeed:(double)newSpeed
{
    speed = newSpeed;
    noUpdateCnt = 0;
}

- (void)startAnimation
{
    speed = 0;
    timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(onTimerTick:) userInfo:nil repeats:true];
}

- (void)onTimerTick:(id)something
{
    //set cloud positions
    smoothSpeed = smoothSpeed * 0.9 + self.speed * 0.1;
    
    float shift = smoothSpeed * 5;
    float wrapShift = self.bounds.size.height + maxCloudHeight;
    
    totalShift += shift;
    
    if(totalShift < 0)
    {
        totalShift += wrapShift;
    }
    else if(totalShift > wrapShift)
    {
        totalShift -= wrapShift;
    }
    
    int i=0;
    for(UIView *cloud in self.subviews)
    {
        float yStart = (float)(i+1)/((float)([self.subviews count] + 1)) * self.bounds.size.height;
        int yPos = ((int)(yStart + totalShift)) % ((int)wrapShift);
        cloud.center = CGPointMake(cloud.center.x, yPos - maxCloudHeight/2);
        i++;
    }
    
    //decrease speed if we get no updates
    if(noUpdateCnt > 50) //5 seconds
    {
        self.speed = 0;
    }
    noUpdateCnt++;
}

- (void)stopAnimation
{
    if(timer)
    {
        [timer invalidate];
        timer = nil;
    }
}


@end
