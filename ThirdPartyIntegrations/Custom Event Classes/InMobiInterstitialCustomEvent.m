//
//  InMobiInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "InMobiInterstitialCustomEvent.h"
#import "MPInstanceProvider.h"
#import "MPLogging.h"

@interface MPInstanceProvider (InMobiInterstitials)

- (IMAdInterstitial *)buildIMAdInterstitialWithDelegate:(id<IMAdInterstitialDelegate>)delegate appId:(NSString *)appId;
- (IMAdRequest *)buildIMAdRequest;

@end

@implementation MPInstanceProvider (InMobiInterstitials)

- (IMAdInterstitial *)buildIMAdInterstitialWithDelegate:(id<IMAdInterstitialDelegate>)delegate appId:(NSString *)appId;
{
    IMAdInterstitial *inMobiInterstitial = [[[IMAdInterstitial alloc] init] autorelease];
    inMobiInterstitial.delegate = delegate;
    inMobiInterstitial.imAppId = appId;
    return inMobiInterstitial;
}

- (IMAdRequest *)buildIMAdRequest
{
    return [IMAdRequest request];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////


#define kInMobiAppID    @"YOUR_INMOBI_APP_ID"

@interface InMobiInterstitialCustomEvent ()

@property (nonatomic, retain) IMAdInterstitial *inMobiInterstitial;

@end

@implementation InMobiInterstitialCustomEvent

#pragma mark - MPInterstitialCustomEvent Subclass Methods

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    MPLogInfo(@"Requesting InMobi interstitial.");

    self.inMobiInterstitial = [[MPInstanceProvider sharedProvider] buildIMAdInterstitialWithDelegate:self
                                                                                               appId:kInMobiAppID];

    IMAdRequest *request = [[MPInstanceProvider sharedProvider] buildIMAdRequest];
    [self.inMobiInterstitial loadRequest:request];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    [self.inMobiInterstitial presentFromRootViewController:rootViewController animated:YES];
}

- (void)dealloc
{
    [self.inMobiInterstitial setDelegate:nil];
    self.inMobiInterstitial = nil;

    [super dealloc];
}

#pragma mark - IMAdInterstitialDelegate

- (void)interstitialDidFinishRequest:(IMAdInterstitial *)ad
{
    MPLogInfo(@"Successfully loaded InMobi interstitial.");

    [self.delegate interstitialCustomEvent:self didLoadAd:ad];
}

- (void)interstitial:(IMAdInterstitial *)ad didFailToReceiveAdWithError:(IMAdError *)error
{
    MPLogInfo(@"Failed to load InMobi interstitial.");

    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)interstitialWillPresentScreen:(IMAdInterstitial *)ad
{
    MPLogInfo(@"InMobi interstitial will be shown.");

    [self.delegate interstitialCustomEventWillAppear:self];

    // InMobi doesn't seem to have a separate callback for the "did appear" event, so we
    // signal that manually.
    [self.delegate interstitialCustomEventDidAppear:self];
}

- (void)interstitial:(IMAdInterstitial *)ad didFailToPresentScreenWithError:(IMAdError *)error
{
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)interstitialWillDismissScreen:(IMAdInterstitial *)ad
{
    [self.delegate interstitialCustomEventWillDisappear:self];
}

- (void)interstitialDidDismissScreen:(IMAdInterstitial *)ad
{
    MPLogInfo(@"InMobi interstitial was dismissed.");

    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)interstitialWillLeaveApplication:(IMAdInterstitial *)ad
{
    // InMobi doesn't seem to have an explicit callback for tap events. However, leaving the
    // application is generally an indicator of a user tap, so we can use this callback
    // to signal the tap event.
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
}

@end
