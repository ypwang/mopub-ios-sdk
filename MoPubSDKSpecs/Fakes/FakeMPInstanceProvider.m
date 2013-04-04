//
//  FakeMPInstanceProvider.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeMPInstanceProvider.h"
#import "MPMillennialInterstitialAdapter.h"
#import "MPAdWebView.h"

@interface MPInstanceProvider (ThirdPartyAdditions)

- (ADInterstitialAd *)buildADInterstitialAd;
- (GADInterstitial *)buildGADInterstitialAd;
- (GADBannerView *)buildGADBannerViewWithFrame:(CGRect)frame;
- (GADRequest *)buildGADRequest;

- (MMAdView *)buildMMInterstitialAdWithAPID:(NSString *)apid delegate:(MPMillennialInterstitialAdapter *)delegate;
- (MMAdView *)buildMMAdViewWithFrame:(CGRect)frame type:(MMAdType)type apid:(NSString *)apid delegate:(id<MMAdDelegate>)delegate;

- (Chartboost *)buildChartboost;

- (GSFullscreenAd *)buildGSFullscreenAdWithDelegate:(id<GSAdDelegate>)delegate GUID:(NSString *)GUID;

- (MPInterstitialCustomEvent *)buildInterstitialCustomEventFromCustomClass:(Class)customClass
                                                                  delegate:(id<MPInterstitialCustomEventDelegate>)delegate;

- (IMAdInterstitial *)buildIMAdInterstitialWithDelegate:(id<IMAdInterstitialDelegate>)delegate appId:(NSString *)appID;

@end


@implementation FakeMPInstanceProvider


- (id)returnFake:(id)fake orCall:(IDReturningBlock)block
{
    if (fake) {
        return fake;
    } else {
        return block();
    }
}

- (NSString *)userAgent
{
    return @"FAKE_TEST_USER_AGENT_STRING";
}

- (MPReachability *)sharedMPReachability
{
    return [self returnFake:self.fakeMPReachability
                     orCall:^id{
                         return [super sharedMPReachability];
                     }];
}

- (MPAnalyticsTracker *)buildMPAnalyticsTracker
{
    self.lastFakeMPAnalyticsTracker = [[[FakeMPAnalyticsTracker alloc] init] autorelease];
    return self.lastFakeMPAnalyticsTracker;
}

- (MPAdWebViewAgent *)buildMPAdWebViewAgentWithAdWebViewFrame:(CGRect)frame delegate:(id<MPAdWebViewAgentDelegate>)delegate customMethodDelegate:(id)customMethodDelegate
{
    return [self returnFake:self.fakeMPAdWebViewAgent
                     orCall:^{
                         return [super buildMPAdWebViewAgentWithAdWebViewFrame:frame
                                                                      delegate:delegate
                                                          customMethodDelegate:customMethodDelegate];
                     }];
}

- (MPAdWebView *)buildMPAdWebViewWithFrame:(CGRect)frame delegate:(id<UIWebViewDelegate>)delegate
{
    if (self.fakeMPAdWebView) {
        self.fakeMPAdWebView.delegate = delegate;
        return self.fakeMPAdWebView;
    } else {
        return [self returnFake:self.fakeMPAdWebView
                         orCall:^{
                             return [super buildMPAdWebViewWithFrame:frame
                                                            delegate:delegate];
                         }];
    }
}

- (MPAdDestinationDisplayAgent *)buildMPAdDestinationDisplayAgentWithDelegate:(id<MPAdDestinationDisplayAgentDelegate>)delegate
{
    return [self returnFake:self.fakeMPAdDestinationDisplayAgent
                     orCall:^{
                         return [super buildMPAdDestinationDisplayAgentWithDelegate:delegate];
                     }];
}

- (MPURLResolver *)buildMPURLResolver
{
    return [self returnFake:self.fakeMPURLResolver
                     orCall:^{
                         return [super buildMPURLResolver];
                     }];
}

- (MPHTMLInterstitialViewController *)buildMPHTMLInterstitialViewControllerWithDelegate:(id<MPHTMLInterstitialViewControllerDelegate>)delegate orientationType:(MPInterstitialOrientationType)type customMethodDelegate:(id)customMethodDelegate
{
    return [self returnFake:self.fakeMPHTMLInterstitialViewController
                     orCall:^{
                         return [super buildMPHTMLInterstitialViewControllerWithDelegate:delegate orientationType:type customMethodDelegate:customMethodDelegate];
                     }];
}

- (MPMRAIDInterstitialViewController *)buildMPMRAIDInterstitialViewControllerWithDelegate:(id<MPMRAIDInterstitialViewControllerDelegate>)delegate configuration:(MPAdConfiguration *)configuration
{
    return [self returnFake:self.fakeMPMRAIDInterstitialViewController
                     orCall:^{
                         return [super buildMPMRAIDInterstitialViewControllerWithDelegate:delegate
                                                                            configuration:configuration];
                     }];
}

