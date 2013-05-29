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

#import "RouteFinishedView.h"

#import "NavigationStatusView.h"

#define ARROW_SIZE 150
#define COMPASS_SIZE 300
#if DEBUG
#define CHECKIN_DISTANCE 5000 //meters
#else
#define CHECKIN_DISTANCE 50 //meters
#endif
//#define DEGREES_TO_RADIANS(x) (M_PI * x / 180.0)
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define STATUS_HEIGHT 50
#define NAVBAR_HEIGHT 44

@interface CompassViewController ()
@property (nonatomic, strong) UIImageView *arrow;
@property (nonatomic, strong) UIImageView *compass;
@property (nonatomic, weak) CheckinView * checkinView;
@property (nonatomic, weak) RouteFinishedView *routeFinishedView;
@property (nonatomic,strong) NavigationStatusView *statusView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *destinationLocation;
@property (nonatomic, assign) BOOL checkinPending;
@end

@implementation CompassViewController
@synthesize arrow, compass, checkinView, statusView;
@synthesize locationManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.checkinPending = NO;
        
//    _destinationLocation = [[CLLocation alloc] initWithLatitude:DUMMY_LATITUDE longitude:DUMMY_LONGITUDE];
//        _destinationLocation = [[CLLocation alloc] initWithLatitude:[AppState sharedInstance].activeTarget.latitude longitude:[AppState sharedInstance].activeTarget.longitude];
        float latitude = [[[[AppState sharedInstance] activeWaypoint] objectForKey:@"latitude"] floatValue];
        float longitude = [[[[AppState sharedInstance] activeWaypoint] objectForKey:@"longitude"] floatValue];
        _destinationLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        NSLog(@"Destination: lat: %f long %f", latitude, longitude);
    }
    return self;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [[AppState sharedInstance] setPlayerIsInCompass:NO];
    [[AppState sharedInstance] save];
}

- (void)viewDidAppear:(BOOL)animated
{
    [[AppState sharedInstance] setPlayerIsInCompass:YES];
    [[AppState sharedInstance] save];
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
        //arrow.transform = CGAffineTransformMakeRotation(adjusted_heading_radians);

        
        [UIView animateWithDuration:0.1 delay:0.0 options:
//         UIViewAnimationOptionBeginFromCurrentState |
         UIViewAnimationOptionCurveLinear animations:^{
            CGAffineTransform transform = CGAffineTransformMakeRotation(adjusted_heading_radians);
            arrow.transform = transform;
        } completion:nil];
        
    }
}

//updates the statusview checkin display
-(void) updateCheckinStatus
{
    //1b. update the statusview
    NSArray *waypoints = [[AppState sharedInstance].activeRoute objectForKey:@"waypoints"];
    NSArray *checkins = [[AppState sharedInstance] checkinsForRoute:[AppState sharedInstance].activeRouteId];
    [self.statusView setCheckinsComplete:[checkins count] ofTotal:[waypoints count]];
}

-(IBAction)checkIn
{
    NSLog(@"CHECK IN");
    
    //1. record the checkin as done
    [[AppState sharedInstance] checkIn];
    [self updateCheckinStatus];
    
    //2. change the active target
    BOOL continueRoute =  [[AppState sharedInstance] nextTarget];
    if (continueRoute) {
        
        float latitude = [[[[AppState sharedInstance] activeWaypoint] objectForKey:@"latitude"] floatValue];
        float longitude = [[[[AppState sharedInstance] activeWaypoint] objectForKey:@"longitude"] floatValue];
        _destinationLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        NSLog(@"Destination: lat: %f long %f", latitude, longitude);
        
        
        [self.checkinView removeFromSuperview];
        self.checkinPending = NO;
    }
    else { 
        
    }
//    _destinationLocation = [[CLLocation alloc] initWithLatitude:[AppState sharedInstance].activeTarget.latitude longitude:[AppState sharedInstance].activeTarget.longitude];

}

