//
//  GoHikeHTTPClient.h
//  GoHikeAmsterdam
//
//  Created by Giovanni on 8/25/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import "AFHTTPClient.h"


extern NSString* const kFinishedLoadingCatalog;
extern NSString* const kFinishedLoadingRoute;
extern NSString* const kFinishedLoadingCities;
extern NSString* const kFinishedDownloadingFile;
extern NSString* const kFinishedConnectingDevice;

extern NSString* const kGOHIKE_BASEURL;

@interface GoHikeHTTPClient : AFHTTPClient

+ (id)sharedClient;

- (void)locate;
- (void)getCatalogForCity:(NSInteger)cityID;
- (void)getRoute:(NSInteger)routeId;
- (void)downloadFileWithUrl:(NSString*)fileUrl savePath:(NSString*)savePath;
- (void)pushCheckins;
- (void)connectFBId:(NSString*)facebookID name:(NSString*)name email:(NSString*)email token:(NSString*)token expDate:(NSDate*)expDate;

@end
