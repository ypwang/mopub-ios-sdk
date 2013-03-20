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
#import "MPInstanceProvider.h"

////// Add iAD support to the shared instance provider

@interface MPInstanceProvider (iAdInterstitials)

- (ADInterstitialAd *)buildADInterstitialAd;

@end

@implementation MPInstanceProvider (iAdInterstitials)

- (ADInterstitialAd *)buildADInterstitialAd
{
    return [[[ADInterstitialAd alloc] init] autorelease];
}

@end

////// MPIAdInterstitialAdapter

@interface MPIAdInterstitialAdapter ()

@property (nonatomic, retain) ADInterstitialAd *iAdInterstitial;
@property (nonatomic, assign) BOOL isOnScreen;

@end

@implementation MPIAdInterstitialAdapter

@synthesize iAdInterstitial = _iAdInterstitial;

- (void)getAdWithConfiguration:(MPAdConfiguration *)configuration
{
    self.iAdInterstitial = [[MPInstanceProvider sharedProvider] buildADInterstitialAd];
    self.iAdInterstitial.delegate = self;
}

- (void)dealloc {
    self.iAdInterstitial.delegate = nil;
    self.iAdInterstitial = nil;
    [super dealloc];
}

- (void)showInterstitialFromViewController:(UIViewController *)controller {
    // ADInterstitialAd throws an exception if we don't check the loaded flag prior to presenting.
    if (self.iAdInterstitial.loaded) {
        [self trackImpression];
        [self.delegate interstitialWillAppearForAdapter:self];
        [self.iAdInterstitial presentFromViewController:controller];
        self.isOnScreen = YES;
        [self.delegate interstitialDidAppearForAdapter:self];
    }
}

- (void)interstitialAdDidUnload:(ADInterstitialAd *)interstitialAd {
    [self retain];

    // This method may be called whether the ad is on-screen or not. We only want to invoke the
    // "disappear" callbacks if the ad is on-screen.
    if (self.isOnScreen) {
        [self.delegate interstitialWillDisappearForAdapter:self];
        [self.delegate interstitialDidDisappearForAdapter:self];
        self.isOnScreen = NO; //technically not necessary as iAd interstitials are single use
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
    [self trackClick];
    return YES; // YES allows the banner action to execute (NO would instead cancel the action).
}
@end
