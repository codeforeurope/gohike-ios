//
//  GHImage.m
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/28/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "GHImage.h"

@implementation GHImage

-(id)initWithDictionary:(NSDictionary*)dictionary
{
    self = [super init];
    if (self) {
        self.GHmd5 = [dictionary objectForKey:@"md5"];
        self.GHurl = [dictionary objectForKey:@"url"];
    }
    return self;
}

@end
