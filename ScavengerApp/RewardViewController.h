//
//  RewardViewController.h
//  ScavengerApp
//
//  Created by Giovanni Maggini on 5/27/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RewardViewController : UIViewController <UIActionSheetDelegate>

@property (nonatomic, weak) IBOutlet UIImageView *rewardImage;
@property (nonatomic, weak) IBOutlet UILabel *rewardTitle;
@property (nonatomic, weak) IBOutlet UILabel *rewardDescription;

@property (nonatomic, strong) NSDictionary *reward;


- (IBAction)badgeTapped:(UITapGestureRecognizer*)sender;


@end
