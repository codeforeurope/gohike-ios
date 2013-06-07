//
//  CustomBarButtonView.h
//  ScavengerApp
//
//  Created by Lodewijk Loos on 30-05-13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomBarButtonView : UIView


- (id)initWithFrame:(CGRect)frame imageName:(NSString*)imageName textRight:(NSString*)textRight textLeft:(NSString*)textLeft target:(id)aTarget action:(SEL)aAction;

@property (nonatomic) SEL action;
@property (nonatomic,assign) id target;

@end
