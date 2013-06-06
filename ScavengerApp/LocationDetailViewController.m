//
//  LocationDetailViewController.m
//  ScavengerApp
//
//  Created by Giovanni on 5/28/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "LocationDetailViewController.h"
#import "CompassViewController.h"
#import "QuartzCore/CALayer.h"
#import "CustomBarButtonView.h"
#import "MapViewController.h"

@interface LocationDetailViewController ()

@end

@implementation LocationDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)awakeFromNib {
    _locationImageView.layer.shadowColor = [UIColor blackColor].CGColor;
    _locationImageView.layer.shadowOffset = CGSizeMake(0, 2);
    _locationImageView.layer.shadowOpacity = 1;
    _locationImageView.layer.shadowRadius = 1.0;
    _locationImageView.clipsToBounds = NO;
}

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
    
    //route info
    NSString *langKey = [[AppState sharedInstance] language];
    if([_location objectForKey:@"image_data"])
        self.locationImageView.image = [UIImage imageWithData:[NSData dataWithBase64EncodedString:[_location objectForKey:@"image_data"]]];
    self.locationText.text = [_location objectForKey:[NSString stringWithFormat:@"description_%@",langKey]];
    self.locationTitleLabel.text = [_location objectForKey:[NSString stringWithFormat:@"name_%@", langKey]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)replayLocation
{
    NSArray *waypoints = [[[AppState sharedInstance] activeRoute] objectForKey:@"waypoints"];
    NSDictionary *thisWayPoint;
    
    NSUInteger index = [waypoints indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return [[obj objectForKey:@"location_id"] integerValue] == [[_location objectForKey:@"location_id"] intValue];
    }];
    if (index == NSNotFound) {
        
    }
    else {
        thisWayPoint = [waypoints objectAtIndex:index];
    }
    
    if([waypoints count] > 0)
    {
        [[AppState sharedInstance] setActiveRouteId: [[_location objectForKey:@"route_id"] intValue]];
        [[AppState sharedInstance] setActiveTargetId: [[_location objectForKey:@"location_id"] intValue]];
        [[AppState sharedInstance] save];
        
        NSLog(@"Active Target ID = %d",[[AppState sharedInstance] activeTargetId]);
        
        CompassViewController *compass = [[CompassViewController alloc] init];
//        [compass setReplay:YES]; //TODO: set we are replaying
        [self.navigationController pushViewController:compass animated:YES];
        
    }
}

- (void)onMapButton
{
    MapViewController *mvc = [[MapViewController alloc] init];
    mvc.waypoints = [NSArray arrayWithObject:self.location];
    [self.navigationController pushViewController:mvc animated:YES];
}

- (void)onBackButton
{
    [self.navigationController popViewControllerAnimated:TRUE];
}

@end
