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
@class MPBaseAdapter;
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
@protocol MPBaseInterstitialAdapterDelegate;
@protocol MPHTMLInterstitialViewControllerDelegate;
@protocol MPMRAIDInterstitialViewControllerDelegate;
@protocol MPInterstitialCustomEventDelegate;
@protocol MPAdapterDelegate;
@protocol MPBannerCustomEventDelegate;
@protocol MPBannerAdManagerDelegate;

@interface MPInstanceProvider : NSObject

+ (MPInstanceProvider *)sharedProvider;

- (MPAnalyticsTracker *)buildMPAnalyticsTracker;
- (MPReachability *)sharedMPReachability;
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

- (MPBaseAdapter *)buildBannerAdapterForConfiguration:(MPAdConfiguration *)configuration
                                             delegate:(id<MPAdapterDelegate>)delegate;
- (MPBannerCustomEvent *)buildBannerCustomEventFromCustomClass:(Class)customClass
                                                      delegate:(id<MPBannerCustomEventDelegate>)delegate;

- (MPBaseInterstitialAdapter *)buildInterstitialAdapterForConfiguration:(MPAdConfiguration *)configuration
                                                               delegate:(id<MPBaseInterstitialAdapterDelegate>)delegate;
- (MPInterstitialCustomEvent *)buildInterstitialCustomEventFromCustomClass:(Class)customClass
                                                                  delegate:(id<MPInterstitialCustomEventDelegate>)delegate;

- (MPHTMLInterstitialViewController *)buildMPHTMLInterstitialViewControllerWithDelegate:(id<MPHTMLInterstitialViewControllerDelegate>)delegate
                                                                        orientationType:(MPInterstitialOrientationType)type
                                                                   customMethodDelegate:(id)customMethodDelegate;
- (MPMRAIDInterstitialViewController *)buildMPMRAIDInterstitialViewControllerWithDelegate:(id<MPMRAIDInterstitialViewControllerDelegate>)delegate
                                                                            configuration:(MPAdConfiguration *)configuration;

@end
