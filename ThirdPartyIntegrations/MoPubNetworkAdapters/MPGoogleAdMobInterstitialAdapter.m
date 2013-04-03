//
//  MPGoogleAdMobInterstitialAdapter.m
//  MoPub
//
//  Created by Nafis Jamal on 4/26/11.
//  Copyright 2011 MoPub. All rights reserved.
//

#import "MPGoogleAdMobInterstitialAdapter.h"
#import "MPInterstitialAdController.h"
#import "MPLogging.h"
#import "MPAdConfiguration.h"
#import "MPInstanceProvider.h"
#import <CoreLocation/CoreLocation.h>

////// Add AdMob support to the shared instance provider

@interface MPInstanceProvider (AdMobInterstitials)

- (GADInterstitial *)buildGADInterstitialAd;
- (GADRequest *)buildGADRequest;

@end

@implementation MPInstanceProvider (AdMobInterstitials)

- (GADInterstitial *)buildGADInterstitialAd
{
    return [[[GADInterstitial alloc] init] autorelease];
}

- (GADRequest *)buildGADRequest
{
    return [GADRequest request];
}

@end

////// MPGoogleAdMobInterstitialAdapter

@interface MPGoogleAdMobInterstitialAdapter ()

@property (nonatomic, retain) GADInterstitial *interstitial;

@end

@implementation MPGoogleAdMobInterstitialAdapter

@synthesize interstitial = _interstitial;

- (void)getAdWithConfiguration:(MPAdConfiguration *)configuration
{
    self.interstitial = [[MPInstanceProvider sharedProvider] buildGADInterstitialAd];

    self.interstitial.adUnitID = [configuration.nativeSDKParameters objectForKey:@"adUnitID"];
    self.interstitial.delegate = self;

    GADRequest *request = [[MPInstanceProvider sharedProvider] buildGADRequest];

    CLLocation *location = self.delegate.location;
    if (location) {
        [request setLocationWithLatitude:location.coordinate.latitude
                               longitude:location.coordinate.longitude
                                accuracy:location.horizontalAccuracy];
    }

    // Here, you can specify a list of devices that will receive test ads.
    // See: http://code.google.com/mobile/ads/docs/ios/intermediate.html#testdevices
    request.testDevices = [NSArray arrayWithObjects:
                           GAD_SIMULATOR_ID,
                           // more UDIDs here,
                           nil];

    [self.interstitial loadRequest:request];
}

- (void)interstitialDidReceiveAd:(GADInterstitial *)interstitial
{
    [self.delegate adapterDidFinishLoadingAd:self];
}

- (void)interstitial:(GADInterstitial *)interstitial
        didFailToReceiveAdWithError:(GADRequestError *)error
{
    [self.delegate adapter:self didFailToLoadAdWithError:error];
}

- (void)showInterstitialFromViewController:(UIViewController *)controller
{
    [self.interstitial presentFromRootViewController:controller];
}

- (void)interstitialWillPresentScreen:(GADInterstitial *)interstitial
{
    [self trackImpression];
    [self.delegate interstitialWillAppearForAdapter:self];
    [self.delegate interstitialDidAppearForAdapter:self];
}

- (void)interstitialWillDismissScreen:(GADInterstitial *)ad
{
    [self.delegate interstitialWillDisappearForAdapter:self];
}

- (void)interstitialDidDismissScreen:(GADInterstitial *)ad
{
    [self retain];
    [self.delegate interstitialDidDisappearForAdapter:self];
    [self release];
}

- (void)interstitialWillLeaveApplication:(GADInterstitial *)ad
{
    [self trackClick];
}

- (void)dealloc
{
    self.interstitial.delegate = nil;
    self.interstitial = nil;
    [super dealloc];
}

@end
