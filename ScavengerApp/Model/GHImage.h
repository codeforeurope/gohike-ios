//
//  GHImage.h
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/28/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GHImage : NSObject

@property (nonatomic, copy) NSString *GHurl;
@property (nonatomic, copy) NSString *GHmd5;

-(id)initWithDictionary:(NSDictionary*)dictionary;

@end
