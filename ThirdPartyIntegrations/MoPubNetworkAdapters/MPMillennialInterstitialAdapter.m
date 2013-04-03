//
//  MPMillennialInterstitialAdapter.m
//  MoPub
//
//  Created by Nafis Jamal on 4/27/11.
//  Copyright 2011 MoPub. All rights reserved.
//

#import "MPMillennialInterstitialAdapter.h"
#import "MPInterstitialAdController.h"
#import "MMAdView.h"
#import "MPLogging.h"
#import "MPAdConfiguration.h"
#import "MPInstanceProvider.h"

static NSMutableDictionary *sharedMMAdViews = nil;

////// Add Millennial support to the shared instance provider

@interface MPInstanceProvider (MillennialInterstitials)

- (MMAdView *)buildMMInterstitialAdWithAPID:(NSString *)apid delegate:(MPMillennialInterstitialAdapter *)delegate;

@end

@implementation MPInstanceProvider (MillennialInterstitials)

- (MMAdView *)buildMMInterstitialAdWithAPID:(NSString *)apid delegate:(MPMillennialInterstitialAdapter *)delegate;
{
    if ([apid length] == 0)
    {
        MPLogWarn(@"Failed to create a Millennial interstitial. Have you set a Millennial "
                  @"publisher ID in your MoPub dashboard?");
        return nil;
    }

    if (!sharedMMAdViews) {
        sharedMMAdViews = [[NSMutableDictionary dictionary] retain];
    }

    MMAdView *interstitial = [sharedMMAdViews objectForKey:apid];
    if (!interstitial) {
        interstitial = [MMAdView interstitialWithType:MMFullScreenAdTransition
                                                 apid:apid
                                             delegate:delegate
                                               loadAd:NO];
        [sharedMMAdViews setObject:interstitial forKey:apid];
    }

    interstitial.delegate = delegate;
    return interstitial;
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPMillennialInterstitialAdapter ()

@property (nonatomic, retain) MMAdView *interstitial;

@end

@implementation MPMillennialInterstitialAdapter

@synthesize interstitial = _interstitial;

- (void)getAdWithConfiguration:(MPAdConfiguration *)configuration
{
    NSString *apid = [configuration.nativeSDKParameters objectForKey:@"adUnitID"];

    self.interstitial = [[MPInstanceProvider sharedProvider] buildMMInterstitialAdWithAPID:apid delegate:self];

    if (!self.interstitial) {
        [self.delegate adapter:self didFailToLoadAdWithError:nil];
        return;
    }

    // If a Millennial interstitial has already been cached, we don't need to fetch another one.
    if ([self.interstitial checkForCachedAd]) {
        MPLogInfo(@"Previous Millennial interstitial ad was found in the cache.");
        [self.delegate adapterDidFinishLoadingAd:self];
        return;
    }

    [self.interstitial fetchAdToCache];
}

- (void)dealloc
{
    self.interstitial.delegate = nil;
    self.interstitial = nil;
    [super dealloc];
}

- (void)showInterstitialFromViewController:(UIViewController *)controller
{
    if ([self.interstitial checkForCachedAd])
    {
        self.interstitial.rootViewController = controller;
        if (![self.interstitial displayCachedAd])
        {
            MPLogInfo(@"Millennial interstitial ad could not be displayed.");
            [self.delegate interstitialDidExpireForAdapter:self];
        }
    }
    else
    {
        MPLogInfo(@"Millennial interstitial ad is no longer cached.");
        [self.delegate interstitialDidExpireForAdapter:self];
    }
}

# pragma mark -
# pragma mark MMAdDelegate

- (NSDictionary *)requestData
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"mopubsdk", @"vendor", nil];

    CLLocation *location = self.delegate.location;
    if (location) {
        [params setObject:[[NSNumber numberWithDouble:location.coordinate.latitude] stringValue] forKey:@"lat"];
        [params setObject:[[NSNumber numberWithDouble:location.coordinate.longitude] stringValue] forKey:@"long"];
    }

    return params;
}

- (void)adRequestFailed:(MMAdView *)adView {

}

- (void)adRequestIsCaching:(MMAdView *)adView {
    MPLogInfo(@"Millennial interstitial ad is currently caching.");
}

- (void)adRequestFinishedCaching:(MMAdView *)adView successful:(BOOL)didSucceed {
    if (didSucceed) {
        MPLogInfo(@"Millennial interstitial ad was cached successfully.");
        [self.delegate adapterDidFinishLoadingAd:self];
    } else {
        MPLogInfo(@"Millennial interstitial ad caching failed.");
        [self.delegate adapter:self didFailToLoadAdWithError:nil];
    }
}

- (void)adModalWillAppear
{
    [self.delegate interstitialWillAppearForAdapter:self];
}

- (void)adModalDidAppear
{
    [self.delegate interstitialDidAppearForAdapter:self];
    [self trackImpression];
}

- (void)adModalWasDismissed
{
    [self retain];
    [self.delegate interstitialWillDisappearForAdapter:self];
    [self.delegate interstitialDidDisappearForAdapter:self];
    [self.delegate interstitialDidExpireForAdapter:self];
    [self release];
}

@end
