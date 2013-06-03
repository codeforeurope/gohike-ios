//
//  RouteStartViewController.h
//  ScavengerApp
//
//  Created by Giovanni on 5/15/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CompassViewController.h"


@interface RouteStartViewController : UITableViewController<CompassViewControllerDelegate> // <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSDictionary *route;

@end
