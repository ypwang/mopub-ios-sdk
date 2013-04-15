//
//  MPMillennialInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPMillennialInterstitialCustomEvent.h"
#import "MPInstanceProvider.h"
#import "MPLogging.h"

static NSMutableDictionary *sharedMMAdViews = nil;

////// Add Millennial support to the shared instance provider

@interface MPInstanceProvider (MillennialInterstitials)

- (MMAdView *)buildMMInterstitialAdWithAPID:(NSString *)apid delegate:(id<MMAdDelegate>)delegate;

@end

@implementation MPInstanceProvider (MillennialInterstitials)

- (MMAdView *)buildMMInterstitialAdWithAPID:(NSString *)apid delegate:(id<MMAdDelegate>)delegate;
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

@interface MPMillennialInterstitialCustomEvent ()

@property (nonatomic, retain) MMAdView *interstitial;

@end

@implementation MPMillennialInterstitialCustomEvent

@synthesize interstitial = _interstitial;

- (void)customEventDidUnload
{
    self.interstitial.delegate = nil;
    [[_interstitial retain] autorelease];
    self.interstitial = nil;
    [super customEventDidUnload];
}

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    NSString *apid = [info objectForKey:@"adUnitID"];
    
    self.interstitial = [[MPInstanceProvider sharedProvider] buildMMInterstitialAdWithAPID:apid delegate:self];
    
    if (!self.interstitial) {
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
        return;
    }
    
    // If a Millennial interstitial has already been cached, we don't need to fetch another one.
    if ([self.interstitial checkForCachedAd]) {
        MPLogInfo(@"Previous Millennial interstitial ad was found in the cache.");
        [self.delegate interstitialCustomEvent:self didLoadAd:self.interstitial];
        return;
    }
    
    [self.interstitial fetchAdToCache];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    if ([self.interstitial checkForCachedAd]) {
        self.interstitial.rootViewController = rootViewController;
        if (![self.interstitial displayCachedAd])
        {
            MPLogInfo(@"Millennial interstitial ad could not be displayed.");
            [self.delegate interstitialCustomEventDidExpire:self];
        }
    } else {
        MPLogInfo(@"Millennial interstitial ad is no longer cached.");
        [self.delegate interstitialCustomEventDidExpire:self];
    }
}

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
        [self.delegate interstitialCustomEvent:self didLoadAd:self.interstitial];
    } else {
        MPLogInfo(@"Millennial interstitial ad caching failed.");
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
    }
}

- (void)adModalWillAppear
{
    [self.delegate interstitialCustomEventWillAppear:self];
}

- (void)adModalDidAppear
{
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)adModalWasDismissed
{
    [self.delegate interstitialCustomEventWillDisappear:self];
    [self.delegate interstitialCustomEventDidDisappear:self];
    [self.delegate interstitialCustomEventDidExpire:self];
}


@end
