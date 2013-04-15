//
//  MPMillennialBannerCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPMillennialBannerCustomEvent.h"
#import "MPAdView.h"
#import "MPLogging.h"
#import "MPAdConfiguration.h"
#import "MPInstanceProvider.h"

#define MM_SIZE_320x53    CGSizeMake(320, 53)
#define MM_SIZE_300x250 CGSizeMake(300, 250)
#define MM_SIZE_728x90  CGSizeMake(728, 90)

@interface MPInstanceProvider (MillennialBanners)

- (MMAdView *)buildMMAdViewWithFrame:(CGRect)frame type:(MMAdType)type apid:(NSString *)apid delegate:(id<MMAdDelegate>)delegate;

@end

@implementation MPInstanceProvider (MillennialBanners)

- (MMAdView *)buildMMAdViewWithFrame:(CGRect)frame type:(MMAdType)type apid:(NSString *)apid delegate:(id<MMAdDelegate>)delegate
{
    return [MMAdView adWithFrame:frame
                            type:type
                            apid:apid
                        delegate:delegate
                          loadAd:NO
                      startTimer:NO];
}

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPMillennialBannerCustomEvent ()

@property (nonatomic, retain) MMAdView *mmAdView;

- (CGSize)sizeFromCustomEventInfo:(NSDictionary *)info;
- (CGRect)frameFromCustomEventInfo:(NSDictionary *)info;
- (MMAdType)typeFromCustomEventInfo:(NSDictionary *)info;

@end

@implementation MPMillennialBannerCustomEvent

- (void)dealloc
{
    self.mmAdView.delegate = nil;
    self.mmAdView = nil;
    [super dealloc];
}

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    CGRect frame = [self frameFromCustomEventInfo:info];
    MMAdType type = [self typeFromCustomEventInfo:info];
    NSString *apid = [info objectForKey:@"adUnitID"];
    self.mmAdView = [[MPInstanceProvider sharedProvider] buildMMAdViewWithFrame:frame
                                                                           type:type
                                                                           apid:apid
                                                                       delegate:self];

    self.mmAdView.rootViewController = [self.delegate viewControllerForPresentingModalView];
    [self.mmAdView refreshAd];
}

- (CGSize)sizeFromCustomEventInfo:(NSDictionary *)info
{
    CGFloat width = [[info objectForKey:@"adWidth"] floatValue];
    CGFloat height = [[info objectForKey:@"adHeight"] floatValue];
    return CGSizeMake(width, height);
}

- (CGRect)frameFromCustomEventInfo:(NSDictionary *)info
{
    CGSize size = [self sizeFromCustomEventInfo:info];
    if (!CGSizeEqualToSize(size, MM_SIZE_300x250) && !CGSizeEqualToSize(size, MM_SIZE_728x90)) {
        size.width = MM_SIZE_320x53.width;
        size.height = MM_SIZE_320x53.height;
    }
    return CGRectMake(0, 0, size.width, size.height);
}

- (MMAdType)typeFromCustomEventInfo:(NSDictionary *)info
{
    CGSize size = [self sizeFromCustomEventInfo:info];
    return CGSizeEqualToSize(size, MM_SIZE_300x250) ? MMBannerAdRectangle : MMBannerAdTop;
}

#pragma mark -
#pragma mark MMAdViewDelegate

- (NSDictionary *)requestData
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"mopubsdk", @"vendor", nil];

    CLLocation *location = self.delegate.location;
    if (location) {
        [params setObject:[[NSNumber numberWithDouble:location.coordinate.latitude] stringValue] forKey:@"lat"];
        [params setObject:[[NSNumber numberWithDouble:location.coordinate.longitude] stringValue] forKey:@"long"];
    }

    return params;
}

- (void)adRequestSucceeded:(MMAdView *)adView
{
    [self.delegate bannerCustomEvent:self didLoadAd:self.mmAdView];
}

- (void)adRequestFailed:(MMAdView *)adView
{
    [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:nil];
}

- (void)adWasTapped:(MMAdView *)adView
{
    [self.delegate bannerCustomEventWillBeginAction:self];
}

- (void)adModalWasDismissed
{
    [self.delegate bannerCustomEventDidFinishAction:self];
}

- (void)applicationWillTerminateFromAd
{
    [self.delegate bannerCustomEventWillLeaveApplication:self];
}

@end
