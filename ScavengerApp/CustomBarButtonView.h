//
//  CustomBarButtonView.h
//  ScavengerApp
//
//  Created by Lodewijk Loos on 30-05-13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomBarButtonView : UIView


- (id)initWithFrame:(CGRect)frame imageName:(NSString*)imageName text:(NSString*)text target:(id)target action:(SEL)selector;

@property (nonatomic) SEL action;
@property (nonatomic,assign) id target;

@end
