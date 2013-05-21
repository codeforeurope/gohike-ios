//
//  RouteStartViewController.h
//  ScavengerApp
//
//  Created by Giovanni on 5/15/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RouteStartViewController : UITableViewController

@property (nonatomic, assign) int routeID;
@property (nonatomic, strong) NSString *routeTitle;
@property (nonatomic, strong) NSString *routeDescription;

@end
