//
//  InMobiBannerCustomEvent.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "InMobiBannerCustomEvent.h"
#import "MPInstanceProvider.h"
#import "MPConstants.h"

#define kInMobiAppID            @"YOUR_INMOBI_APP_ID"
#define INVALID_INMOBI_AD_SIZE  -1

@interface MPInstanceProvider (InMobiBanners)

- (IMAdView *)buildIMAdViewWithFrame:(CGRect)frame appId:(NSString *)appId adSize:(int)adSize rootViewController:(UIViewController *)rootViewController;
- (IMAdRequest *)buildIMAdRequest;

@end

@implementation MPInstanceProvider (InMobiBanners)

- (IMAdView *)buildIMAdViewWithFrame:(CGRect)frame appId:(NSString *)appId adSize:(int)adSize rootViewController:(UIViewController *)rootViewController
{
    return [[[IMAdView alloc] initWithFrame:frame
                                    imAppId:appId
                                   imAdSize:adSize
                         rootViewController:rootViewController] autorelease];
}

- (IMAdRequest *)buildIMAdRequest
{
    return [IMAdRequest request];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface InMobiBannerCustomEvent ()

@property (nonatomic, retain) IMAdView *inMobiAdView;

- (int)imAdSizeConstantForCGSize:(CGSize)size;

@end

@implementation InMobiBannerCustomEvent

#pragma mark - MPBannerCustomEvent Subclass Methods

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    int imAdSizeConstant = [self imAdSizeConstantForCGSize:size];
    if (imAdSizeConstant == INVALID_INMOBI_AD_SIZE) {
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
        return;
    }
    self.inMobiAdView = [[MPInstanceProvider sharedProvider] buildIMAdViewWithFrame:CGRectMake(0, 0, size.width, size.height)
                                                                              appId:kInMobiAppID
                                                                             adSize:imAdSizeConstant
                                                                 rootViewController:[self.delegate viewControllerForPresentingModalView]];
    self.inMobiAdView.delegate = self;
    self.inMobiAdView.refreshInterval = REFRESH_INTERVAL_OFF;

    IMAdRequest *request = [[MPInstanceProvider sharedProvider] buildIMAdRequest];
    [self.inMobiAdView loadIMAdRequest:request];
}

- (int)imAdSizeConstantForCGSize:(CGSize)size
{
    if (CGSizeEqualToSize(size, MOPUB_BANNER_SIZE)) {
        return IM_UNIT_320x50;
    } else if (CGSizeEqualToSize(size, MOPUB_MEDIUM_RECT_SIZE)) {
        return IM_UNIT_300x250;
    } else if (CGSizeEqualToSize(size, MOPUB_LEADERBOARD_SIZE)) {
        return IM_UNIT_728x90;
    } else {
        return INVALID_INMOBI_AD_SIZE;
    }
}

- (void)dealloc
{
    [self.inMobiAdView setDelegate:nil];
    self.inMobiAdView = nil;
    [super dealloc];
}

#pragma mark - IMAdDelegate

- (void)adViewDidFinishRequest:(IMAdView *)adView
{
    [self.delegate bannerCustomEvent:self didLoadAd:adView];
}

- (void)adView:(IMAdView *)view didFailRequestWithError:(IMAdError *)error
{
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
}

- (void)adViewWillPresentScreen:(IMAdView *)adView
{
    [self.delegate bannerCustomEventWillBeginAction:self];
}

- (void)adViewDidDismissScreen:(IMAdView *)adView
{
    [self.delegate bannerCustomEventDidFinishAction:self];
}

- (void)adViewWillLeaveApplication:(IMAdView *)adView
{
    [self.delegate bannerCustomEventWillLeaveApplication:self];
}

@end
