//
//  CompassViewController.m
//  ScavengerApp
//
//  Created by Taco van Dijk on 5/21/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "CompassViewController.h"

#import <QuartzCore/QuartzCore.h>

#define ARROW_SIZE 150
#define DEGREES_TO_RADIANS(x) (M_PI * x / 180.0)

@interface CompassViewController ()
@property (nonatomic, strong) UIImageView *arrow;
@property (nonatomic, strong) CLLocationManager *locationManager;

@end

@implementation CompassViewController
@synthesize arrow;
@synthesize locationManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    if (newHeading.headingAccuracy > 0) {
        float magneticHeading = newHeading.magneticHeading;
        float trueHeading = newHeading.trueHeading;
        NSLog(@"magnetic heading %f",magneticHeading);
        NSLog(@"true heading: %f",trueHeading);
        
        //magneticHeadingLabel.text = [NSString stringWithFormat:@"%f", magneticHeading];
        //trueHeadingLabel.text = [NSString stringWithFormat:@"%f", trueHeading];
        
        float heading = -1.0f * M_PI * newHeading.magneticHeading / 180.0f;
        arrow.transform = CGAffineTransformMakeRotation(heading);
    }
}
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    if(locationManager == nil)
    {
        locationManager = [[CLLocationManager alloc] init];
    }
        locationManager.delegate = self;
    if( [CLLocationManager locationServicesEnabled]
       &&  [CLLocationManager headingAvailable]) {
        NSLog(@"heading available");
        [locationManager startUpdatingLocation];
        [locationManager startUpdatingHeading];
        
        locationManager.headingFilter = 5;  // 5 degrees
    } else {
        NSLog(@"Can't report heading");
    }
    
    UIImage * arrowImage = [UIImage imageNamed:@"arrow.png"];
    arrow = [[UIImageView alloc] initWithImage:arrowImage];
    [arrow.layer setBorderColor:[UIColor redColor].CGColor];
    [arrow.layer setBorderWidth:1];
    
    //[arrow setFrame:CGRectMake(20, 20, 100, 100)];
    CGRect arrowRect = CGRectMake(0, 0, ARROW_SIZE, ARROW_SIZE);
    [arrow setFrame:arrowRect];
    [arrow setCenter:self.view.center];
    
    //[arrow setTransform:CGAffineTransformMakeRotation(DEGREES_TO_RADIANS(180))];
    
    //point the arrow north
    
    [self.view addSubview:arrow];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