-(IBAction) finishRoute:(id)sender
{
    [_routeFinishedView removeFromSuperview];
}

-(IBAction) goToReward:(id)sender
{
    [_routeFinishedView removeFromSuperview];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    NSString * destinationName = [[[AppState sharedInstance] activeWaypoint] objectForKey:@"name_en"];
    NSLog(@"did update with destination: %@",destinationName);
    
    CLLocation *currentLocation = [locations lastObject];
//    NSLog(@"New user location: %@", currentLocation);
    NSDate* eventDate = currentLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        
        // If the event is recent, do something with it.
        double distanceFromDestination = [currentLocation distanceFromLocation:_destinationLocation];
        [self.statusView update:destinationName withDistance:distanceFromDestination];
        
        if (distanceFromDestination < CHECKIN_DISTANCE) {
            NSLog(@"within distance");
            
            if(!self.checkinPending)
            {
                self.checkinPending = YES;
//                UIView *aCheckinView = [[[NSBundle mainBundle] loadNibNamed:@"CheckinView" owner:self options:nil] objectAtIndex:0];
                //Begin - Added by Giovanni 2013-05-28
                //TODO: to test
                NSString *langKey = [[AppState sharedInstance] language];
                CheckinView *aCheckinView = [[CheckinView alloc] init];
                aCheckinView.locationTextView.text = [[[AppState sharedInstance] activeWaypoint] objectForKey:[NSString stringWithFormat:@"description_%@", langKey]];
                aCheckinView.checkInLabel.text = NSLocalizedString(@"You can check-in!", nil);
                //End - Added by Giovanni 2013-05-28
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
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Exit", nil)
                                     style:UIBarButtonItemStyleBordered
                                    target:nil
                                    action:@selector(BackButtonPressed:)];
    
    self.navigationItem.rightBarButtonItem =
    [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Map", nil)
                                     style:UIBarButtonItemStyleBordered
                                    target:nil
                                    action:nil];
    
    CGRect statusRect = CGRectMake(0, self.view.bounds.size.height - (STATUS_HEIGHT + NAVBAR_HEIGHT), self.view.bounds.size.width, STATUS_HEIGHT);
    self.statusView = [[NavigationStatusView alloc] initWithFrame:statusRect];
    [self updateCheckinStatus];
    
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
    
    CGPoint screenCenter = CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height / 2) - NAVBAR_HEIGHT);
    compass = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"compass.png"]];
    CGRect compassRect = CGRectMake(0, 0, COMPASS_SIZE, COMPASS_SIZE);
    [compass setFrame:compassRect];
    [compass setCenter:screenCenter];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIImage *backgroundImage = [UIImage imageNamed:@"background.png"];
    UIImageView *background = [[UIImageView alloc] initWithImage:backgroundImage];
    background.contentMode = UIViewContentModeScaleAspectFit;
    [background setFrame:self.view.bounds];
    [self.view addSubview:background];
    
    UIImage *gridImage = [UIImage imageNamed:@"grid.png"];
    UIImageView *grid = [[UIImageView alloc] initWithImage:gridImage];
    grid.contentMode = UIViewContentModeScaleAspectFit;
    [grid setFrame:self.view.bounds];
    [grid setCenter:screenCenter];
    
    
    UIImage * arrowImage = [UIImage imageNamed:@"arrow.png"];
    arrow = [[UIImageView alloc] initWithImage:arrowImage];
    arrow.contentMode = UIViewContentModeScaleAspectFit;
    
    //[arrow setFrame:CGRectMake(20, 20, 100, 100)];
    CGRect arrowRect = CGRectMake(0, 0, ARROW_SIZE, ARROW_SIZE);
    [arrow setFrame:arrowRect];
    [arrow setCenter:CGPointMake(screenCenter.x + 1, screenCenter.y)];//manual calibration
    
    [self.view addSubview:grid];
    [self.view addSubview:compass];
    [self.view addSubview:arrow];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.statusView];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
