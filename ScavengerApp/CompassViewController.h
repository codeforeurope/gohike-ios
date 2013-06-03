//
//  CompassViewController.h
//  ScavengerApp
//
//  Created by Taco van Dijk on 5/21/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

#define DUMMY_LATITUDE 52.34444
#define DUMMY_LONGITUDE 4.91667

@protocol CompassViewControllerDelegate;

@interface CompassViewController : UIViewController <CLLocationManagerDelegate>


@property (nonatomic,assign) id<CompassViewControllerDelegate> delegate;

/* still needed?
-(IBAction) checkIn;
-(IBAction) finishRoute:(id)sender;
-(IBAction) goToReward:(id)sender;
*/


@end

@protocol CompassViewControllerDelegate

- (void)onRouteFinished;

@end
