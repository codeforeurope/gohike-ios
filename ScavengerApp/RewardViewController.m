//
//  RewardViewController.m
//  ScavengerApp
//
//  Created by Giovanni on 5/27/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <Social/Social.h>
#import "RewardViewController.h"
#import "CustomBarButtonViewLeft.h"
#import "CustomBarButtonViewRight.h"

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
    CustomBarButtonViewLeft *backButton = [[CustomBarButtonViewLeft alloc] initWithFrame:CGRectMake(0, 0, 32, 32)
                                                                       imageName:@"icon-back"
                                                                            text:NSLocalizedString(@"Back", nil)
                                                                          target:self
                                                                          action:@selector(onBackButton)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    CustomBarButtonViewLeft *shareButton = [[CustomBarButtonViewLeft alloc] initWithFrame:CGRectMake(0, 0, 32, 32)
                                                                         imageName:@"icon-facebook"
                                                                              text:nil
                                                                            target:self
                                                                            action:@selector(onShareButton)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:shareButton];
    
    
    NSString *langKey = [[AppState sharedInstance] language];
    _rewardTitle.text = [_reward objectForKey:[NSString stringWithFormat:@"name_%@", langKey]];
    _rewardDescription.text = [_reward objectForKey:[NSString stringWithFormat:@"description_%@", langKey]];
    _rewardImage.image = [UIImage imageWithData:[NSData dataWithBase64EncodedString:[_reward objectForKey:@"image_data"]]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onShareButton
{
    SLComposeViewController*fvc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    
    [fvc setInitialText:[NSString stringWithFormat:NSLocalizedString(@"FacebookMessage", nil),_rewardTitle.text]];
    //[fvc setInitialText:NSLocalizedString(@"I am the first Amsterdam explorer with the Take a Hike Amsterdam App! Have a look at http://http://www.gotakeahike.nl/", nil)];
    [fvc addImage:[_rewardImage image]];
    [self presentViewController:fvc animated:YES completion:nil];
}

- (void)onBackButton
{
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)badgeTapped:(UITapGestureRecognizer*)sender
{
    NSLog(@"Badge tapped");
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"SavePictureQuestion", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Don't save", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Save", nil), nil];
    [actionSheet showInView:self.view];
}

#pragma mark - Action sheet delegates

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex

{
    if(buttonIndex == 0)
    {
        UIImage* imageToSave = [_rewardImage image]; // alternatively, imageView.image
        
        // Save it to the camera roll / saved photo album
        UIImageWriteToSavedPhotosAlbum(imageToSave, nil, nil, nil);
    }
}

@end
