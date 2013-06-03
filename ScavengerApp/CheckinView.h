//
//  CheckinView.h
//  ScavengerApp
//
//  Created by Taco van Dijk on 5/23/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CheckinView : UIView
{
    UITextView *bodyTextView;
    UILabel *titleLabel;
}

- (void)setTitle:(NSString*)text;
- (void)setBodyText:(NSString*)text;

@property (nonatomic, assign) id closeTarget;
@property (nonatomic) SEL closeAction;
@property (nonatomic, assign) id buttonTarget;
@property (nonatomic) SEL buttonAction;

@end
