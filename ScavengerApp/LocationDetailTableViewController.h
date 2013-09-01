//
//  LocationDetailTableViewController.h
//  GoHikeAmsterdam
//
//  Created by Giovanni on 9/1/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationDetailTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate> {
    UIImageView     *_imageView;
    UIScrollView    *_imageScroller;
    UITableView     *_tableView;
}

- (id)initWithImage:(UIImage *)image;@property (nonatomic, strong) GHWaypoint *location;

@end
