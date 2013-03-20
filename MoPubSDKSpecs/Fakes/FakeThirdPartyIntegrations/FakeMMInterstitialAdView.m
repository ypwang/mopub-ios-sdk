//
//  FakeMMInterstitialAdView.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeMMInterstitialAdView.h"
#import "MMAdView.h"

@implementation FakeMMInterstitialAdView

- (MMAdView *)masquerade
{
    return (MMAdView *)self;
}

- (BOOL)checkForCachedAd
{
    return self.hasCachedAd;
}

- (BOOL)fetchAdToCache
{
    self.askedToFetchAd = YES;
    if (self.hasCachedAd) {
        [self.delegate adRequestFailed:self.masquerade];
        return NO;
    } else {
        [self.delegate adRequestFailed:self.masquerade];
        [self.delegate adRequestIsCaching:self.masquerade];
        return YES;
    }
}

- (BOOL)displayCachedAd
{
    if (self.willSuccessfullyDisplayAd) {
        self.presentingViewController = self.rootViewController;
        [self.delegate adModalWillAppear];
        [self.delegate adModalDidAppear];

        return YES;
    } else {
        return NO;
    }
}

- (void)simulateSuccessfullyCachingAd
{
    [self.delegate adRequestFinishedCaching:self.masquerade successful:YES];
}

- (void)simulateFailingToCacheAd
{
    [self.delegate adRequestFinishedCaching:self.masquerade successful:NO];
}

- (void)simulateDismissingAd
{
    self.presentingViewController = nil;
    [self.delegate adModalWasDismissed];
}

@end
