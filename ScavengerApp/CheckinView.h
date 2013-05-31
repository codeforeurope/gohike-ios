//
//  CheckinView.h
//  ScavengerApp
//
//  Created by Taco van Dijk on 5/23/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckinView : UIView

@property (nonatomic, weak) IBOutlet UITextView *locationTextView;
@property (nonatomic, weak) IBOutlet UILabel *checkInLabel;
@property (nonatomic, assign) id target;
@property (nonatomic) SEL action;

@end
