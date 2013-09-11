//
//  CompassViewController.m
//  ScavengerApp
//
//  Created by Taco van Dijk on 5/21/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "CompassViewController.h"

#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>

#import "CLLocation+measuring.h"

#import "CheckinView.h"

#import "NavigationStatusView.h"

#import "CompassTopView.h"

#import "CustomBarButtonViewLeft.h"
#import "CustomBarButtonViewRight.h"

#import "CloudView.h"

#import "DestinationRadarView.h"

#import "MapViewController.h"

#import "SIAlertView.h"

#define ARROW_SIZE 200
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
@property (nonatomic, strong) IBOutlet UIImageView *arrow;
@property (nonatomic, strong) IBOutlet UIImageView *compass;
@property (nonatomic, strong) IBOutlet UILabel *labelDistance;
@property (nonatomic,strong) NavigationStatusView *statusView;
//@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *destinationLocation;
@property (nonatomic, strong) CLLocation *previousLocation;
@property (nonatomic, assign) BOOL checkinPending;
@property (nonatomic, strong) CloudView *cloudView;
@property (nonatomic, strong) DestinationRadarView *destinationRadarView;
@property (nonatomic, strong) CompassTopView *topView;
@end

@implementation CompassViewController
@synthesize arrow, compass, statusView, cloudView, destinationRadarView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        self.checkinPending = NO;
        float latitude = [[[AppState sharedInstance] activeWaypoint] GHlatitude];
        float longitude = [[[AppState sharedInstance] activeWaypoint] GHlongitude];
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
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLocationServicesGotBestAccuracyLocation object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLocationServicesUpdateHeading object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kLocationServicesEnteredDestinationRegion object:nil];
    
    [cloudView stopAnimation];
    [[AppState sharedInstance] setPlayerIsInCompass:NO];
    [[AppState sharedInstance] save];
    
    [[AppState sharedInstance] stopLocationServices];
}

- (void)viewDidAppear:(BOOL)animated
{
    //start location services
    [[AppState sharedInstance] startLocationServices];
    [[AppState sharedInstance] startMonitoringForDestination];

    
    //register for notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleHeadingUpdate:) name:kLocationServicesUpdateHeading object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLocationUpdate:) name:kLocationServicesGotBestAccuracyLocation object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleEnteredRegion:) name:kLocationServicesEnteredDestinationRegion object:nil];
    
    [cloudView startAnimation];
    [[AppState sharedInstance] setPlayerIsInCompass:YES];
    [[AppState sharedInstance] save];
#if DEBUG
    [[AppState sharedInstance] locationManager:nil didUpdateLocations:[NSArray arrayWithObject:_destinationLocation]];
#endif
}

#pragma mark - CLLocation

//updates the statusview checkin display
-(void) updateCheckinStatus
{
    //update the statusview
    NSArray *waypointsWithCheckins = [[AppState sharedInstance] waypointsWithCheckinsForRoute:[AppState sharedInstance].activeRouteId];
    [self.statusView setCheckinsCompleteWithArray:waypointsWithCheckins nextLocationId:[[AppState sharedInstance] activeTargetId]];
    
}

- (void)updateLabelsWithDistance:(double)distance destination:(NSString*)destination
{
    if(distance > 1000){
        self.labelDistance.text = [NSString stringWithFormat:@"%.2f km",distance/1000];
    }
    else{
        self.labelDistance.text = [NSString stringWithFormat:@"%.0f m",distance];
    }
    
    self.topView.label.text = destination;


}

- (void)scheduleLocalNotification
{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    notification.alertBody = NSLocalizedString(@"NotificationAlertBody", @"You are close to the next check-in!");
    notification.alertAction = NSLocalizedString(@"NotificationAlertAction", @"Check-in");
    [[UIApplication sharedApplication] presentLocalNotificationNow:notification];
}


