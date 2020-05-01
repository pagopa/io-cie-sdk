//
//  CieModule.m
//  iocieiossdk
//
//  Created by ugo chirico on 14.03.2020.
//  Copyright © 2020 Facebook. All rights reserved.
//

#import "CieModule.h"
#import <RNNativeCiesdk-Swift.h>

#define eventChannel @"onEvent"
#define errorChannel @"onError"
#define successChannel @"onSuccess"

@interface CieModule()

@property long attemptsLeft;
@property NSString* pin;
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
  callback(@[@YES]);
}

RCT_EXPORT_METHOD(setPIN:(NSString*) pin) {
  self.pin = pin;
}

RCT_EXPORT_METHOD(setAuthenticationUrl:(NSString*) url) {
  self.url = url;
}

RCT_EXPORT_METHOD(start:(RCTResponseSenderBlock)callback) {
  
  dispatch_async(dispatch_get_global_queue(0, 0), ^{
    [self.cieSDK postWithUrl:self.url pin:self.pin completed:^(uint16_t error, NSString* response) {
    
      if(error == 0)
      {
        [self sendEvent: successChannel eventValue: response];
      }
      else
      {
        [self sendEvent: eventChannel eventValue: [NSString stringWithFormat:@"Error: %x", error]];
      }
    }];
  });
  
  callback(@[]);
}

- (void) sendEvent: (NSString*) channel eventValue: (NSString*) eventValue
{
  [self sendEventWithName:channel body:@{@"event": eventValue, @"attemptsLeft": [NSNumber numberWithInt:self.attemptsLeft]}];
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



//RCT_EXPORT_METHOD(squareMe:(NSString *)number:(RCTResponseSenderBlock)callback) {
//NSNumber *num = @([number intValue]);
//NSNumber *myValue = @([num integerValue] * [num integerValue]);
// NSLog(@"----------------%@",myValue);
//callback(@[[NSNull null], [NSNumber numberWithInt:([myValue integerValue])]]);}


@end