- (MPAdServerCommunicator *)buildMPAdServerCommunicatorWithDelegate:(id<MPAdServerCommunicatorDelegate>)delegate
{
    self.lastFakeMPAdServerCommunicator = [[[FakeMPAdServerCommunicator alloc] initWithDelegate:delegate] autorelease];
    return self.lastFakeMPAdServerCommunicator;
}

- (MPBaseInterstitialAdapter *)buildInterstitialAdapterForConfiguration:(MPAdConfiguration *)configuration
                                                               delegate:(id<MPBaseInterstitialAdapterDelegate>)delegate
{
    if (self.fakeInterstitialAdapter) {
        self.fakeInterstitialAdapter.delegate = delegate;
        return self.fakeInterstitialAdapter;
    } else {
        return [super buildInterstitialAdapterForConfiguration:configuration
                                                      delegate:delegate];
    }
}

- (MPInterstitialAdManager *)buildMPInterstitialAdManagerWithDelegate:(id<MPInterstitialAdManagerDelegate>)delegate
{
    return [self returnFake:self.fakeMPInterstitialAdManager
                     orCall:^{
                         return [super buildMPInterstitialAdManagerWithDelegate:delegate];
                     }];
}

- (ADInterstitialAd *)buildADInterstitialAd
{
    return [self returnFake:self.fakeADInterstitialAd
                     orCall:^{
                         return [super buildADInterstitialAd];
                     }];
}

- (GADInterstitial *)buildGADInterstitialAd
{
    return [self returnFake:self.fakeGADInterstitial
                     orCall:^{
                         return [super buildGADInterstitialAd];
                     }];
}

- (GADBannerView *)buildGADBannerViewWithFrame:(CGRect)frame
{
    return [self returnFake:self.fakeGADBannerView
                     orCall:^{
                         return [super buildGADBannerViewWithFrame:frame];
                     }];
}

- (GADRequest *)buildGADRequest
{
    return [self returnFake:self.fakeGADRequest
                     orCall:^{
                         return [super buildGADRequest];
                     }];
}

- (MMAdView *)buildMMInterstitialAdWithAPID:(NSString *)apid delegate:(MPMillennialInterstitialAdapter *)delegate
{
    if ([apid length] == 0) {
        return nil;
    }

    if (self.fakeMMAdViewInterstitial) {
        self.fakeMMAdViewInterstitial.apid = apid;
        self.fakeMMAdViewInterstitial.delegate = delegate;
        return self.fakeMMAdViewInterstitial.masquerade;
    }

    return [super buildMMInterstitialAdWithAPID:apid delegate:delegate];
}

- (MMAdView *)buildMMAdViewWithFrame:(CGRect)frame type:(MMAdType)type apid:(NSString *)apid delegate:(id<MMAdDelegate>)delegate
{
    if (self.fakeMMAdViewBanner) {
        self.fakeMMAdViewBanner.frame = frame;
        self.fakeMMAdViewBanner.type = type;
        self.fakeMMAdViewBanner.apid = apid;
        self.fakeMMAdViewBanner.delegate = delegate;
        return self.fakeMMAdViewBanner.masquerade;
    }

    return [super buildMMAdViewWithFrame:frame type:type apid:apid delegate:delegate];
}

- (MPInterstitialCustomEvent *)buildInterstitialCustomEventFromCustomClass:(Class)customClass
                                                                  delegate:(id<MPInterstitialCustomEventDelegate>)delegate
{
    if (self.fakeInterstitialCustomEvent) {
        self.fakeInterstitialCustomEvent.delegate = delegate;
        return self.fakeInterstitialCustomEvent;
    }

    return [super buildInterstitialCustomEventFromCustomClass:customClass delegate:delegate];
}

- (Chartboost *)buildChartboost
{
    return [self returnFake:self.fakeChartboost
                     orCall:^{
                         return [super buildChartboost];
                     }];
}

- (IMAdInterstitial *)buildIMAdInterstitialWithDelegate:(id<IMAdInterstitialDelegate>)delegate appId:(NSString *)appId;
{
    if (self.fakeIMAdInterstitial) {
        self.fakeIMAdInterstitial.imAppId = appId;
        self.fakeIMAdInterstitial.delegate = delegate;
        return self.fakeIMAdInterstitial;
    }
    return [super buildIMAdInterstitialWithDelegate:delegate appId:appId];
}

- (GSFullscreenAd *)buildGSFullscreenAdWithDelegate:(id<GSAdDelegate>)delegate GUID:(NSString *)GUID
{
    if (self.fakeGSFullscreenAd) {
        self.fakeGSFullscreenAd.delegate = delegate;
        self.fakeGSFullscreenAd.GUID = GUID;
        return self.fakeGSFullscreenAd;
    } else {
        return [super buildGSFullscreenAdWithDelegate:delegate GUID:GUID];
    }
}

@end
