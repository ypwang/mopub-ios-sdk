//
//  FakeMPInstanceProvider.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPInstanceProvider.h"
#import "FakeMPAdServerCommunicator.h"
#import "FakeInterstitialAdapter.h"
#import "FakeMPAnalyticsTracker.h"
#import <iAd/iAd.h>
#import "GADInterstitial.h"
#import "GADBannerView.h"
#import "FakeMMInterstitialAdView.h"
#import "FakeInterstitialCustomEvent.h"
#import "Chartboost.h"
#import "FakeGSFullscreenAd.h"
#import "IMAdInterstitial.h"
#import "MPInterstitialAdManager.h"
#import "GADRequest.h"
#import "FakeMMBannerAdView.h"
#import "FakeMPReachability.h"
#import "MPBaseAdapter.h"
#import "FakeBannerCustomEvent.h"
#import "FakeMPTimer.h"

@interface FakeMPInstanceProvider : MPInstanceProvider

@property (nonatomic, assign) MPAdWebViewAgent *fakeMPAdWebViewAgent;
@property (nonatomic, assign) MPAdWebView *fakeMPAdWebView;
@property (nonatomic, assign) MPAdDestinationDisplayAgent *fakeMPAdDestinationDisplayAgent;
@property (nonatomic, assign) MPURLResolver *fakeMPURLResolver;
@property (nonatomic, assign) MPHTMLInterstitialViewController *fakeMPHTMLInterstitialViewController;
@property (nonatomic, assign) MPMRAIDInterstitialViewController *fakeMPMRAIDInterstitialViewController;
@property (nonatomic, assign) MPInterstitialAdManager *fakeMPInterstitialAdManager;

@property (nonatomic, assign) MPBaseAdapter *fakeBannerAdapter;
@property (nonatomic, assign) FakeBannerCustomEvent *fakeBannerCustomEvent;
@property (nonatomic, assign) MPBaseInterstitialAdapter *fakeInterstitialAdapter;
@property (nonatomic, assign) FakeInterstitialCustomEvent *fakeInterstitialCustomEvent;

@property (nonatomic, assign) ADInterstitialAd *fakeADInterstitialAd;
@property (nonatomic, assign) ADBannerView *fakeADBannerView;

@property (nonatomic, assign) GADInterstitial *fakeGADInterstitial;
@property (nonatomic, assign) GADBannerView *fakeGADBannerView;
@property (nonatomic, assign) GADRequest *fakeGADRequest;

@property (nonatomic, assign) FakeMMInterstitialAdView *fakeMMAdViewInterstitial;
@property (nonatomic, assign) FakeMMBannerAdView *fakeMMAdViewBanner;
@property (nonatomic, assign) Chartboost *fakeChartboost;
@property (nonatomic, assign) FakeGSFullscreenAd *fakeGSFullscreenAd;
@property (nonatomic, assign) IMAdInterstitial *fakeIMAdInterstitial;

@property (nonatomic, assign) FakeMPReachability *fakeMPReachability;

@property (nonatomic, assign) FakeMPAdServerCommunicator *lastFakeMPAdServerCommunicator;

- (FakeMPAnalyticsTracker *)sharedFakeMPAnalyticsTracker;
- (void)advanceMPTimers:(NSTimeInterval)timeInterval;
- (NSMutableArray *)fakeTimers;
- (FakeMPTimer *)lastFakeMPTimerWithSelector:(SEL)selector;

@end
