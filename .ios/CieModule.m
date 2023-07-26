
//
//  CieModule.m
//  iocieiossdk
//
//  Created by ugo chirico on 14.03.2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "CieModule.h"
#import <iociesdkios/iociesdkios.h>

@import iociesdkios;

#define eventChannel @"onEvent"
#define errorChannel @"onError"
#define successChannel @"onSuccess"

@interface CieModule()

@property long attemptsLeft;
@property (nonatomic) NSString* PIN;
@property NSString* url;
@property CIEIDSdk* cieSDK;

@end

@implementation CieModule

- (id) init
{
  self = [super init];
  if(self)
  {
    self.cieSDK = [[CIEIDSdk alloc] init];
  }

  return self;
}

RCT_EXPORT_MODULE();

- (NSArray<NSString *> *)supportedEvents {
    return @[@"onSuccess", @"onEvent", @"onError"];
}

RCT_EXPORT_METHOD(isNFCEnabled:(RCTResponseSenderBlock)callback) {
  callback(@[@YES]);
}

RCT_EXPORT_METHOD(hasNFCFeature:(RCTResponseSenderBlock)callback) {
    BOOL value = [self.cieSDK hasNFCFeature];
    callback(@[[NSNumber numberWithBool:value]]);
}

RCT_EXPORT_METHOD(setPin:(NSString*) pin) {
  self.PIN = pin;
}

- (NSString*) getPin
{
  return self.PIN;
}

RCT_EXPORT_METHOD(setAuthenticationUrl:(NSString*) url) {
  self.url = url;
}

RCT_EXPORT_METHOD(setCutomIdpUrl:(NSString*) idpUrl) {
  [self.cieSDK setCustomIdpUrlWithUrl:idpUrl];
}

RCT_EXPORT_METHOD(enableLog:(BOOL) isEnabled) {
  [self.cieSDK enableLogWithIsEnabled:isEnabled];
}

RCT_EXPORT_METHOD(setAlertMessage:(NSString*)key withValue:(NSString*)value) {
    [self.cieSDK setAlertMessageWithKey:key value:value];
}

- (NSString*) getAuthenticationUrl
{
  return self.url;
}

- (void) post: (void(^)(NSString*, NSString* )) callback
{
  dispatch_async(dispatch_get_global_queue(0, 0), ^{

    [self.cieSDK postWithUrl:self.url pin:self.PIN completed:^(NSString* error, NSString* response) {
      callback(error, response);
    }];
  });
}

RCT_EXPORT_METHOD(start:(RCTResponseSenderBlock)callback) {
  [self post: ^(NSString* error, NSString* response) {
      if(error == nil)
      {
          [self sendEvent: successChannel eventValue: response];
      }
      else
      {
          [self sendEvent: eventChannel eventValue: error];
      }
  }];

  callback(@[]);
}


- (void) sendEvent: (NSString*) channel eventValue: (NSString*) eventValue
{
    [self sendEventWithName:channel body:@{@"event": eventValue, @"attemptsLeft": [NSNumber numberWithLong:self.cieSDK.attemptsLeft]}];
}

RCT_EXPORT_METHOD(launchCieID:(RCTResponseSenderBlock)callback) {
  // TODO run CIE ID
  callback(@[]);
}

#pragma NOT_AVAILABLE_ON_IOS

// non disponibile su iOS
RCT_EXPORT_METHOD(startListeningNFC:(RCTResponseSenderBlock)callback) {
  callback(@[]);
}

// non disponibile su iOS
RCT_EXPORT_METHOD(stopListeningNFC:(RCTResponseSenderBlock)callback) {
  callback(@[]);
}

// non disponibile su iOS
RCT_EXPORT_METHOD(openNFCSettings:(RCTResponseSenderBlock)callback) {
  callback(@[]);
}

// non disponibile su iOS
RCT_EXPORT_METHOD(hasApiLevelSupport:(RCTResponseSenderBlock)callback) {
  callback(@[]);
}

+ (BOOL)requiresMainQueueSetup
{
    return NO;
}

//RCT_EXPORT_METHOD(squareMe:(NSString *)number:(RCTResponseSenderBlock)callback) {
//NSNumber *num = @([number intValue]);
//NSNumber *myValue = @([num integerValue] * [num integerValue]);
// NSLog(@"----------------%@",myValue);
//callback(@[[NSNull null], [NSNumber numberWithInt:([myValue integerValue])]]);}


@end
