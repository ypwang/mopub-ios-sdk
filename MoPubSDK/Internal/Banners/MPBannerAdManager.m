//
//  MPBannerAdManager.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPBannerAdManager.h"
#import "MPAdServerURLBuilder.h"
#import "MPInstanceProvider.h"
#import "MPBannerAdManagerDelegate.h"
#import "MPError.h"
#import "MPTimer.h"

@interface MPBannerAdManager ()

@property (nonatomic, retain) MPAdServerCommunicator *communicator;
@property (nonatomic, retain) MPBaseAdapter *onscreenAdapter;
@property (nonatomic, retain) MPBaseAdapter *requestingAdapter;
@property (nonatomic, retain) UIView *requestingAdapterAdContentView;
@property (nonatomic, retain) MPAdConfiguration *requestingConfiguration;
@property (nonatomic, retain) MPTimer *refreshTimer;
@property (nonatomic, assign) BOOL adActionInProgress;

- (void)loadAdWithURL:(NSURL *)URL;
- (void)scheduleRefreshTimer;
- (void)refreshTimerDidFire;

@end

@implementation MPBannerAdManager

@synthesize delegate = _delegate;
@synthesize communicator = _communicator;
@synthesize onscreenAdapter = _onscreenAdapter;
@synthesize requestingAdapter = _requestingAdapter;
@synthesize refreshTimer = _refreshTimer;
@synthesize adActionInProgress = _adActionInProgress;

- (id)initWithDelegate:(id<MPBannerAdManagerDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;

        self.communicator = [[MPInstanceProvider sharedProvider] buildMPAdServerCommunicatorWithDelegate:self];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(forceRefreshAd)
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:[UIApplication sharedApplication]];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [self.communicator cancel];
    self.communicator = nil;

    [self.refreshTimer invalidate];
    self.refreshTimer = nil;

    [self.onscreenAdapter unregisterDelegate];
    self.onscreenAdapter = nil;

    [self.requestingAdapter unregisterDelegate];
    self.requestingAdapter = nil;
    self.requestingAdapterAdContentView = nil;
    self.requestingConfiguration = nil;

    [super dealloc];
}

- (BOOL)loading
{
    return self.communicator.loading || self.requestingAdapter;
}

- (void)loadAd
{
    if (self.loading) {
        MPLogWarn(@"Banner view (%@) is already loading an ad. Wait for previous load to finish.", [self.delegate adUnitId]);
        return;
    }

    [self loadAdWithURL:nil];
}

- (void)forceRefreshAd
{
    [self loadAdWithURL:nil];
}

- (void)loadAdWithURL:(NSURL *)URL
{
    URL = [URL copy]; //if this is the URL from the requestingConfiguration, it's about to die...
    // Cancel the current request/requesting adapter
    self.requestingConfiguration = nil;
    [self.requestingAdapter unregisterDelegate];
    self.requestingAdapter = nil;
    self.requestingAdapterAdContentView = nil;

    [self.communicator cancel];

    URL = (URL) ? URL : [MPAdServerURLBuilder URLWithAdUnitID:[self.delegate adUnitId]
                                                     keywords:[self.delegate keywords]
                                                     location:[self.delegate location]
                                                      testing:[self.delegate isTesting]];

    MPLogInfo(@"Banner view (%@) loading ad with MoPub server URL: %@", [self.delegate adUnitId], URL);

    [self.communicator loadURL:URL];
}

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation
{
    [self.requestingAdapter rotateToOrientation:orientation];
    [self.onscreenAdapter rotateToOrientation:orientation];
}

#pragma mark - Deprecated Public Interface

- (void)customEventDidLoadAd
{
    // the requesting adapter will send this message
    // nil out the requesting adapter (signifies load is done)
    // don't tell the delegate
    // start the refresh timer
}

- (void)customEventDidFailToLoadAd
{
    // waterfall
}

- (void)customEventActionWillBegin
{
    //ad action in progress
}

- (void)customEventActionDidEnd
{
    //ad action not in progress
    //presentRequestingAdapter
}

#pragma mark - Internal

- (void)scheduleRefreshTimer
{
    [self.refreshTimer invalidate];
    NSTimeInterval timeInterval = self.requestingConfiguration ? self.requestingConfiguration.refreshInterval : 60;

    if (timeInterval > 0) {
        self.refreshTimer = [[MPInstanceProvider sharedProvider] buildMPTimerWithTimeInterval:timeInterval
                                                                                       target:self
                                                                                     selector:@selector(refreshTimerDidFire)
                                                                                      repeats:NO];
        [self.refreshTimer scheduleNow];
    }
}

