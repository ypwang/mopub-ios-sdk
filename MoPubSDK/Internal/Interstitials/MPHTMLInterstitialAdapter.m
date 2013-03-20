//
//  MPHTMLInterstitialAdapter.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPHTMLInterstitialAdapter.h"

#import "MPAdConfiguration.h"
#import "MPInterstitialAdController.h"
#import "MPLogging.h"

@implementation MPHTMLInterstitialAdapter

- (void)getAdWithConfiguration:(MPAdConfiguration *)configuration
{
    MPLogTrace(@"Loading HTML interstitial with source: %@", [configuration adResponseHTMLString]);

    _interstitial = [[MPHTMLInterstitialViewController alloc] init];
    _interstitial.delegate = self;
    _interstitial.orientationType = configuration.orientationType;
    [_interstitial setCustomMethodDelegate:[self.delegate interstitialDelegate]];
    [_interstitial loadConfiguration:configuration];
}

- (void)dealloc
{
    [_interstitial setDelegate:nil];
    [_interstitial setCustomMethodDelegate:nil];
    [_interstitial release];
    [super dealloc];
}

- (void)showInterstitialFromViewController:(UIViewController *)controller
{
    [_interstitial presentInterstitialFromViewController:controller];
}

#pragma mark - MPHTMLInterstitialViewControllerDelegate

- (void)interstitialDidLoadAd:(MPHTMLInterstitialViewController *)interstitial
{
    [self.delegate adapterDidFinishLoadingAd:self];
}

- (void)interstitialDidFailToLoadAd:(MPHTMLInterstitialViewController *)interstitial
{
    [self.delegate adapter:self didFailToLoadAdWithError:nil];
}

- (void)interstitialWillAppear:(MPHTMLInterstitialViewController *)interstitial
{
    [self.delegate interstitialWillAppearForAdapter:self];
}

- (void)interstitialDidAppear:(MPHTMLInterstitialViewController *)interstitial
{
    [self.delegate interstitialDidAppearForAdapter:self];
}

- (void)interstitialWillDisappear:(MPHTMLInterstitialViewController *)interstitial
{
    [self.delegate interstitialWillDisappearForAdapter:self];
}

- (void)interstitialDidDisappear:(MPHTMLInterstitialViewController *)interstitial
{
    [self.delegate interstitialDidDisappearForAdapter:self];
}

- (void)interstitialWasTapped:(MPHTMLInterstitialViewController *)interstitial
{
    [self.delegate interstitialWasTappedForAdapter:self];
}

- (void)interstitialWillLeaveApplication:(MPHTMLInterstitialViewController *)interstitial
{
    [self.delegate interstitialWillLeaveApplicationForAdapter:self];
}

@end
