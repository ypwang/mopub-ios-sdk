//
//  FakeInterstitialCustomEvent.h
//  MoPubSDK
//
//  Created by pivotal on 3/19/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPInterstitialCustomEvent.h"

@interface FakeInterstitialCustomEvent : MPInterstitialCustomEvent

@property (nonatomic, assign) NSDictionary *customEventInfo;
@property (nonatomic, assign) UIViewController *rootViewController;

+ (FakeInterstitialCustomEvent *)lastInterstitialCustomEvent;

@end
