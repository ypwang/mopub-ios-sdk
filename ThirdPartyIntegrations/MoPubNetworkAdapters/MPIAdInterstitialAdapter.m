//
//  MPIAdInterstitialAdapter.m
//  MoPub
//
//  Created by Haydn Dufrene on 10/28/11.
//  Copyright 2011 MoPub. All rights reserved.
//

#import "MPIAdInterstitialAdapter.h"
#import "MPAdView.h"
#import "MPLogging.h"
#import "CJSONDeserializer.h"

@implementation MPIAdInterstitialAdapter

- (void)getAdWithParams:(NSDictionary *)params
{
    _iAdInterstitial = [[ADInterstitialAd alloc] init];
    _iAdInterstitial.delegate = self;
}

- (void)dealloc {
    _iAdInterstitial.delegate = nil;
    [_iAdInterstitial release];
    [super dealloc];
}

- (void)showInterstitialFromViewController:(UIViewController *)controller {
    // ADInterstitialAd throws an exception if we don't check the loaded flag prior to presenting.
    if (_iAdInterstitial.loaded) {
        [self.delegate interstitialWillAppearForAdapter:self];
        [_iAdInterstitial presentFromViewController:controller];
        _isOnscreen = YES;
        [self.delegate interstitialDidAppearForAdapter:self];
    }
}

- (void)interstitialAdDidUnload:(ADInterstitialAd *)interstitialAd {
    [self retain];

    // This method may be called whether the ad is on-screen or not. We only want to invoke the
    // "disappear" callbacks if the ad is on-screen.
    if (_isOnscreen) {
        [self.delegate interstitialWillDisappearForAdapter:self];
        [self.delegate interstitialDidDisappearForAdapter:self];
        _isOnscreen = NO;
    }

    // ADInterstitialAd can't be shown again after it has unloaded, so notify the controller.
    [self.delegate interstitialDidExpireForAdapter:self];

    [self release];
}

- (void)interstitialAd:(ADInterstitialAd *)interstitialAd didFailWithError:(NSError *)error {
    [self.delegate adapter:self didFailToLoadAdWithError:error];
}

- (void)interstitialAdDidLoad:(ADInterstitialAd *)interstitialAd {
    [self.delegate adapterDidFinishLoadingAd:self];
}

- (BOOL)interstitialAdActionShouldBegin:(ADInterstitialAd *)interstitialAd
                   willLeaveApplication:(BOOL)willLeave {
    [self.delegate interstitialWasTappedForAdapter:self];
    return YES; // YES allows the banner action to execute (NO would instead cancel the action).
}
@end
