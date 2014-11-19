//
//  CitiesOverlayView.h
//  GoHikeAmsterdam
//
//  Created by Giovanni on 9/4/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CitiesOverlayView : UIView

@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *dismissButton;

@property (nonatomic, weak) IBOutlet UITextView *textView;


@end
