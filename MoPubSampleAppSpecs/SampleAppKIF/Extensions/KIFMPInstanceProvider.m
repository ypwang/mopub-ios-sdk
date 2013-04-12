//
//  KIFMPInstanceProvider.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFMPInstanceProvider.h"
#import "GSBAnnerAdView.h"
#import "GSFullscreenAd.h"
#import "GSAdDelegate.h"
#import "IMAdInterstitial.h"
#import "IMAdInterstitialDelegate.h"

static KIFMPInstanceProvider *sharedProvider = nil;

@interface MPInstanceProvider (ThirdPartyIntegrations)

- (GSFullscreenAd *)buildGSFullscreenAdWithDelegate:(id<GSAdDelegate>)delegate GUID:(NSString *)GUID;
- (GSBannerAdView *)buildGreystripeBannerAdViewWithDelegate:(id<GSAdDelegate>)delegate GUID:(NSString *)GUID size:(CGSize)size;
- (IMAdInterstitial *)buildIMAdInterstitialWithDelegate:(id<IMAdInterstitialDelegate>)delegate appId:(NSString *)appId;
- (IMAdRequest *)buildIMAdRequest;

@end

@implementation MPInstanceProvider (KIF)

+ (MPInstanceProvider *)sharedProvider
{
    if (!sharedProvider) {
        sharedProvider = [[KIFMPInstanceProvider alloc] init];
    }
    return sharedProvider;
}

@end

@implementation KIFMPInstanceProvider

- (GSFullscreenAd *)buildGSFullscreenAdWithDelegate:(id<GSAdDelegate>)delegate GUID:(NSString *)GUID
{
    return [super buildGSFullscreenAdWithDelegate:delegate GUID:GUID];
}

- (GSBannerAdView *)buildGreystripeBannerAdViewWithDelegate:(id<GSAdDelegate>)delegate GUID:(NSString *)GUID size:(CGSize)size
{
    return [super buildGreystripeBannerAdViewWithDelegate:delegate GUID:@"1d73efc1-c8c5-44e6-9b02-b6dd29374c1c" size:size];
}

- (IMAdInterstitial *)buildIMAdInterstitialWithDelegate:(id<IMAdInterstitialDelegate>)delegate appId:(NSString *)appId
{
    return [super buildIMAdInterstitialWithDelegate:delegate appId:@"4028cba631d63df10131e1d4650600cd"];
}

- (IMAdRequest *)buildIMAdRequest
{
    IMAdRequest *request = [super buildIMAdRequest];
    request.testMode = YES;
    return request;
}

@end
