//
//  FakeGSFullScreenAd.m
//  MoPubSDK
//
//  Created by pivotal on 3/25/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeIMAdInterstitial.h"

@implementation FakeIMAdInterstitial

- (void)loadRequest:(IMAdRequest *)request
{
    self.request = request;
}

- (void)presentFromRootViewController:(UIViewController *)rootViewController animated:(BOOL)animated
{
    if (self.willPresentSuccessfully) {
        self.presentingViewController = rootViewController;
        [self.delegate interstitialWillPresentScreen:self];
    } else {
        [self.delegate interstitial:self didFailToPresentScreenWithError:nil];
    }
}

- (void)simulateLoadingAd
{
    [self.delegate interstitialDidFinishRequest:self];
}

- (void)simulateFailingToLoad
{
    [self.delegate interstitial:self didFailToReceiveAdWithError:nil];
}

- (void)simulateUserDismissingAd
{
    self.presentingViewController = nil;
    [self.delegate interstitialDidDismissScreen:self];
}

@end
