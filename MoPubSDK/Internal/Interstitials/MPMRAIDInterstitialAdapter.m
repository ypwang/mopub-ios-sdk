//
//  MPMraidInterstitialAdapter.m
//  MoPub
//
//  Created by Andrew He on 12/11/11.
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPMraidInterstitialAdapter.h"

#import "MPAdConfiguration.h"
#import "MPInterstitialAdController.h"
#import "MPInterstitialAdManager.h"
#import "MPLogging.h"

@implementation MPMRAIDInterstitialAdapter

- (void)getAdWithConfiguration:(MPAdConfiguration *)configuration
{
    _interstitial = [[MPMRAIDInterstitialViewController alloc]
                     initWithAdConfiguration:configuration];
    _interstitial.delegate = self;
    [_interstitial setCloseButtonStyle:MPInterstitialCloseButtonStyleAdControlled];
    [_interstitial startLoading];
}

- (void)dealloc
{
    _interstitial.delegate = nil;
    [_interstitial release];

    [super dealloc];
}

- (void)showInterstitialFromViewController:(UIViewController *)controller
{
    [_interstitial presentInterstitialFromViewController:controller];
}

#pragma mark - MPMRAIDInterstitialViewControllerDelegate

- (void)interstitialDidLoadAd:(MPMRAIDInterstitialViewController *)interstitial
{
    [self.delegate adapterDidFinishLoadingAd:self];
}

- (void)interstitialDidFailToLoadAd:(MPMRAIDInterstitialViewController *)interstitial
{
    [self.delegate adapter:self didFailToLoadAdWithError:nil];
}

- (void)interstitialWillAppear:(MPMRAIDInterstitialViewController *)interstitial
{
    [self.delegate interstitialWillAppearForAdapter:self];
}

- (void)interstitialDidAppear:(MPMRAIDInterstitialViewController *)interstitial
{
    [self.delegate interstitialDidAppearForAdapter:self];
}

- (void)interstitialWillDisappear:(MPMRAIDInterstitialViewController *)interstitial
{
    [self.delegate interstitialWillDisappearForAdapter:self];
}

- (void)interstitialDidDisappear:(MPMRAIDInterstitialViewController *)interstitial
{
    [self.delegate interstitialDidDisappearForAdapter:self];
}

// TODO: Tapped callback.

@end
