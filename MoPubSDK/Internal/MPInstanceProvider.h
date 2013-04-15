//
//  MPInstanceProvider.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MPInterstitialViewController.h"

@class MPAdWebViewAgent;
@class MPAdWebView;
@class MPAdDestinationDisplayAgent;
@class MPURLResolver;
@class MPInterstitialAdManager;
@class MPAdServerCommunicator;
@class MPBaseBannerAdapter;
@class MPBannerCustomEvent;
@class MPBaseInterstitialAdapter;
@class MPInterstitialCustomEvent;
@class MPAdConfiguration;
@class MPHTMLInterstitialViewController;
@class MPAnalyticsTracker;
@class MPReachability;
@class MPMRAIDInterstitialViewController;
@class MPTimer;
@class MPBannerAdManager;

@protocol MPAdWebViewAgentDelegate;
@protocol MPAdDestinationDisplayAgentDelegate;
@protocol MPInterstitialAdManagerDelegate;
@protocol MPAdServerCommunicatorDelegate;
@protocol MPInterstitialAdapterDelegate;
@protocol MPInterstitialViewControllerDelegate;
@protocol MPInterstitialCustomEventDelegate;
@protocol MPBannerAdapterDelegate;
@protocol MPBannerCustomEventDelegate;
@protocol MPBannerAdManagerDelegate;

typedef id(^MPSingletonProviderBlock)();

@interface MPInstanceProvider : NSObject

+ (MPInstanceProvider *)sharedProvider;

- (id)singletonForClass:(Class)klass provider:(MPSingletonProviderBlock)provider;

- (MPReachability *)sharedMPReachability;
- (MPAnalyticsTracker *)sharedMPAnalyticsTracker;

- (MPTimer *)buildMPTimerWithTimeInterval:(NSTimeInterval)seconds target:(id)target selector:(SEL)selector repeats:(BOOL)repeats;

- (NSMutableURLRequest *)buildConfiguredURLRequestWithURL:(NSURL *)URL;

- (MPAdWebViewAgent *)buildMPAdWebViewAgentWithAdWebViewFrame:(CGRect)frame
                                                     delegate:(id<MPAdWebViewAgentDelegate>)delegate
                                         customMethodDelegate:(id)customMethodDelegate;
- (MPAdWebView *)buildMPAdWebViewWithFrame:(CGRect)frame
                                  delegate:(id<UIWebViewDelegate>)delegate;
- (MPAdDestinationDisplayAgent *)buildMPAdDestinationDisplayAgentWithDelegate:(id<MPAdDestinationDisplayAgentDelegate>)delegate;
- (MPURLResolver *)buildMPURLResolver;
- (MPInterstitialAdManager *)buildMPInterstitialAdManagerWithDelegate:(id<MPInterstitialAdManagerDelegate>)delegate;
- (MPAdServerCommunicator *)buildMPAdServerCommunicatorWithDelegate:(id<MPAdServerCommunicatorDelegate>)delegate;
- (MPBannerAdManager *)buildMPBannerAdManagerWithDelegate:(id<MPBannerAdManagerDelegate>)delegate;

- (MPBaseBannerAdapter *)buildBannerAdapterForConfiguration:(MPAdConfiguration *)configuration
                                             delegate:(id<MPBannerAdapterDelegate>)delegate;
- (MPBannerCustomEvent *)buildBannerCustomEventFromCustomClass:(Class)customClass
                                                      delegate:(id<MPBannerCustomEventDelegate>)delegate;

- (MPBaseInterstitialAdapter *)buildInterstitialAdapterForConfiguration:(MPAdConfiguration *)configuration
                                                               delegate:(id<MPInterstitialAdapterDelegate>)delegate;
- (MPInterstitialCustomEvent *)buildInterstitialCustomEventFromCustomClass:(Class)customClass
                                                                  delegate:(id<MPInterstitialCustomEventDelegate>)delegate;

- (MPHTMLInterstitialViewController *)buildMPHTMLInterstitialViewControllerWithDelegate:(id<MPInterstitialViewControllerDelegate>)delegate
                                                                        orientationType:(MPInterstitialOrientationType)type
                                                                   customMethodDelegate:(id)customMethodDelegate;
- (MPMRAIDInterstitialViewController *)buildMPMRAIDInterstitialViewControllerWithDelegate:(id<MPInterstitialViewControllerDelegate>)delegate
                                                                            configuration:(MPAdConfiguration *)configuration;

@end
