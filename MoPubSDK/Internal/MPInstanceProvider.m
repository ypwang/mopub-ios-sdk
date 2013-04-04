//
//  MPInstanceProvider.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPInstanceProvider.h"
#import "MPAdWebView.h"
#import "MPAdDestinationDisplayAgent.h"
#import "MPURLResolver.h"
#import "MPAdWebViewAgent.h"
#import "MPInterstitialAdManager.h"
#import "MPAdServerCommunicator.h"
#import "MPAdapterMap.h"
#import "MPInterstitialCustomEventAdapter.h"
#import "MPLegacyInterstitialCustomEventAdapter.h"
#import "MPHTMLInterstitialViewController.h"
#import "MPAnalyticsTracker.h"
#import "MPGlobal.h"
#import "MPMRAIDInterstitialViewController.h"
#import "MPReachability.h"
#import "MPTimer.h"
#import "MPInterstitialCustomEvent.h"

@interface MPInstanceProvider ()

@property (nonatomic, retain) MPReachability *sharedReachability;
@property (nonatomic, copy) NSString *userAgent;

@end

@implementation MPInstanceProvider

@synthesize sharedReachability = _sharedReachability;
@synthesize userAgent = _userAgent;

static MPInstanceProvider *sharedProvider = nil;

+ (MPInstanceProvider *)sharedProvider
{
    if (!sharedProvider) {
        sharedProvider = [[MPInstanceProvider alloc] init];
    }
    return sharedProvider;
}

- (void)dealloc
{
    self.sharedReachability = nil;
    [super dealloc];
}

- (MPTimer *)buildMPTimerWithTimeInterval:(NSTimeInterval)seconds target:(id)target selector:(SEL)selector repeats:(BOOL)repeats
{
    return [MPTimer timerWithTimeInterval:seconds target:target selector:selector repeats:repeats];
}

- (MPAnalyticsTracker *)buildMPAnalyticsTracker
{
    return [MPAnalyticsTracker tracker];
}

- (MPReachability *)sharedMPReachability
{
    if (!self.sharedReachability) {
        self.sharedReachability = [MPReachability reachabilityForLocalWiFi];
    }
    return self.sharedReachability;
}

- (NSString *)userAgent
{
    if (!_userAgent) {
        self.userAgent = [[[[UIWebView alloc] init] autorelease] stringByEvaluatingJavaScriptFromString:@"navigator.userAgent"];
    }

    return _userAgent;
}

- (NSMutableURLRequest *)buildConfiguredURLRequestWithURL:(NSURL *)URL
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    [request setValue:self.userAgent forHTTPHeaderField:@"User-Agent"];
    return request;
}

- (MPAdWebViewAgent *)buildMPAdWebViewAgentWithAdWebViewFrame:(CGRect)frame delegate:(id<MPAdWebViewAgentDelegate>)delegate customMethodDelegate:(id)customMethodDelegate
{
    return [[[MPAdWebViewAgent alloc] initWithAdWebViewFrame:frame delegate:delegate customMethodDelegate:customMethodDelegate] autorelease];
}

- (MPAdWebView *)buildMPAdWebViewWithFrame:(CGRect)frame delegate:(id<UIWebViewDelegate>)delegate
{
    MPAdWebView *webView = [[[MPAdWebView alloc] initWithFrame:frame] autorelease];
    webView.delegate = delegate;
    return webView;
}

- (MPAdDestinationDisplayAgent *)buildMPAdDestinationDisplayAgentWithDelegate:(id<MPAdDestinationDisplayAgentDelegate>)delegate
{
    return [MPAdDestinationDisplayAgent agentWithDelegate:delegate];
}

- (MPURLResolver *)buildMPURLResolver
{
    return [MPURLResolver resolver];
}

- (MPInterstitialAdManager *)buildMPInterstitialAdManagerWithDelegate:(id<MPInterstitialAdManagerDelegate>)delegate
{
    return [[(MPInterstitialAdManager *)[MPInterstitialAdManager alloc] initWithDelegate:delegate] autorelease];
}

- (MPAdServerCommunicator *)buildMPAdServerCommunicatorWithDelegate:(id<MPAdServerCommunicatorDelegate>)delegate
{
    return [[(MPAdServerCommunicator *)[MPAdServerCommunicator alloc] initWithDelegate:delegate] autorelease];
}

- (MPBaseInterstitialAdapter *)buildInterstitialAdapterForConfiguration:(MPAdConfiguration *)configuration
                                                               delegate:(id<MPBaseInterstitialAdapterDelegate>)delegate
{
    if ([configuration.networkType isEqualToString:@"custom"]) {
        if (configuration.customEventClass) {
            return [[(MPInterstitialCustomEventAdapter *)[MPInterstitialCustomEventAdapter alloc] initWithDelegate:delegate] autorelease];
        } else if (configuration.customSelectorName) {
            return [[(MPLegacyInterstitialCustomEventAdapter *)[MPLegacyInterstitialCustomEventAdapter alloc] initWithDelegate:delegate] autorelease];
        } else {
            return nil;
        }
    } else {
        Class adapterClass = [[MPAdapterMap sharedAdapterMap] interstitialAdapterClassForNetworkType:configuration.networkType];
        return [[(MPBaseInterstitialAdapter *)[adapterClass alloc] initWithDelegate:delegate] autorelease];
    }
}

- (MPInterstitialCustomEvent *)buildInterstitialCustomEventFromCustomClass:customClass
                                                                  delegate:(id<MPInterstitialCustomEventDelegate>)delegate
{
    MPInterstitialCustomEvent *customEvent = [[[customClass alloc] init] autorelease];
    customEvent.delegate = delegate;
    return customEvent;
}

- (MPHTMLInterstitialViewController *)buildMPHTMLInterstitialViewControllerWithDelegate:(id<MPHTMLInterstitialViewControllerDelegate>)delegate
                                                                        orientationType:(MPInterstitialOrientationType)type
                                                                   customMethodDelegate:(id)customMethodDelegate
{
    MPHTMLInterstitialViewController *controller = [[[MPHTMLInterstitialViewController alloc] init] autorelease];
    controller.delegate = delegate;
    controller.orientationType = type;
    controller.customMethodDelegate = customMethodDelegate;
    return controller;
}

- (MPMRAIDInterstitialViewController *)buildMPMRAIDInterstitialViewControllerWithDelegate:(id<MPMRAIDInterstitialViewControllerDelegate>)delegate
                                                                            configuration:(MPAdConfiguration *)configuration
{
    MPMRAIDInterstitialViewController *controller = [[[MPMRAIDInterstitialViewController alloc] initWithAdConfiguration:configuration] autorelease];
    controller.delegate = delegate;
    return controller;
}

@end

