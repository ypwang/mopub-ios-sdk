//
//  MPGoogleAdMobAdapter.m
//  MoPub
//
//  Created by Andrew He on 5/1/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import "MPGoogleAdMobAdapter.h"
#import "MPLogging.h"
#import "MPInstanceProvider.h"
#import "MPAdConfiguration.h"

@interface MPInstanceProvider (AdMobBanners)

- (GADBannerView *)buildGADBannerViewWithFrame:(CGRect)frame;
- (GADRequest *)buildGADRequest;

@end

@implementation MPInstanceProvider (AdMobBanners)

- (GADBannerView *)buildGADBannerViewWithFrame:(CGRect)frame
{
    return [[[GADBannerView alloc] initWithFrame:frame] autorelease];
}

- (GADRequest *)buildGADRequest
{
    return [GADRequest request];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPGoogleAdMobAdapter ()

@property (nonatomic, retain) GADBannerView *adBannerView;

@end


@implementation MPGoogleAdMobAdapter

@synthesize adBannerView = _adBannerView;

- (id)initWithAdapterDelegate:(id<MPAdapterDelegate>)delegate
{
    if (self = [super initWithAdapterDelegate:delegate])
    {
        self.adBannerView = [[MPInstanceProvider sharedProvider] buildGADBannerViewWithFrame:CGRectZero];
        self.adBannerView.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    self.adBannerView.delegate = nil;
    self.adBannerView = nil;
    [super dealloc];
}

- (void)getAdWithConfiguration:(MPAdConfiguration *)configuration
{
    self.adBannerView.frame = [self frameForConfiguration:configuration];
    self.adBannerView.adUnitID = [configuration.nativeSDKParameters objectForKey:@"adUnitID"];
    self.adBannerView.rootViewController = [self.delegate viewControllerForPresentingModalView];

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

    [self.adBannerView loadRequest:request];
}

- (CGRect)frameForConfiguration:(MPAdConfiguration *)configuration
{
    CGFloat width = [[configuration.nativeSDKParameters objectForKey:@"adWidth"] floatValue];
    CGFloat height = [[configuration.nativeSDKParameters objectForKey:@"adHeight"] floatValue];

    if (width < GAD_SIZE_320x50.width && height < GAD_SIZE_320x50.height) {
        width = GAD_SIZE_320x50.width;
        height = GAD_SIZE_320x50.height;
    }
    return CGRectMake(0, 0, width, height);
}

#pragma mark -
#pragma mark GADBannerViewDelegate methods

- (void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    [self.delegate adapter:self didFinishLoadingAd:bannerView shouldTrackImpression:YES];
}

- (void)adView:(GADBannerView *)bannerView
        didFailToReceiveAdWithError:(GADRequestError *)error
{
    [self.delegate adapter:self didFailToLoadAdWithError:nil];
}

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView
{
    [self.delegate userActionWillBeginForAdapter:self];
}

- (void)adViewDidDismissScreen:(GADBannerView *)bannerView
{
    [self.delegate userActionDidFinishForAdapter:self];
}

- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView
{
    [self.delegate userWillLeaveApplicationFromAdapter:self];
}

@end
