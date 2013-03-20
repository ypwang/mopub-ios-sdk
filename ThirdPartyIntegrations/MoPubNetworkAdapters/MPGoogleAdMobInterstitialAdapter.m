//
//  MPGoogleAdMobInterstitialAdapter.m
//  MoPub
//
//  Created by Nafis Jamal on 4/26/11.
//  Copyright 2011 MoPub. All rights reserved.
//

#import "MPGoogleAdMobInterstitialAdapter.h"
#import "CJSONDeserializer.h"
#import "MPInterstitialAdController.h"
#import "MPLogging.h"
#import "MPAdConfiguration.h"
#import "MPInstanceProvider.h"

#define kLocationAccuracyMeters 100

////// Add AdMob support to the shared instance provider

@interface MPInstanceProvider (AdMobInterstitials)

- (GADInterstitial *)buildGADInterstitialAd;

@end

@implementation MPInstanceProvider (AdMobInterstitials)

- (GADInterstitial *)buildGADInterstitialAd
{
    return [[[GADInterstitial alloc] init] autorelease];
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

    NSDictionary *params = configuration.headers;
    CJSONDeserializer *deserializer = [CJSONDeserializer deserializerWithNullObject:NULL];

    NSData *hdrData = [(NSString *)[params objectForKey:@"X-Nativeparams"]
                       dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *hdrParams = [deserializer deserializeAsDictionary:hdrData error:NULL];

    self.interstitial.adUnitID = [hdrParams objectForKey:@"adUnitID"];
    self.interstitial.delegate = self;

    GADRequest *request = [GADRequest request];

    NSArray *locationPair = [self.delegate locationDescriptionPair];
    if ([locationPair count] == 2) {
        [request setLocationWithLatitude:[[locationPair objectAtIndex:0] floatValue]
                               longitude:[[locationPair objectAtIndex:1] floatValue]
                                accuracy:kLocationAccuracyMeters];
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
