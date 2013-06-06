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

#import "CustomBarButtonView.h"

#import "CloudView.h"

#import "DestinationRadarView.h"

#import "MapViewController.h"

#define ARROW_SIZE 150
#define COMPASS_SIZE 300
#if DEBUG
#define CHECKIN_DISTANCE 20 //meters
#else
#define CHECKIN_DISTANCE 60 //meters
#endif
//#define DEGREES_TO_RADIANS(x) (M_PI * x / 180.0)
#define DEGREES_TO_RADIANS(angle) ((angle) / 180.0 * M_PI)
#define STATUS_HEIGHT 50
#define NAVBAR_HEIGHT 44

@interface CompassViewController ()
@property (nonatomic, strong) UIImageView *arrow;
@property (nonatomic, strong) UIImageView *compass;
@property (nonatomic, weak) RouteFinishedView *routeFinishedView;
@property (nonatomic,strong) NavigationStatusView *statusView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *destinationLocation;
@property (nonatomic, strong) CLLocation *previousLocation;
@property (nonatomic, assign) BOOL checkinPending;
@property (nonatomic, strong) CloudView *cloudView;
@property (nonatomic, strong) DestinationRadarView *destinationRadarView;
@end

@implementation CompassViewController
@synthesize arrow, compass, statusView, cloudView, destinationRadarView;
@synthesize locationManager;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.checkinPending = NO;
        float latitude = [[[[AppState sharedInstance] activeWaypoint] objectForKey:@"latitude"] floatValue];
        float longitude = [[[[AppState sharedInstance] activeWaypoint] objectForKey:@"longitude"] floatValue];
        _destinationLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
        self.previousLocation = nil;
#if DEBUG
        NSLog(@"Destination: lat: %f long %f", latitude, longitude);
#endif
    }
    return self;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [cloudView stopAnimation];
    [[AppState sharedInstance] setPlayerIsInCompass:NO];
    [[AppState sharedInstance] save];
}

- (void)viewDidAppear:(BOOL)animated
{
    [cloudView startAnimation];
    [[AppState sharedInstance] setPlayerIsInCompass:YES];
    [[AppState sharedInstance] save];
#if DEBUG
    [self locationManager:nil didUpdateLocations:[NSArray arrayWithObject:_destinationLocation]];
#endif
}

#pragma mark - CLLocation

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    if (newHeading.headingAccuracy > 0) {
        float magneticHeading = newHeading.magneticHeading;
        float trueHeading = newHeading.trueHeading;

        //current heading in degrees and radians
        //use true heading if it is available
        float heading = (trueHeading > 0) ? trueHeading : magneticHeading;
        float heading_radians = DEGREES_TO_RADIANS(heading);

        
        compass.transform = CGAffineTransformMakeRotation(-1 * heading_radians); //set the compass to current heading
        
        CLLocationDirection destinationHeading = [locationManager.location directionToLocation:_destinationLocation];
        float adjusted_heading = destinationHeading - heading;
        float adjusted_heading_radians = DEGREES_TO_RADIANS(adjusted_heading);
        
        [UIView animateWithDuration:0.1 delay:0.0 options:
            UIViewAnimationOptionCurveLinear animations:^{
                CGAffineTransform transform = CGAffineTransformMakeRotation(adjusted_heading_radians);
                arrow.transform = transform;
                destinationRadarView.transform = transform;
            } completion:nil];
        
    }
}

//updates the statusview checkin display
-(void) updateCheckinStatus
{
    //update the statusview
    NSArray *waypoints = [[AppState sharedInstance].activeRoute objectForKey:@"waypoints"];
    NSArray *checkins = [[AppState sharedInstance] checkinsForRoute:[AppState sharedInstance].activeRouteId];
    [self.statusView setCheckinsComplete:[checkins count] ofTotal:[waypoints count]];
}


-(IBAction) finishRoute:(id)sender
{
    [_routeFinishedView removeFromSuperview];
}

- (IBAction)goToReward:(id)sender
{
    [_routeFinishedView removeFromSuperview];
}

- (void)addCheckInView
{
    NSString *langKey = [[AppState sharedInstance] language];
    CGRect gridRect = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - STATUS_HEIGHT);
    CheckinView *checkinView = [[CheckinView alloc] initWithFrame:CGRectInset(gridRect, 10, 10)];
    [checkinView setBodyText:[[[AppState sharedInstance] activeWaypoint] objectForKey:[NSString stringWithFormat:@"description_%@", langKey]]];
    [checkinView setTitle:NSLocalizedString(@"You can check-in!", nil)];
    
    checkinView.closeTarget = self;
    checkinView.closeAction = @selector(onCancelCheckIn);
    
    checkinView.buttonTarget = self;
    checkinView.buttonAction = @selector(onAcceptCheckIn);
    
    [self.view addSubview:checkinView];
#if DEBUG
    NSLog(@"add checkin view");
#endif
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    
    NSString * destinationName = [[[AppState sharedInstance] activeWaypoint] objectForKey:@"name_en"];
#if DEBUG
    NSLog(@"did update with destination: %@",destinationName);
