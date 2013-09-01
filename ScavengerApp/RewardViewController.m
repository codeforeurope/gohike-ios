//
//  RewardViewController.m
//  ScavengerApp
//
//  Created by Giovanni Maggini on 5/27/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <Social/Social.h>
#import "RewardViewController.h"
#import "CustomBarButtonViewLeft.h"
#import "CustomBarButtonViewRight.h"
#import "SIAlertView.h"
#import <FacebookSDK/FacebookSDK.h>

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
    
    _rewardTitle.text = [_reward GHname];
    _rewardDescription.text = [_reward GHdescription];
    _rewardImage.image = [UIImage imageWithData:[FileUtilities imageDataForReward:_reward]];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)onShareButton
{
    // Ask for publish_actions permissions in context
    if ([FBSession.activeSession.permissions
         indexOfObject:@"publish_actions"] == NSNotFound) {
        // Permission hasn't been granted, so ask for publish_actions
        [FBSession openActiveSessionWithPublishPermissions:@[@"publish_actions"]
                                           defaultAudience:FBSessionDefaultAudienceFriends
                                              allowLoginUI:YES
                                         completionHandler:^(FBSession *session, FBSessionState state, NSError *error) {
                                             if (FBSession.activeSession.isOpen && !error) {
                                                 // Publish the story if permission was granted
                                                 [self publishStory];
                                             }
                                         }];
    } else {
        // If permissions present, publish the story
        [self publishStory];
    }
    
    //Old
//    SLComposeViewController*fvc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
//    
//    [fvc setInitialText:[NSString stringWithFormat:NSLocalizedString(@"FacebookMessage", nil),_rewardTitle.text]];
//    //[fvc setInitialText:NSLocalizedString(@"I am the first Amsterdam explorer with the Take a Hike Amsterdam App! Have a look at http://http://www.gotakeahike.nl/", nil)];
//    [fvc addImage:[_rewardImage image]];
//    [self presentViewController:fvc animated:YES completion:nil];
}

- (void)publishStory
{
    
    
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    params[@"link"] = [NSString stringWithFormat:@"%@/rewards/%d",kGOHIKE_BASEURL, [_reward GHid] ];
    params[@"name"] = [_reward GHname];
    params[@"description"] = [_reward GHdescription];
//    params[@"message"] = [NSString stringWithFormat:NSLocalizedString(@"FacebookMessage", nil),_rewardTitle.text];
    
    [FBRequestConnection
     startWithGraphPath:@"me/feed"
     parameters:params
     HTTPMethod:@"POST"
     completionHandler:^(FBRequestConnection *connection,
                         id result,
                         NSError *error) {
         NSString *alertText;
         NSString *alertTitle;
         if (error) {
             alertTitle = @"Result";
             alertText = [NSString stringWithFormat:
                          @"error: domain = %@, code = %d",
                          error.domain, error.code];
         } else {
             alertTitle = NSLocalizedString(@"Done!", @"Alertview title");
//             alertText = [NSString stringWithFormat:
//                          @"Posted action, id: %@",
//                          result[@"id"]];
             alertText = NSLocalizedString(@"Posted successfully!", nil);
         }
         // Show the result in an alert
         [[[UIAlertView alloc] initWithTitle:@"Result"
                                     message:alertText
                                    delegate:self
                           cancelButtonTitle:@"OK!"
                           otherButtonTitles:nil]
          show];
         
         SIAlertView *a = [[SIAlertView alloc] initWithTitle:alertTitle andMessage:alertText];
         [a addButtonWithTitle:NSLocalizedString(@"Ok", nil) type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) { [alertView dismissAnimated:YES];   }];
         a.transitionStyle = SIAlertViewTransitionStyleBounce;
         a.backgroundStyle = SIAlertViewBackgroundStyleSolid;
         [a show];
     }];
}

- (void)onBackButton
{
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)badgeTapped:(UITapGestureRecognizer*)sender
{
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
        UIImageWriteToSavedPhotosAlbum(imageToSave, self, @selector(imageSaved), nil);
    }
}

- (void)imageSaved
{
    SIAlertView *a = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Done!", nil) andMessage:nil];
    [a addButtonWithTitle:NSLocalizedString(@"Ok!", nil) type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView)  { [alertView dismissAnimated:YES];   }];
    a.transitionStyle = SIAlertViewTransitionStyleBounce;
    a.backgroundStyle = SIAlertViewBackgroundStyleSolid;

    [a show];
}

@end
