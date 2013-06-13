//
//  LocationDetailViewController.h
//  ScavengerApp
//
//  Created by Giovanni Maggini on 5/28/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LocationDetailViewController : UIViewController

@property (nonatomic, strong) NSDictionary *location;
@property (nonatomic, weak) IBOutlet UILabel *locationTitleLabel;
@property (nonatomic, weak) IBOutlet UIImageView *locationImageView;
@property (nonatomic, weak) IBOutlet UITextView *locationText;
@property (nonatomic, weak) IBOutlet UILabel *locationDescriptionLabel;


@end