#endif
    
    CLLocation *currentLocation = [locations lastObject];
    
    
    NSDate* eventDate = currentLocation.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (abs(howRecent) < 15.0) {
        
        // If the event is recent, do something with it.
        double distanceFromDestination = [currentLocation distanceFromLocation:_destinationLocation];
        [self.statusView update:destinationName withDistance:distanceFromDestination];
        
        if (distanceFromDestination < CHECKIN_DISTANCE) {
#if DEBUG
            NSLog(@"within distance");
#endif
            if(!self.checkinPending)
            {
                self.checkinPending = YES;
                [self addCheckInView];
            }
        }
    
        //if we have a previous location, determine sort of proximation speed
        if(self.previousLocation)
        {
            double previousDistanceFromDestination = [self.previousLocation distanceFromLocation:_destinationLocation];
            
            float pSpeed = (previousDistanceFromDestination - distanceFromDestination) / ([currentLocation.timestamp timeIntervalSinceNow] - [self.previousLocation.timestamp timeIntervalSinceNow]);
            cloudView.speed = pSpeed;
        }
        
        //update radar
        destinationRadarView.currentLocation = currentLocation;
        [destinationRadarView setNeedsDisplay];
        
        self.previousLocation = currentLocation;
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
    
    //custom back button
    CustomBarButtonView *backButton = [[CustomBarButtonView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)
                                                                       imageName:@"icon-back"
                                                                            text:@"Back"
                                                                          target:self
                                                                          action:@selector(onBackButton)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    
    //custom map button
    CustomBarButtonView *mapButton = [[CustomBarButtonView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)
                                                                      imageName:@"icon-map"
                                                                           text:nil
                                                                          target:self
                                                                          action:@selector(onMapButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:mapButton];
    
    
    //
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
#if DEBUG
        NSLog(@"heading available");
#endif
        [locationManager startUpdatingLocation];
        [locationManager startUpdatingHeading];
        
    } else {
        NSLog(@"Can't report heading");
    }
    
    CGPoint screenCenter = CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height / 2) - NAVBAR_HEIGHT);
    compass = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"compass"]];
    CGRect compassRect = CGRectMake(0, 0, COMPASS_SIZE, COMPASS_SIZE);
    [compass setFrame:compassRect];
    [compass setCenter:screenCenter];
    
    [self.view setBackgroundColor:[UIColor whiteColor]];
    UIImage *backgroundImage = [UIImage imageNamed:@"viewbackground"];
    UIImageView *background = [[UIImageView alloc] initWithImage:backgroundImage];
    background.contentMode = UIViewContentModeScaleAspectFit;
    [background setFrame:self.view.bounds];
    [self.view addSubview:background];
    
    CGRect gridRect = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - STATUS_HEIGHT);
    UIImage *gridImage = [UIImage imageNamed:@"compassbackground"];
    UIImageView *grid = [[UIImageView alloc] initWithImage:gridImage];
    grid.contentMode = UIViewContentModeScaleToFill;
    [grid setFrame:gridRect];
    [grid setCenter:screenCenter];
    
    
    UIImage * arrowImage = [UIImage imageNamed:@"arrow.png"];
    arrow = [[UIImageView alloc] initWithImage:arrowImage];
    arrow.contentMode = UIViewContentModeScaleAspectFit;
    
    //add arrow
    CGRect arrowRect = CGRectMake(0, 0, ARROW_SIZE, ARROW_SIZE);
    [arrow setFrame:arrowRect];
    [arrow setCenter:CGPointMake(screenCenter.x + 1, screenCenter.y)];//manual calibration
    
    //add clouds
    cloudView = [[CloudView alloc] initWithFrame:gridRect];
    
    //add radar make it square (bigger than frame) so it overlaps the whole grid always (also when rotated)
    float s = sqrtf(gridRect.size.width*gridRect.size.width+gridRect.size.height*gridRect.size.height);
    destinationRadarView = [[DestinationRadarView alloc] initWithFrame:CGRectMake(0, 0, s, s)];
    destinationRadarView.center = arrow.center;
    destinationRadarView.radius = 1500; //1.5 km
    destinationRadarView.checkinRadiusInPixels = 85; //radius of check in area in pix (edge of compass circle)
    destinationRadarView.checkinRadiusInMeters = CHECKIN_DISTANCE;
    
    [self.view addSubview:grid];
    [self.view addSubview:compass];
    [self.view addSubview:arrow];
    [self.view addSubview:destinationRadarView];
    [self.view addSubview:cloudView];
    [self.view setBackgroundColor:[UIColor whiteColor]];
    [self.view addSubview:self.statusView];
    
//    [cloudView startAnimation]; //it is already started when viewDidAppear
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - CustomButtonHandlers
- (void)onBackButton
{
    [self.navigationController popViewControllerAnimated:true];
}

- (void)onMapButton
{
    MapViewController *mvc = [[MapViewController alloc] init];
    mvc.waypoints = [[AppState sharedInstance] waypointsWithCheckinsForRoute: [[AppState sharedInstance] activeRouteId]];
    [self.navigationController pushViewController:mvc animated:YES];
}

- (void)onCancelCheckIn
{
    self.checkinPending = FALSE;
}

- (void)onAcceptCheckIn
{
    self.checkinPending = NO;
    
    //record the checkin as done
    [[AppState sharedInstance] checkIn];
    [self updateCheckinStatus];
    
    //change the active target
    if ([[AppState sharedInstance] setNextTarget])
    {        
        float latitude = [[[[AppState sharedInstance] activeWaypoint] objectForKey:@"latitude"] floatValue];
        float longitude = [[[[AppState sharedInstance] activeWaypoint] objectForKey:@"longitude"] floatValue];
        _destinationLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
#if DEBUG
        NSLog(@"Destination: lat: %f long %f", latitude, longitude);
#endif
        [destinationRadarView setNeedsDisplay];
    }
    else
    {
        //remove the compas, notify the delegate that route was done
        //so it can show the reward
        [self.delegate onRouteFinished];
        [self.navigationController popViewControllerAnimated:true];
    }
}

@end
