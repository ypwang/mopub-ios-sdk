//
//  FakeInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeInterstitialCustomEvent.h"

@implementation FakeInterstitialCustomEvent

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    self.customEventInfo = info;
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    [self.delegate interstitialCustomEventWillAppear:self];
    self.presentingViewController = rootViewController;
}

- (void)simulateLoadingAd
{
    [self.delegate interstitialCustomEvent:self didLoadAd:nil];
}

- (void)simulateFailingToLoad
{
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)simulateUserInteraction
{
    [self.delegate interstitialCustomEventWillLeaveApplication:self];
}

- (void)simulateUserDismissingAd
{
    self.presentingViewController = nil;
    [self.delegate interstitialCustomEventDidDisappear:self];
}

@end
