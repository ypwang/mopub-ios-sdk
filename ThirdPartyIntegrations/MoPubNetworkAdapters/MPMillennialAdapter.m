//
//  MPMillennialAdapter.m
//  MoPub
//
//  Created by Andrew He on 5/1/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import "MPMillennialAdapter.h"
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

@interface MPMillennialAdapter ()

@property (nonatomic, retain) MMAdView *mmAdView;

- (CGSize)sizeFromConfiguration:(MPAdConfiguration *)configuration;
- (CGRect)frameFromConfiguration:(MPAdConfiguration *)configuration;
- (MMAdType)typeFromConfiguration:(MPAdConfiguration *)configuration;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@implementation MPMillennialAdapter
@synthesize mmAdView = _mmAdView;

- (void)dealloc
{
    self.mmAdView.delegate = nil;
    self.mmAdView = nil;
    [super dealloc];
}

- (void)getAdWithConfiguration:(MPAdConfiguration *)configuration containerSize:(CGSize)size
{
    CGRect frame = [self frameFromConfiguration:configuration];
    MMAdType type = [self typeFromConfiguration:configuration];
    NSString *apid = [configuration.nativeSDKParameters objectForKey:@"adUnitID"];
    self.mmAdView = [[MPInstanceProvider sharedProvider] buildMMAdViewWithFrame:frame
                                                                           type:type
                                                                           apid:apid
                                                                       delegate:self];

    self.mmAdView.rootViewController = [self.delegate viewControllerForPresentingModalView];
    [self.mmAdView refreshAd];
}

- (CGSize)sizeFromConfiguration:(MPAdConfiguration *)configuration
{
    CGFloat width = [[configuration.nativeSDKParameters objectForKey:@"adWidth"] floatValue];
    CGFloat height = [[configuration.nativeSDKParameters objectForKey:@"adHeight"] floatValue];
    return CGSizeMake(width, height);
}

- (CGRect)frameFromConfiguration:(MPAdConfiguration *)configuration
{
    CGSize size = [self sizeFromConfiguration:configuration];
    if (!CGSizeEqualToSize(size, MM_SIZE_300x250) && !CGSizeEqualToSize(size, MM_SIZE_728x90)) {
        size.width = MM_SIZE_320x53.width;
        size.height = MM_SIZE_320x53.height;
    }
    return CGRectMake(0, 0, size.width, size.height);
}

- (MMAdType)typeFromConfiguration:(MPAdConfiguration *)configuration
{
    CGSize size = [self sizeFromConfiguration:configuration];
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
    [self.delegate adapter:self didFinishLoadingAd:adView];
}

- (void)adRequestFailed:(MMAdView *)adView
{
    [self.delegate adapter:self didFailToLoadAdWithError:nil];
}

- (void)adWasTapped:(MMAdView *)adView
{
    [self.delegate userActionWillBeginForAdapter:self];
}

- (void)applicationWillTerminateFromAd
{
    [self.delegate userWillLeaveApplicationFromAdapter:self];
}

- (void)adModalWasDismissed
{
    [self.delegate userActionDidFinishForAdapter:self];
}

@end
