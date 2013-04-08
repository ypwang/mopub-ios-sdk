//
//  MPBannerCustomEventAdapter.m
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import "MPBannerCustomEventAdapter.h"

#import "MPAdConfiguration.h"
#import "MPBannerCustomEvent.h"
#import "MPInstanceProvider.h"

@interface MPBannerCustomEventAdapter ()

@property (nonatomic, retain) MPBannerCustomEvent *bannerCustomEvent;

- (void)loadAdFromCustomClass:(Class)customClass configuration:(MPAdConfiguration *)configuration;

@end

@implementation MPBannerCustomEventAdapter

- (void)dealloc
{
    [self.bannerCustomEvent customEventDidUnload];
    self.bannerCustomEvent.delegate = nil;
    self.bannerCustomEvent = nil;
    
    [super dealloc];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)getAdWithConfiguration:(MPAdConfiguration *)configuration
{
    Class customEventClass = configuration.customEventClass;
    
    MPLogInfo(@"Looking for custom event class named %@.", configuration.customEventClass);
    
    if (customEventClass) {
        [self loadAdFromCustomClass:customEventClass configuration:configuration];
        return;
    }
    
    MPLogInfo(@"Could not handle custom event request.");
    
    [self.delegate adapter:self didFailToLoadAdWithError:nil];
}

- (void)loadAdFromCustomClass:(Class)customClass configuration:(MPAdConfiguration *)configuration
{
    self.bannerCustomEvent = [[MPInstanceProvider sharedProvider] buildBannerCustomEventFromCustomClass:customClass delegate:self];
    [self.bannerCustomEvent requestAdWithSize:configuration.adSize customEventInfo:configuration.customEventClassData];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - MPBannerCustomEventDelegate

- (UIViewController *)viewControllerForPresentingModalView
{
    return [self.delegate viewControllerForPresentingModalView];
}

- (void)bannerCustomEvent:(MPBannerCustomEvent *)event didLoadAd:(UIView *)ad
{
    [self.delegate adapter:self didFinishLoadingAd:ad shouldTrackImpression:YES];
}

- (void)bannerCustomEvent:(MPBannerCustomEvent *)event didFailToLoadAdWithError:(NSError *)error
{
    [self.delegate adapter:self didFailToLoadAdWithError:error];
}

- (void)bannerCustomEventWillBeginAction:(MPBannerCustomEvent *)event
{
    [self.delegate userActionWillBeginForAdapter:self];
}

- (void)bannerCustomEventDidFinishAction:(MPBannerCustomEvent *)event
{
    [self.delegate userActionDidFinishForAdapter:self];
}

- (void)bannerCustomEventWillLeaveApplication:(MPBannerCustomEvent *)event
{
    [self.delegate userWillLeaveApplicationFromAdapter:self];
}

@end
