//
//  KeychainManager.h
//  ScavengerApp
//
//  Created by Giovanni on 5/29/13.
//  Copyright (c) 2013 Code for Europe. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KeychainManager : NSObject

+(KeychainManager *)sharedInstance;

- (NSData *)searchKeychainCopyMatching:(NSString *)identifier;
- (BOOL)createKeychainValue:(NSString *)password forIdentifier:(NSString *)identifier;
- (void)deleteKeychainValue:(NSString *)identifier;

@end