- (void)addCheckInView
{
    if([UIApplication sharedApplication].applicationState != UIApplicationStateActive)
    {
        [self scheduleLocalNotification];
    }

    
    CGRect gridRect = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - STATUS_HEIGHT);
    CheckinView *checkinView = [[CheckinView alloc] initWithFrame:CGRectInset(gridRect, 10, 10)];
    NSString *destinationName = [[[AppState sharedInstance] activeWaypoint] GHname];
    
    [checkinView setBodyText:[NSString stringWithFormat:NSLocalizedString(@"LocationFound", @"Text for checkin view when lcation is found: Look around! You're close to %@, can you see it?"), destinationName]];
    [checkinView setTitle:NSLocalizedString(@"You are almost there!", nil)];
    [checkinView setDestinationImage:[FileUtilities imageDataForWaypoint:[[AppState sharedInstance] activeWaypoint]]];
    checkinView.closeTarget = self;
    checkinView.closeAction = @selector(onCancelCheckIn);
    
    checkinView.buttonTarget = self;
    checkinView.buttonAction = @selector(onAcceptCheckIn);
    
    [self.view addSubview:checkinView];
    
    //Play sound
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"success" ofType:@"mp3"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    AudioServicesPlaySystemSound (soundID);
    
}

- (void)handleLocationUpdate:(NSNotification*)notification
{
    NSString * destinationName = [[[AppState sharedInstance] activeWaypoint] GHname];
 
#if DEBUG
    NSLog(@"did update with destination: %@",destinationName);
#endif
    
    CLLocation *currentLocation = [[AppState sharedInstance] currentLocation];

    // If the event is recent, get the distance from destination
    double distanceFromDestination = [currentLocation distanceFromLocation:_destinationLocation];
    //update all the labels and navigation bars
    [self updateLabelsWithDistance:distanceFromDestination destination:destinationName];
//    [self.statusView update:destinationName withDistance:distanceFromDestination];
//    [self.topView updateDistance:distanceFromDestination];
    
    if (distanceFromDestination < CHECKIN_DISTANCE) {
//#if DEBUG
//        NSLog(@"within distance");
//#endif
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

- (void)handleHeadingUpdate:(NSNotification*)notification
{
    float heading = [[[notification userInfo] objectForKey:@"heading"] floatValue];
    float heading_radians = DEGREES_TO_RADIANS(heading);

    compass.transform = CGAffineTransformMakeRotation(-1 * heading_radians); //set the compass to current heading
    
    CLLocationDirection destinationHeading = [[[AppState sharedInstance] currentLocation] directionToLocation:_destinationLocation];
    float adjusted_heading = destinationHeading - heading;
    float adjusted_heading_radians = DEGREES_TO_RADIANS(adjusted_heading);
    
    [UIView animateWithDuration:0.1 delay:0.0 options:
     UIViewAnimationOptionCurveLinear animations:^{
         CGAffineTransform transform = CGAffineTransformMakeRotation(adjusted_heading_radians);
         arrow.transform = transform;
         destinationRadarView.transform = transform;
     } completion:nil];
}

- (void)handleEnteredRegion:(NSNotification*)notification
{
    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"EnteredRegionAlertTitle", @"Almost there!") andMessage:NSLocalizedString(@"EnteredRegionAlertMessage", @"You are getting closer to the next location!")];
    [alertView addButtonWithTitle:NSLocalizedString(@"EnteredRegionAlertOk", @"Yeah!")
                             type:SIAlertViewButtonTypeDefault
                          handler:^(SIAlertView *alertView) {
                              [alertView dismissAnimated:YES];
                          }];
    alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
    alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
    alertView.didDismissHandler = ^(SIAlertView *alertView) {
    };
    [alertView show];
}


#pragma mark - UIViewController

