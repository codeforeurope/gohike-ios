//
//  Location.h
//  ScavengerApp
//
//  Created by Taco van Dijk on 5/23/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Location : NSObject

@property (nonatomic, assign) int locationId;
@property (nonatomic, strong) NSString *locationName;
@property (nonatomic, strong) NSString *locationPicture;
@property (nonatomic, assign) double latitude;
@property (nonatomic, assign) double longitude;


@end