- (void)refreshTimerDidFire
{
    if (!self.loading) {
        [self loadAd];
    }
}

#pragma mark - <MPAdServerCommunicatorDelegate>

- (void)communicatorDidReceiveAdConfiguration:(MPAdConfiguration *)configuration
{
    self.requestingConfiguration = configuration;

    if (configuration.adType == MPAdTypeUnknown) {
        [self didFailToLoadAdapterWithError:[MPError errorWithCode:MPErrorServerError]];
        return;
    }

    if (configuration.adType == MPAdTypeInterstitial) {
        [self didFailToLoadAdapterWithError:[MPError errorWithCode:MPErrorAdapterInvalid]];
        return;
    }

    if ([configuration.networkType isEqualToString:kAdTypeClear]) {
        [self didFailToLoadAdapterWithError:[MPError errorWithCode:MPErrorNoInventory]];
        return;
    }

    self.requestingAdapter = [[MPInstanceProvider sharedProvider] buildBannerAdapterForConfiguration:configuration
                                                                                            delegate:self];
    if (!self.requestingAdapter) {
        [self loadAdWithURL:self.requestingConfiguration.failoverURL];
        return;
    }

    [self.requestingAdapter _getAdWithConfiguration:configuration containerSize:self.delegate.containerSize];
}

- (void)communicatorDidFailWithError:(NSError *)error
{
    [self didFailToLoadAdapterWithError:error];
}

- (void)didFailToLoadAdapterWithError:(NSError *)error
{
    [self.delegate managerDidFailToLoadAd];
    [self scheduleRefreshTimer];

    MPLogError(@"Banner view (%@) failed. Error: %@", [self.delegate adUnitId], error);
}

#pragma mark - <MPAdapterDelegate>

- (MPAdView *)banner
{
    return [self.delegate banner];
}

- (id<MPAdViewDelegate>)bannerDelegate
{
    return [self.delegate bannerDelegate];
}

- (UIViewController *)viewControllerForPresentingModalView
{
    return [self.delegate viewControllerForPresentingModalView];
}

- (MPNativeAdOrientation)allowedNativeAdsOrientation
{
    return [self.delegate allowedNativeAdsOrientation];
}

- (CLLocation *)location
{
    return [self.delegate location];
}

- (void)presentRequestingAdapter
{
    if (!self.adActionInProgress && self.requestingAdapterAdContentView) {
        [self.onscreenAdapter unregisterDelegate];
        self.onscreenAdapter = self.requestingAdapter;
        self.requestingAdapter = nil;

        [self.delegate managerDidLoadAd:self.requestingAdapterAdContentView];
        [self.onscreenAdapter didDisplayAd];

        self.requestingAdapterAdContentView = nil;
        if (![self.delegate ignoresAutorefresh]) {
            [self scheduleRefreshTimer];
        }
    }
}

- (void)adapter:(MPBaseAdapter *)adapter didFinishLoadingAd:(UIView *)ad
{
    if (self.requestingAdapter == adapter) {
        self.requestingAdapterAdContentView = ad;
        [self presentRequestingAdapter];
    }
}

- (void)adapter:(MPBaseAdapter *)adapter didFailToLoadAdWithError:(NSError *)error
{
    if (self.requestingAdapter == adapter) {
        [self loadAdWithURL:self.requestingConfiguration.failoverURL];
    }

    if (self.onscreenAdapter == adapter) {
        // the onscreen adapter has failed.  we need to:
        // 1) remove it
        // 2) tell the delegate
        // 3) and note that there can't possibly be a modal on display any more
        [self.delegate managerDidFailToLoadAd];
        [self.delegate invalidateContentView];
        [self.onscreenAdapter unregisterDelegate];
        self.onscreenAdapter = nil;
        if (self.adActionInProgress) {
            [self.delegate userActionDidFinish];
        }
        self.adActionInProgress = NO;
        [self loadAd];
    }
}

- (void)userActionWillBeginForAdapter:(MPBaseAdapter *)adapter
{
    if (self.onscreenAdapter == adapter) {
        self.adActionInProgress = YES;
        [self.delegate userActionWillBegin];
    }
}

- (void)userActionDidFinishForAdapter:(MPBaseAdapter *)adapter
{
    if (self.onscreenAdapter == adapter) {
        [self.delegate userActionDidFinish];
        self.adActionInProgress = NO;
        [self presentRequestingAdapter];
    }
}

- (void)userWillLeaveApplicationFromAdapter:(MPBaseAdapter *)adapter
{
    if (self.onscreenAdapter == adapter) {
        [self.delegate userWillLeaveApplication];
    }
}

@end


