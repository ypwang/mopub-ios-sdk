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

- (void)getAdWithConfiguration:(MPAdConfiguration *)configuration containerSize:(CGSize)size
{
    Class customEventClass = configuration.customEventClass;

    MPLogInfo(@"Looking for custom event class named %@.", configuration.customEventClass);

    if (customEventClass) {
        self.bannerCustomEvent = [[MPInstanceProvider sharedProvider] buildBannerCustomEventFromCustomClass:customEventClass
                                                                                                   delegate:self];
        [self.bannerCustomEvent requestAdWithSize:size customEventInfo:configuration.customEventClassData];
        return;
    }

    MPLogInfo(@"Could not handle custom event request.");

    [self.delegate adapter:self didFailToLoadAdWithError:nil];
}

- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation
{
    [self.bannerCustomEvent rotateToOrientation:newOrientation];
}

////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark - MPBannerCustomEventDelegate

- (UIViewController *)viewControllerForPresentingModalView
{
    return [self.delegate viewControllerForPresentingModalView];
}

- (void)bannerCustomEvent:(MPBannerCustomEvent *)event didLoadAd:(UIView *)ad
{
    [self.delegate adapter:self didFinishLoadingAd:ad];
}

- (void)bannerCustomEvent:(MPBannerCustomEvent *)event didFailToLoadAdWithError:(NSError *)error
{
    [self.delegate adapter:self didFailToLoadAdWithError:error];
}

- (void)bannerCustomEventWillBeginAction:(MPBannerCustomEvent *)event
{
    [self trackClick];
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
