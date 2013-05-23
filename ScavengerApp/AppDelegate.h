//
//  AppDelegate.h
//  ScavengerApp
//
//  Created by Giovanni on 5/15/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AppState.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) UINavigationController *navigationController;

@property (strong, nonatomic) AppState *appState;

@end
