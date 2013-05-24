//
//  CompassViewController.m
//  ScavengerApp
//
//  Created by Taco van Dijk on 5/21/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "CompassViewController.h"

#import <QuartzCore/QuartzCore.h>

#import "CLLocation+measuring.h"

#import "CheckinView.h"

#define ARROW_SIZE 150
#define COMPASS_SIZE 300
#define CHECKIN_DISTANCE 3650 //meters
//#define DEGREES_TO_RADIANS(x) (M_PI * x / 180.0)
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)

@interface CompassViewController ()
@property (nonatomic, strong) UIImageView *arrow;
@property (nonatomic, strong) UIImageView *compass;
@property (nonatomic, weak) CheckinView * checkinView;
@property (nonatomic, strong) UILabel *distanceLabel;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *destinationLocation;
@property (nonatomic, assign) BOOL checkinPending;
@end

@implementation CompassViewController
@synthesize arrow, compass, checkinView;
@synthesize locationManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.checkinPending = NO;
        
//    _destinationLocation = [[CLLocation alloc] initWithLatitude:DUMMY_LATITUDE longitude:DUMMY_LONGITUDE];
        _destinationLocation = [[CLLocation alloc] initWithLatitude:[AppState sharedInstance].activeTarget.latitude longitude:[AppState sharedInstance].activeTarget.longitude];
    }
    return self;
}

-(IBAction)BackButtonPressed:(id)sender
{
    NSLog(@"BackButtonPressed");
    [[AppState sharedInstance] setPlayerIsInCompass:NO];
}


#pragma mark - CLLocation

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    if (newHeading.headingAccuracy > 0) {
        float magneticHeading = newHeading.magneticHeading;
        float trueHeading = newHeading.trueHeading;
#if DEBUG
        //NSLog(@"magnetic heading %f",magneticHeading);
        //NSLog(@"true heading: %f",trueHeading);
#endif
        //current heading in degrees and radians
        //use true heading if it is available
        float heading = (trueHeading > 0) ? trueHeading : magneticHeading;
        float heading_radians = DEGREES_TO_RADIANS(heading);

        
        compass.transform = CGAffineTransformMakeRotation(-1 * heading_radians); //set the compass to current heading

//        [UIView animateWithDuration:0.1 delay:0.0 options:
////         UIViewAnimationOptionBeginFromCurrentState |
//         UIViewAnimationOptionCurveLinear animations:^{
//            CGAffineTransform transform = CGAffineTransformMakeRotation(-1 * heading_radians);
//            compass.transform = transform;
//        } completion:nil];
        
        
        
        CLLocationDirection destinationHeading = [locationManager.location directionToLocation:_destinationLocation];
        //NSLog(@"Destination heading: %f",destinationHeading);
        float adjusted_heading = destinationHeading - heading;
        float adjusted_heading_radians = DEGREES_TO_RADIANS(adjusted_heading);
        arrow.transform = CGAffineTransformMakeRotation(adjusted_heading_radians);

        
//        [UIView animateWithDuration:0.1 delay:0.0 options:
////         UIViewAnimationOptionBeginFromCurrentState |
//         UIViewAnimationOptionCurveLinear animations:^{
//            CGAffineTransform transform = CGAffineTransformMakeRotation(adjusted_heading_radians);
//            arrow.transform = transform;
//        } completion:nil];
        
    }
}

-(IBAction)checkIn
{
    NSLog(@"CHECK IN");
    
    //1. record the checkin as done
    [[AppState sharedInstance] checkIn];
    
    //2. change the active target
    [[AppState sharedInstance] nextTarget];
    _destinationLocation = [[CLLocation alloc] initWithLatitude:[AppState sharedInstance].activeTarget.latitude longitude:[AppState sharedInstance].activeTarget.longitude];
    
   
    [self.checkinView removeFromSuperview];
    self.checkinPending = NO;
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"did update with destination: %@", [AppState sharedInstance].activeTarget.locationName );
    CLLocation *currentLocation = [locations lastObject];
//    NSLog(@"New user location: %@", currentLocation);
    NSDate* eventDate = currentLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        double distanceFromDestination = [currentLocation distanceFromLocation:_destinationLocation];
        _distanceLabel.text = [NSString stringWithFormat:@"%f meters", distanceFromDestination];
        
        if (distanceFromDestination < CHECKIN_DISTANCE) {
            NSLog(@"within distance");
            if(!self.checkinPending)
            {
                self.checkinPending = YES;
                UIView *aCheckinView = [[[NSBundle mainBundle] loadNibNamed:@"CheckinView" owner:self options:nil] objectAtIndex:0];
                self.checkinView = (CheckinView*)aCheckinView;
                [self.view addSubview:checkinView];
                NSLog(@"add checkin view");
            }
        }
    }
    
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Could not get location due to error: %@", [error description]);
}

#pragma mark - UIViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.navigationItem.backBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Exit"
                                     style:UIBarButtonItemStyleBordered
                                    target:nil
                                    action:@selector(BackButtonPressed:)];
    
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:@"Map"
                                     style:UIBarButtonItemStyleBordered
                                    target:nil
                                    action:nil];
    
    
    if(locationManager == nil)
    {
        locationManager = [[CLLocationManager alloc] init];
    }
    locationManager.delegate = self;
    locationManager.activityType = CLActivityTypeFitness; //Used to track pedestrian activity
    locationManager.headingFilter = 5;  // 5 degrees
//        locationManager.distanceFilter = 2; //2 meters
    

    if( [CLLocationManager locationServicesEnabled]
       &&  [CLLocationManager headingAvailable]) {
        NSLog(@"heading available");
        [locationManager startUpdatingLocation];
        [locationManager startUpdatingHeading];
        
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
    [arrow setCenter:CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2)];
    
    compass = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"ring_compas.png"]];
    CGRect compassRect = CGRectMake(0, 0, COMPASS_SIZE, COMPASS_SIZE);
    [compass setFrame:compassRect];
    [compass setCenter:CGPointMake(self.view.frame.size.width / 2, self.view.frame.size.height / 2)];
//    [compass setCenter:self.view.center];

    
    CGRect distanceLabelRect = CGRectMake(0, 0, 400, 50);
    _distanceLabel = [[UILabel alloc] initWithFrame:distanceLabelRect];
    _distanceLabel.backgroundColor = [UIColor clearColor];
    _distanceLabel.text = @"Calculating...";
    _distanceLabel.textColor = [UIColor redColor];
    _distanceLabel.textAlignment = NSTextAlignmentCenter;
    _distanceLabel.center = CGPointMake(self.view.frame.size.width/2, 40);
    _distanceLabel.font = [UIFont systemFontOfSize:22.0];
    
    [self.view addSubview:arrow];
    [self.view addSubview:compass];
    [self.view addSubview:_distanceLabel];
    [self.view setBackgroundColor:[UIColor lightGrayColor]];
    
    
        
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
