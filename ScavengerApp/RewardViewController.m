//
//  RewardViewController.m
//  ScavengerApp
//
//  Created by Giovanni on 5/27/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "RewardViewController.h"

@interface RewardViewController ()

@end

@implementation RewardViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Share on Facebook!", nil) style:UIBarButtonItemStylePlain target:self action:@selector(shareButtonTapped)];
    self.navigationItem.rightBarButtonItem = shareButton;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)shareButtonTapped
{
    //TODO: Share on Facebook using the integrated facebook 
}

@end
