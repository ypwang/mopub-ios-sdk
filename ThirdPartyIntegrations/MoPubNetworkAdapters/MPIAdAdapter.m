//
//  MPIAdAdapter.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPIAdAdapter.h"
#import "MPInstanceProvider.h"
#import <iAd/iAd.h>

@protocol MPADBannerViewManagerObserver <NSObject>

- (void)bannerDidLoad;
- (void)bannerDidFail;
- (void)bannerActionWillBeginAndWillLeaveApplication:(BOOL)willLeave;
- (void)bannerActionDidFinish;

@end

@interface MPIAdAdapter () <MPADBannerViewManagerObserver>

@property (nonatomic, retain) ADBannerView *bannerView;
@property (nonatomic, assign) BOOL onScreen;
@property (nonatomic, assign) BOOL trackImpressionWhenPresented;

@end

/////////////////////////////////////////////////////////////////////////////////////

@interface MPInstanceProvider (iAdBanners)

- (ADBannerView *)buildADBannerView;

@end

@implementation MPInstanceProvider (iAdBanners)

- (ADBannerView *)buildADBannerView
{
    return [[[ADBannerView alloc] init] autorelease];
}

@end

/////////////////////////////////////////////////////////////////////////////////////

@interface MPADBannerViewManager : NSObject <ADBannerViewDelegate>

@property (nonatomic, retain) ADBannerView *bannerView;
@property (nonatomic, retain) NSMutableSet *observers;
@property (nonatomic, assign) BOOL hasTrackedImpression;
@property (nonatomic, assign) BOOL hasTrackedClick;

+ (MPADBannerViewManager *)sharedManager;

- (void)registerAdapter:(MPIAdAdapter *)adapter;
- (void)unregisterAdapter:(MPIAdAdapter *)adapter;
- (BOOL)shouldTrackImpression;
- (void)didTrackImpression;
- (BOOL)shouldTrackClick;
- (void)didTrackClick;

@end

@implementation MPADBannerViewManager

@synthesize bannerView = _bannerView;
@synthesize observers = _observers;
@synthesize hasTrackedImpression = _hasTrackedImpression;
@synthesize hasTrackedClick = _hasTrackedClick;

static MPADBannerViewManager *sharedManager = nil;

+ (MPADBannerViewManager *)sharedManager
{
    if (!sharedManager) {
        sharedManager = [[self alloc] init];
    }
    return sharedManager;
}

+ (void)resetSharedManager
{
    sharedManager = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.bannerView = [[MPInstanceProvider sharedProvider] buildADBannerView];
        self.bannerView.delegate = self;
        self.observers = [NSMutableSet set];
    }
    return self;
}

- (void)dealloc
{
    self.bannerView.delegate = nil;
    self.bannerView = nil;
    self.observers = nil;
    [super dealloc];
}

- (void)registerAdapter:(MPIAdAdapter *)adapter
{
    [self.observers addObject:adapter];
}

- (void)unregisterAdapter:(MPIAdAdapter *)adapter
{
    [self.observers removeObject:adapter];
}

- (BOOL)shouldTrackImpression
{
    return !self.hasTrackedImpression;
}

- (void)didTrackImpression
{
    self.hasTrackedImpression = YES;
}

- (BOOL)shouldTrackClick
{
    return !self.hasTrackedClick;
}

- (void)didTrackClick
{
    self.hasTrackedClick = YES;
}

#pragma mark - <ADBannerViewDelegate>

- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    self.hasTrackedImpression = NO;
    self.hasTrackedClick = NO;

    for (MPIAdAdapter *adapter in self.observers) {
        [adapter bannerDidLoad];
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    for (MPIAdAdapter *adapter in self.observers) {
        [adapter bannerDidFail];
    }
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    for (MPIAdAdapter *adapter in self.observers) {
        [adapter bannerActionWillBeginAndWillLeaveApplication:willLeave];
    }
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    for (MPIAdAdapter *adapter in self.observers) {
        [adapter bannerActionDidFinish];
    }
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MPIAdAdapter

@synthesize bannerView = _bannerView;
@synthesize onScreen = _onScreen;

- (void)dealloc
{
    self.bannerView = nil;
    [super dealloc];
}

- (void)getAdWithConfiguration:(MPAdConfiguration *)configuration containerSize:(CGSize)size
{
    self.bannerView = [MPADBannerViewManager sharedManager].bannerView;
    [[MPADBannerViewManager sharedManager] registerAdapter:self];

    if (self.bannerView.isBannerLoaded) {
        [self bannerDidLoad];
    }
}

- (void)unregisterDelegate
{
    self.onScreen = NO;
    [[MPADBannerViewManager sharedManager] unregisterAdapter:self];

    [super unregisterDelegate];
}

- (void)didDisplayAd
{
    self.onScreen = YES;
    [self trackImpressionIfNecessary];
}

- (void)trackImpressionIfNecessary
{
    if (self.onScreen && [[MPADBannerViewManager sharedManager] shouldTrackImpression]) {
        [super trackImpression];
        [[MPADBannerViewManager sharedManager] didTrackImpression];
    }
}

- (void)trackClickIfNecessary
{
    if ([[MPADBannerViewManager sharedManager] shouldTrackClick]) {
        [super trackClick];
        [[MPADBannerViewManager sharedManager] didTrackClick];
    }
}

#pragma mark - <MPADBannerViewManagerObserver>

- (void)bannerDidLoad
{
    [self trackImpressionIfNecessary];
    [self didStopLoading];
    [self.delegate adapter:self didFinishLoadingAd:self.bannerView];
}

- (void)bannerDidFail
{
    [self didStopLoading];
    [self.delegate adapter:self didFailToLoadAdWithError:nil];
}

- (void)bannerActionWillBeginAndWillLeaveApplication:(BOOL)willLeave
{
    [self trackClickIfNecessary];
    if (willLeave) {
        [self.delegate userWillLeaveApplicationFromAdapter:self];
    } else {
        [self.delegate userActionWillBeginForAdapter:self];
    }
}

- (void)bannerActionDidFinish
{
    [self.delegate userActionDidFinishForAdapter:self];
}

@end
