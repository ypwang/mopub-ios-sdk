//
//  FakeMMBannerAdView.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeMMBannerAdView.h"

@implementation FakeMMBannerAdView

- (MMAdView *)masquerade
{
    return (MMAdView *)self;
}

- (void)refreshAd
{
    self.hasRefreshed = YES;
}

- (void)simulateLoadingAd
{
    [self.delegate adRequestSucceeded:self.masquerade];
}

- (void)simulateFailingToLoad
{
    [self.delegate adRequestFailed:self.masquerade];
}

- (void)simulateUserTap
{
    [self.delegate adWasTapped:self.masquerade];
}

- (void)simulateUserEndingInteraction
{
    [self.delegate adModalWasDismissed];
}

- (void)simulateUserLeavingApplication
{
    [self.delegate applicationWillTerminateFromAd];
}

@end
