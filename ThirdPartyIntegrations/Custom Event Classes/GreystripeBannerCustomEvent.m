//
//  GreystripeBannerCustomEvent.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "GreystripeBannerCustomEvent.h"
#import "GSMobileBannerAdView.h"
#import "GSMediumRectangleAdView.h"
#import "GSLeaderboardAdView.h"
#import "MPConstants.h"
#import "MPLogging.h"
#import "MPInstanceProvider.h"

#define kGreystripeGUID @"YOUR_GREYSTRIPE_GUID"

@interface MPInstanceProvider (GreystripeBanners)

- (GSBannerAdView *)buildGreystripeBannerAdViewWithDelegate:(id<GSAdDelegate>)delegate GUID:(NSString *)GUID size:(CGSize)size;

@end

@implementation MPInstanceProvider (GreystripeBanners)

- (GSBannerAdView *)buildGreystripeBannerAdViewWithDelegate:(id<GSAdDelegate>)delegate GUID:(NSString *)GUID size:(CGSize)size
{
    if (CGSizeEqualToSize(size, MOPUB_BANNER_SIZE)) {
        return [[GSMobileBannerAdView alloc] initWithDelegate:delegate GUID:GUID autoload:NO];
    } else if (CGSizeEqualToSize(size, MOPUB_MEDIUM_RECT_SIZE)) {
        return [[GSMediumRectangleAdView alloc] initWithDelegate:delegate GUID:GUID autoload:NO];
    } else if (CGSizeEqualToSize(size, MOPUB_LEADERBOARD_SIZE)) {
        return [[GSLeaderboardAdView alloc] initWithDelegate:delegate GUID:GUID autoload:NO];
    } else {
        return nil;
    }
}

@end


@interface GreystripeBannerCustomEvent ()

@property (nonatomic, retain) GSBannerAdView *greystripeBanner;

@end

@implementation GreystripeBannerCustomEvent

@synthesize greystripeBanner = _greystripeBanner;

#pragma mark - MPBannerCustomEvent Subclass Methods

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    self.greystripeBanner = [[MPInstanceProvider sharedProvider] buildGreystripeBannerAdViewWithDelegate:self GUID:kGreystripeGUID size:size];
    if (!self.greystripeBanner) {
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
    }
    [self.greystripeBanner fetch];
}

- (UIViewController *)greystripeBannerDisplayViewController
{
    return [self.delegate viewControllerForPresentingModalView];
}

- (void)customEventDidUnload
{
    self.greystripeBanner.delegate = nil;
    [[_greystripeBanner retain] autorelease];
    self.greystripeBanner = nil;

    [super customEventDidUnload];
}

#pragma mark - GSAdDelegate

- (void)greystripeAdFetchSucceeded:(id<GSAd>)a_ad
{
    [self.delegate bannerCustomEvent:self didLoadAd:self.greystripeBanner];
}

- (void)greystripeAdFetchFailed:(id<GSAd>)a_ad withError:(GSAdError)a_error
{
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)greystripeWillPresentModalViewController
{
    [self.delegate bannerCustomEventWillBeginAction:self];
}

- (void)greystripeDidDismissModalViewController
{
    [self.delegate bannerCustomEventDidFinishAction:self];
}

@end
