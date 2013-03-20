//
//  MPInterstitialCustomEventAdapter.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPInterstitialCustomEventAdapter.h"

#import "MPAdConfiguration.h"
#import "MPInterstitialAdManager.h"
#import "MPInterstitialAdController.h"
#import "MPLogging.h"

@interface MPInterstitialCustomEventAdapter ()

@property (nonatomic, retain) MPInterstitialCustomEvent *interstitialCustomEvent;

@end

@implementation MPInterstitialCustomEventAdapter

@synthesize interstitialCustomEvent = _interstitialCustomEvent;

- (void)dealloc
{
    self.interstitialCustomEvent.delegate = nil;
    self.interstitialCustomEvent = nil;

    [super dealloc];
}


- (void)getAdWithConfiguration:(MPAdConfiguration *)configuration
{
    Class customEventClass = configuration.customEventClass;

    MPLogInfo(@"Looking for custom event class named %@.", configuration.customEventClass);

    if (customEventClass) {
        [self loadAdFromCustomClass:customEventClass configuration:configuration];
        return;
    }

    MPLogInfo(@"Looking for custom event selector named %@.", configuration.customSelectorName);

    SEL customEventSelector = NSSelectorFromString(configuration.customSelectorName);
    if ([self.delegate.interstitialDelegate respondsToSelector:customEventSelector]) {
        [self.delegate.interstitialDelegate performSelector:customEventSelector];
        return;
    }

    NSString *oneArgumentSelectorName = [configuration.customSelectorName
                                         stringByAppendingString:@":"];

    MPLogInfo(@"Looking for custom event selector named %@.", oneArgumentSelectorName);

    SEL customEventOneArgumentSelector = NSSelectorFromString(oneArgumentSelectorName);
    if ([self.delegate.interstitialDelegate respondsToSelector:customEventOneArgumentSelector]) {
        [self.delegate.interstitialDelegate performSelector:customEventOneArgumentSelector
                                                 withObject:self.delegate.interstitialAdController];
        return;
    }

    MPLogInfo(@"Could not handle custom event request.");

    [self.delegate adapter:self didFailToLoadAdWithError:nil];
}

- (void)loadAdFromCustomClass:(Class)customClass configuration:(MPAdConfiguration *)configuration
{
    self.interstitialCustomEvent = [[[customClass alloc] init] autorelease];
    self.interstitialCustomEvent.delegate = self;
    [self.interstitialCustomEvent requestInterstitialWithCustomEventInfo:configuration.customEventClassData];
}

- (void)showInterstitialFromViewController:(UIViewController *)controller
{
    [self.interstitialCustomEvent showInterstitialFromRootViewController:controller];
}

#pragma mark - MPInterstitialCustomEventDelegate

- (void)interstitialCustomEvent:(MPInterstitialCustomEvent *)customEvent
                      didLoadAd:(id)ad
{
    [self.delegate adapterDidFinishLoadingAd:self];
}

- (void)interstitialCustomEvent:(MPInterstitialCustomEvent *)customEvent
       didFailToLoadAdWithError:(NSError *)error
{
    [self.delegate adapter:self didFailToLoadAdWithError:error];
}

- (void)interstitialCustomEventWillAppear:(MPInterstitialCustomEvent *)customEvent
{
    [self.delegate interstitialWillAppearForAdapter:self];
    [self.delegate interstitialDidAppearForAdapter:self];
}

- (void)interstitialCustomEventDidDisappear:(MPInterstitialCustomEvent *)customEvent
{
    [self.delegate interstitialWillDisappearForAdapter:self];
    [self.delegate interstitialDidDisappearForAdapter:self];
}

- (void)interstitialCustomEventWillLeaveApplication:(MPInterstitialCustomEvent *)customEvent
{
    [self.delegate interstitialWillLeaveApplicationForAdapter:self];
}

@end
