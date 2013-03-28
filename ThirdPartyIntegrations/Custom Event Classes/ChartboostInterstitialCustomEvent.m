//
//  ChartboostInterstitialCustomEvent.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "ChartboostInterstitialCustomEvent.h"
#import "MPInstanceProvider.h"
#import "MPLogging.h"

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPInstanceProvider (ChartboostInterstitials)

- (Chartboost *)buildChartboost;

@end

@implementation MPInstanceProvider (ChartboostInterstitials)

- (Chartboost *)buildChartboost
{
    return [Chartboost sharedChartboost];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPChartboostRouter : NSObject <ChartboostDelegate>

@property (nonatomic, retain) NSMutableDictionary *events;
@property (nonatomic, retain) Chartboost *chartboost;

+ (MPChartboostRouter *)sharedRouter;

- (void)cacheInterstitialWithCustomEventInfo:(NSDictionary *)info forChartboostInterstitialCustomEvent:(ChartboostInterstitialCustomEvent *)event;
- (ChartboostInterstitialCustomEvent *)eventForLocation:(NSString *)location;
- (void)setEvent:(ChartboostInterstitialCustomEvent *)event forLocation:(NSString *)location;
- (void)unregisterEventForLocation:(NSString *)location;
- (BOOL)hasCachedInterstitialForLocation:(NSString *)location;
- (void)showInterstitialForLocation:(NSString *)location;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface ChartboostInterstitialCustomEvent ()

@property (nonatomic, retain) NSString *location;

@end

@implementation ChartboostInterstitialCustomEvent

@synthesize location = _location;

- (void)customEventDidUnload
{
    [[MPChartboostRouter sharedRouter] unregisterEventForLocation:self.location];
    self.location = nil;
    [super customEventDidUnload];
}

#pragma mark - MPInterstitialCustomEvent Subclass Methods

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    NSString *location = [info objectForKey:@"location"];
    self.location = location;

    MPLogInfo(@"Requesting Chartboost interstitial.");
    [[MPChartboostRouter sharedRouter] cacheInterstitialWithCustomEventInfo:info
                                       forChartboostInterstitialCustomEvent:self];
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    if ([[MPChartboostRouter sharedRouter] hasCachedInterstitialForLocation:self.location]) {
        MPLogInfo(@"Chartboost interstitial will be shown.");

        // Normally, we call the "will appear" and "did appear" methods in response to
        // callbacks from Third Party Integrations. Unfortunately, Chartboost doesn't seem to have
        // such callbacks, so we call the methods manually.
        [self.delegate interstitialCustomEventWillAppear:self];
        [[MPChartboostRouter sharedRouter] showInterstitialForLocation:self.location];
        [self.delegate interstitialCustomEventDidAppear:self];
    } else {
        MPLogInfo(@"Failed to show Chartboost interstitial.");
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
    }
}

#pragma mark - ChartboostDelegate

- (void)didCacheInterstitial:(NSString *)location
{
    MPLogInfo(@"Successfully loaded Chartboost interstitial.");

    [self.delegate interstitialCustomEvent:self didLoadAd:nil];
}

- (void)didFailToLoadInterstitial:(NSString *)location
{
    MPLogInfo(@"Failed to load Chartboost interstitial.");

    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)didDismissInterstitial:(NSString *)location
{
    MPLogInfo(@"Chartboost interstitial was dismissed.");

    // Chartboost doesn't seem to have a separate callback for the "will disappear" event, so we
    // signal "will disappear" manually.

    [self.delegate interstitialCustomEventWillDisappear:self];
    [self.delegate interstitialCustomEventDidDisappear:self];
}

- (void)didClickInterstitial:(NSString *)location
{
    [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

/*
 * Chartboost only provides a shared instance, so only one object may be the Chartboost delegate at
 * any given time. However, because it is common to request Chartboost interstitials for separate
 * "locations" in a single app session, we may have multiple instances of our custom event class,
 * all of which are interested in delegate callbacks.
 *
 * MPChartboostRouter is a singleton that is always the Chartboost delegate, and dispatches
 * events to all of the custom event instances.
 */

@implementation MPChartboostRouter

@synthesize events = _events;

static MPChartboostRouter *sharedRouter = nil;

+ (MPChartboostRouter *)sharedRouter
{
    if (!sharedRouter) {
        sharedRouter = [[self alloc] init];
    }
    return sharedRouter;
}

+ (void)resetSharedRouter
{
    sharedRouter = nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        self.events = [NSMutableDictionary dictionary];
        self.chartboost = [[MPInstanceProvider sharedProvider] buildChartboost];
        self.chartboost.delegate = self;
    }
    return self;
}

- (void)dealloc
{
    self.chartboost = nil;
    self.events = nil;
    [super dealloc];
}

- (void)cacheInterstitialWithCustomEventInfo:(NSDictionary *)info forChartboostInterstitialCustomEvent:(ChartboostInterstitialCustomEvent *)event
{
    NSString *appId = [info objectForKey:@"appId"];
    NSString *appSignature = [info objectForKey:@"appSignature"];
    NSString *location = [info objectForKey:@"location"];

    if ([self eventForLocation:location]) {
        MPLogInfo(@"Failed to load Chartboost interstitial: this location is already in use.");
        [event didFailToLoadInterstitial:location];
        return;
    }

    if ([appId length] > 0 && [appSignature length] > 0) {
        [self setEvent:event forLocation:location];

        self.chartboost.appId = appId;
        self.chartboost.appSignature = appSignature;

        [self.chartboost startSession];
        [self.chartboost cacheInterstitial:location];
    } else {
        MPLogInfo(@"Failed to load Chartboost interstitial: missing either appId or appSignature.");
        [event didFailToLoadInterstitial:location];
    }
}

- (BOOL)hasCachedInterstitialForLocation:(NSString *)location
{
    return [self.chartboost hasCachedInterstitial:location];
}

- (void)showInterstitialForLocation:(NSString *)location
{
    [self.chartboost showInterstitial:location];
}

- (ChartboostInterstitialCustomEvent *)eventForLocation:(NSString *)location
{
    return [self.events objectForKey:location ? location : [NSNull null]];
}

- (void)setEvent:(ChartboostInterstitialCustomEvent *)event forLocation:(NSString *)location
{
    [self.events setObject:event forKey:location ? location : [NSNull null]];
}

- (void)unregisterEventForLocation:(NSString *)location
{
    [self.events removeObjectForKey:location ? location : [NSNull null]];
}

- (void)didCacheInterstitial:(NSString *)location
{
    [[self eventForLocation:location] didCacheInterstitial:location];
}

- (void)didFailToLoadInterstitial:(NSString *)location
{
    [[self eventForLocation:location] didFailToLoadInterstitial:location];
    [self unregisterEventForLocation:location];
}

- (void)didDismissInterstitial:(NSString *)location
{
    [[self eventForLocation:location] didDismissInterstitial:location];
    [self unregisterEventForLocation:location];
}

- (void)didClickInterstitial:(NSString *)location
{
    [[self eventForLocation:location] didClickInterstitial:location];
}

@end

