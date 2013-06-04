//
//  RewardViewController.m
//  ScavengerApp
//
//  Created by Giovanni on 5/27/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <Social/Social.h>
#import "RewardViewController.h"
#import "CustomBarButtonView.h"

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
    CustomBarButtonView *backButton = [[CustomBarButtonView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)
                                                                       imageName:@"icon-back"
                                                                            text:@"Back"
                                                                          target:self
                                                                          action:@selector(onBackButton)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    CustomBarButtonView *shareButton = [[CustomBarButtonView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)
                                                                         imageName:@"icon-facebook"
                                                                              text:nil
                                                                            target:self
                                                                            action:@selector(onShareButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onShareButton
{
    SLComposeViewController*fvc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    [fvc setInitialText:NSLocalizedString(@"I've completed the go-hike Amsterdam experience", nil)];
    [fvc addImage:[UIImage imageNamed:@"pin"]];
    [self presentViewController:fvc animated:YES completion:nil];
}

- (void)onBackButton
{
    [self.navigationController popViewControllerAnimated:true];
}

@end
