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

@interface CompassViewController : UIViewController <CLLocationManagerDelegate>
   -(IBAction) checkIn;
@end
