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
#import "MPBaseAdapter.h"
#import "MPBannerCustomEventAdapter.h"
#import "MPLegacyBannerCustomEventAdapter.h"
#import "MPBannerCustomEvent.h"
#import "MPBannerAdManager.h"

@interface MPInstanceProvider ()

@property (nonatomic, copy) NSString *userAgent;
@property (nonatomic, retain) NSMutableDictionary *singletons;

@end

@implementation MPInstanceProvider

@synthesize userAgent = _userAgent;
@synthesize singletons = _singletons;

static MPInstanceProvider *sharedProvider = nil;

+ (MPInstanceProvider *)sharedProvider
{
    if (!sharedProvider) {
        sharedProvider = [[MPInstanceProvider alloc] init];
    }
    return sharedProvider;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.singletons = [NSMutableDictionary dictionary];
    }
    return self;
}

- (void)dealloc
{
    self.singletons = nil;
    [super dealloc];
}

- (id)singletonForClass:(Class)klass provider:(MPSingletonProviderBlock)provider
{
    id singleton = [self.singletons objectForKey:klass];
    if (!singleton) {
        singleton = provider();
        [self.singletons setObject:singleton forKey:(id<NSCopying>)klass];
    }
    return singleton;
}

- (MPTimer *)buildMPTimerWithTimeInterval:(NSTimeInterval)seconds target:(id)target selector:(SEL)selector repeats:(BOOL)repeats
{
    return [MPTimer timerWithTimeInterval:seconds target:target selector:selector repeats:repeats];
}

- (MPReachability *)sharedMPReachability
{
    return [self singletonForClass:[MPReachability class] provider:^id{
        return [MPReachability reachabilityForLocalWiFi];
    }];
}

- (MPAnalyticsTracker *)sharedMPAnalyticsTracker
{
    return [self singletonForClass:[MPAnalyticsTracker class] provider:^id{
        return [MPAnalyticsTracker tracker];
    }];
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

- (MPBannerAdManager *)buildMPBannerAdManagerWithDelegate:(id<MPBannerAdManagerDelegate>)delegate
{
    return [[(MPBannerAdManager *)[MPBannerAdManager alloc] initWithDelegate:delegate] autorelease];
}

- (MPBaseAdapter *)buildBannerAdapterForConfiguration:(MPAdConfiguration *)configuration
                                             delegate:(id<MPAdapterDelegate>)delegate
{
    [configuration setUpCustomEventClassForBanner];
    if (configuration.customEventClass) {
        return [[(MPBannerCustomEventAdapter *)[MPBannerCustomEventAdapter alloc] initWithAdapterDelegate:delegate] autorelease];
    } else if (configuration.customSelectorName) {
        return [[(MPLegacyBannerCustomEventAdapter *)[MPLegacyBannerCustomEventAdapter alloc] initWithAdapterDelegate:delegate] autorelease];
    }

    return nil;
}

- (MPBannerCustomEvent *)buildBannerCustomEventFromCustomClass:(Class)customClass
                                                      delegate:(id<MPBannerCustomEventDelegate>)delegate
{
    MPBannerCustomEvent *customEvent = [[[customClass alloc] init] autorelease];
    customEvent.delegate = delegate;
    return customEvent;
}


- (MPBaseInterstitialAdapter *)buildInterstitialAdapterForConfiguration:(MPAdConfiguration *)configuration
                                                               delegate:(id<MPBaseInterstitialAdapterDelegate>)delegate
{
    [configuration setUpCustomEventClassForInterstitial];
    if (configuration.customEventClass) {
        return [[(MPInterstitialCustomEventAdapter *)[MPInterstitialCustomEventAdapter alloc] initWithDelegate:delegate] autorelease];
    } else if (configuration.customSelectorName) {
        return [[(MPLegacyInterstitialCustomEventAdapter *)[MPLegacyInterstitialCustomEventAdapter alloc] initWithDelegate:delegate] autorelease];
    } else {
        Class adapterClass = [[MPAdapterMap sharedAdapterMap] interstitialAdapterClassForNetworkType:configuration.networkType];
        return [[(MPBaseInterstitialAdapter *)[adapterClass alloc] initWithDelegate:delegate] autorelease];
    }
}

- (MPInterstitialCustomEvent *)buildInterstitialCustomEventFromCustomClass:(Class)customClass
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

