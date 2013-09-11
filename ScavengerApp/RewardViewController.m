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


@interface RewardViewController () <FBLoginViewDelegate>

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

- (void)fixUIForiOS7
{
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        [self setEdgesForExtendedLayout:UIRectEdgeNone];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Fix UI for iOS7
    [self fixUIForiOS7];
    
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
    
    BOOL isFacebookLoggedIn = (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded || FBSession.activeSession.state == FBSessionStateOpen);
    if(isFacebookLoggedIn){
        //If Facebook IsLoggedIn then we can go for publish directly
    
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
                                                     [self confirmPublishStory];
                                                 }
                                             }];
        } else {
            // If permissions present, publish the story
            [self confirmPublishStory];
        }
    }
    else{
        //We have no FB Connection, we need to open it, and register the user if has not registered already to API
        [self openSession];
    }

}

- (void)confirmPublishStory
{
    SIAlertView *a = [[SIAlertView alloc] initWithTitle:nil andMessage:NSLocalizedString(@"Share the reward with your Facebook friends?", @"Share the reward with your Facebook friends?")];
    [a addButtonWithTitle:NSLocalizedString(@"No", nil) type:SIAlertViewButtonTypeCancel handler:^(SIAlertView *alertView) { [alertView dismissAnimated:YES];   }];
    [a addButtonWithTitle:NSLocalizedString(@"Yes!", nil) type:SIAlertViewButtonTypeDefault handler:^(SIAlertView *alertView) { [self publishStory];  }];
    a.transitionStyle = SIAlertViewTransitionStyleBounce;
    a.backgroundStyle = SIAlertViewBackgroundStyleSolid;
    [a show];
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
             alertText = NSLocalizedString(@"Posted successfully!", nil);
         }
         
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

#pragma mark - Privacy

- (void)dealWithPrivacy
{
    NSString *facebookUsername = [SSKeychain passwordForService:kServiceNameForKeychain account:kAccountNameForKeychainFacebook];
    
    if(![facebookUsername length] > 0)
    {
        NSString *title = NSLocalizedString(@"PrivacyAlertViewTitle", @"Connect with Take a Hike?");
        NSString *message = NSLocalizedString(@"PrivacyAlertViewMessage", @"By continuing, you agree with Take a Hike Terms of Use and Privacy Policy.");
        NSString *termsButtonText = NSLocalizedString(@"PrivacyTermsButtonText", @"View Tems of Use");
        NSString *privacyButtonText = NSLocalizedString(@"PrivacyButtonText", @"View Provacy Policy");
        NSString *agreeTerms = NSLocalizedString(@"PrivacyAgree", @"I agree");
        NSString *dontagreeTerms = NSLocalizedString(@"PrivacyNotAgree", @"I do not agree");
        
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:title andMessage:message];
        [alertView addButtonWithTitle:termsButtonText
                                 type:SIAlertViewButtonTypeCancel
                              handler:^(SIAlertView *alertView) {
                                  NSURL *url = [NSURL URLWithString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"TermsOfUseURL"]];
                                  [[UIApplication sharedApplication] openURL:url];
                                  
                              }];
        [alertView addButtonWithTitle:privacyButtonText
                                 type:SIAlertViewButtonTypeCancel
                              handler:^(SIAlertView *alertView) {
                                  NSURL *url = [NSURL URLWithString:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"PrivacyPolicyURL"]];
                                  [[UIApplication sharedApplication] openURL:url];
                                  
                              }];
        [alertView addButtonWithTitle:dontagreeTerms
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                                  [alertView dismissAnimated:NO];
                              }];
        [alertView addButtonWithTitle:agreeTerms
                                 type:SIAlertViewButtonTypeDefault
                              handler:^(SIAlertView *alertView) {
                                  [alertView dismissAnimated:NO];
                                  [self openSession];
                              }];
        alertView.transitionStyle = SIAlertViewTransitionStyleDropDown;
        alertView.backgroundStyle = SIAlertViewBackgroundStyleSolid;
        alertView.didDismissHandler = ^(SIAlertView *alertView) {
        };
        [alertView show];
    }
    else{
        //user has already opted in before
        [self openSession];
        
    }
}

#pragma mark - Facebook

- (void)sessionStateChanged:(FBSession *)session
                      state:(FBSessionState) state
                      error:(NSError *)error
{
    switch (state) {
        case FBSessionStateOpen: {
#if DEBUG
            NSLog(@"facebook session open");
#endif
            //first we get the user details
            [self getUserDetails];
            

            
        }
            break;
        case FBSessionStateClosed:
        case FBSessionStateClosedLoginFailed:
            [FBSession.activeSession closeAndClearTokenInformation];
            
            break;
        default:
            break;
    }
    
    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:NSLocalizedString(@"Facebook Error", @"Facebook Error")
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }
}


- (void)getUserDetails
{
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection,
           NSDictionary<FBGraphUser> *user,
           NSError *error) {
             if (!error) {
#if DEBUG
                 NSLog(@"we got user: %@", user);
#endif
                 [SSKeychain setPassword:user.name forService:kServiceNameForKeychain account:kAccountNameForKeychainFacebook];
                 [self connectUser:user];
             }
         }];
    }
}

- (void)connectUser:(NSDictionary<FBGraphUser> *)user
{
    @try {
        NSString *username = user.first_name;
        NSString *FBid = [NSString stringWithFormat:@"%@", user.id];
        NSString *email = [user objectForKey:@"email"];
        NSDate *expirationDate = FBSession.activeSession.accessTokenData.expirationDate;
        NSString *token = FBSession.activeSession.accessTokenData.accessToken;
        
        [[GoHikeHTTPClient sharedClient] connectFBId:FBid name:username email:email token:token expDate:expirationDate];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", [exception description]);
    }
    @finally {
        //we finally publish the story
        [self confirmPublishStory];
    }
}

- (void)openSession
{
    [FBSession openActiveSessionWithReadPermissions:@[@"email"]
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session,
       FBSessionState state, NSError *error) {
         [self sessionStateChanged:session state:state error:error];
     }];
}

@end
