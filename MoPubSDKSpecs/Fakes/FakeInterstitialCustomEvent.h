//
//  FakeInterstitialCustomEvent.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPInterstitialCustomEvent.h"

@interface FakeInterstitialCustomEvent : MPInterstitialCustomEvent <FakeInterstitialAd>

@property (nonatomic, assign) NSDictionary *customEventInfo;
@property (nonatomic, assign) UIViewController *presentingViewController;

- (void)simulateLoadingAd;
- (void)simulateFailingToLoad;
- (void)simulateUserInteraction;
- (void)simulateUserDismissingAd;

@end