- (void)fixUIForiOS7
{
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Fix UI for iOS7
    [self fixUIForiOS7];

    //buttons
    [self customizeButtons];
    
    
    //Constraints. Watch out when animating!
//    NSLayoutConstraint *constrainArrow = [NSLayoutConstraint constraintWithItem:arrow
//                                                                 attribute:NSLayoutAttributeCenterY
//                                                                 relatedBy:NSLayoutRelationEqual
//                                                                    toItem:self.view
//                                                                 attribute:NSLayoutAttributeCenterY
//                                                                multiplier:1.1
//                                                                  constant:0];
//    
//    NSLayoutConstraint *constrainCompass = [NSLayoutConstraint constraintWithItem:compass
//                                                                        attribute:NSLayoutAttributeCenterY
//                                                                        relatedBy:NSLayoutRelationEqual
//                                                                           toItem:self.view
//                                                                        attribute:NSLayoutAttributeCenterY
//                                                                       multiplier:1.1
//                                                                         constant:0];
//    [self.view addConstraints:@[constrainArrow, constrainCompass]];
    
    //UI
    CGRect frame, remain;
    CGRectDivide(self.view.bounds, &frame, &remain, STATUS_HEIGHT, CGRectMaxYEdge);
    self.statusView = [[[NSBundle mainBundle] loadNibNamed:@"NavigationStatusView" owner:self options:nil] objectAtIndex:0];
    [self.statusView setFrame:frame];
    [self.statusView setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
    [self updateCheckinStatus];

    
//    CGPoint screenCenter = CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height / 2) - NAVBAR_HEIGHT);
    CGPoint screenCenterProportional = CGPointMake(self.view.frame.size.width / 2, (self.view.frame.size.height / 10 * 6) - NAVBAR_HEIGHT);
    
    CGRect compassRect = CGRectMake(0, 0, COMPASS_SIZE, COMPASS_SIZE);
    [compass setFrame:compassRect];
    [compass setCenter:screenCenterProportional];
        
    CGRect gridRect = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - STATUS_HEIGHT);

    //shadow stuff
    arrow.layer.shadowOffset = CGSizeMake(1.0f, 2.0f);
    arrow.layer.shadowColor = [[UIColor blackColor] CGColor] ;
    arrow.layer.shadowOpacity = 0.8f;
//    arrow.layer.shadowRadius = 1.0f;
    arrow.layer.masksToBounds = YES;
//    UIBezierPath *path = [UIBezierPath bezierPathWithRect:arrow.bounds];
//    arrow.layer.shadowPath = path.CGPath;
    
    //add arrow
    CGRect arrowRect = CGRectMake(0, 0, ARROW_SIZE, ARROW_SIZE);
    [arrow setFrame:arrowRect];
    [arrow setCenter:CGPointMake(screenCenterProportional.x + 1, screenCenterProportional.y)];//manual calibration
    
    //add clouds
    cloudView = [[CloudView alloc] initWithFrame:gridRect];
    
    //add radar make it square (bigger than frame) so it overlaps the whole grid always (also when rotated)
    float s = sqrtf(gridRect.size.width*gridRect.size.width+gridRect.size.height*gridRect.size.height);
    destinationRadarView = [[DestinationRadarView alloc] initWithFrame:CGRectMake(0, 0, s, s)];
    destinationRadarView.center = arrow.center;
    destinationRadarView.radius = 1500; //1.5 km
    destinationRadarView.checkinRadiusInPixels = 85; //radius of check in area in pix (edge of compass circle)
    destinationRadarView.checkinRadiusInMeters = CHECKIN_DISTANCE;
    
    
    //add top view with distance
    _topView = [[[NSBundle mainBundle] loadNibNamed:@"CompassTopView" owner:self options:nil] objectAtIndex:0];
    
    
    [self.view addSubview:destinationRadarView];
    [self.view addSubview:cloudView];
    [self.view addSubview:self.statusView];
    [self.view addSubview:_topView];
        
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)customizeButtons
{
    //custom back button
    CustomBarButtonViewLeft *backButton = [[CustomBarButtonViewLeft alloc] initWithFrame:CGRectMake(0, 0, 32, 32)
                                                                               imageName:@"icon-back"
                                                                                    text:NSLocalizedString(@"Back", nil)
                                                                                  target:self
                                                                                  action:@selector(onBackButton)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    
    //custom map button
    CustomBarButtonViewRight *mapButton = [[CustomBarButtonViewRight alloc] initWithFrame:CGRectMake(0, 0, 32, 32)
                                                                                imageName:@"icon-map"
                                                                                     text:nil
                                                                                   target:self
                                                                                   action:@selector(onMapButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:mapButton];
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
    
    //Play a fanfare sound
    NSString *soundPath = [[NSBundle mainBundle] pathForResource:@"fanfare" ofType:@"mp3"];
    SystemSoundID soundID;
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &soundID);
    AudioServicesPlaySystemSound (soundID);
    
    //record the checkin as done
    [[AppState sharedInstance] checkIn];
    [self updateCheckinStatus];
    
    //change the active target
    if ([[AppState sharedInstance] setNextTarget])
    {
        [[AppState sharedInstance] startMonitoringForDestination];
        [self updateCheckinStatus]; //this is to set the new color on the current destination
        float latitude = [[[AppState sharedInstance] activeWaypoint] GHlatitude];
        float longitude = [[[AppState sharedInstance] activeWaypoint] GHlongitude];
        _destinationLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
#if DEBUG
        NSLog(@"Destination: %@ lat: %f long %f", [[[AppState sharedInstance] activeWaypoint] GHname], latitude, longitude);
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
