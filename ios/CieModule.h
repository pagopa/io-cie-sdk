//
//  CieModule.h
//  iocieiossdk
//
//  Created by ugo chirico on 14.03.2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h>

NS_ASSUME_NONNULL_BEGIN

@interface CieModule : RCTEventEmitter  <RCTBridgeModule>


-(void) isNFCEnabled:(RCTResponseSenderBlock)callback;

-(void) hasNFCFeature:(RCTResponseSenderBlock)callback;

-(void) setPin:(NSString*) pin;

-(void) setAuthenticationUrl:(NSString*) url;

- (NSString*) getPin;

- (NSString*) getAuthenticationUrl;

- (void) post: (void(^)(NSString*, NSString* )) callback;

-(void) launchCieID:(RCTResponseSenderBlock)callback;

 #pragma NOT_AVAILABLE_ON_IOS

// non disponibile su iOS
-(void) startListeningNFC:(RCTResponseSenderBlock)callback;

 // non disponibile su iOS
-(void) stopListeningNFC:(RCTResponseSenderBlock)callback;

 // non disponibile su iOS
-(void) openNFCSettings:(RCTResponseSenderBlock)callback;

 // non disponibile su iOS
-(void) hasApiLevelSupport:(RCTResponseSenderBlock)callback;

@end

NS_ASSUME_NONNULL_END
