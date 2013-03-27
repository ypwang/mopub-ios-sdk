//
//  FakeChartboost.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeChartboost.h"

@implementation FakeChartboost

- (void)startSession
{
    self.didStartSession = YES;
}

- (void)cacheInterstitial
{
    self.didStartCaching = YES;
}

- (void)showInterstitial
{
    // chartboost doesn't actually need a view controller
    // this is here as a proxy
    self.presentingViewController = [[[UIViewController alloc] init] autorelease];
}

- (void)simulateLoadingAd
{
    [self.delegate didCacheInterstitial:nil];
}

- (void)simulateFailingToLoad
{
    [self.delegate didFailToLoadInterstitial:nil];
}

- (void)simulateUserTap
{
    [self.delegate didClickInterstitial:nil];
    [self simulateUserDismissingAd]; //Chartboost always dismisses the ad when clicked
}

- (void)simulateUserDismissingAd
{
    self.presentingViewController = nil;
    [self.delegate didDismissInterstitial:nil];
}

@end
