//
//  MPAdView.h
//  MoPub
//
//  Created by Nafis Jamal on 1/19/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MPGlobal.h"
#import "MPConstants.h"
#import "MPLogging.h"

typedef enum
{
    MPNativeAdOrientationAny,
    MPNativeAdOrientationPortrait,
    MPNativeAdOrientationLandscape
} MPNativeAdOrientation;

@protocol MPAdViewDelegate;
@class MPBannerAdManager;

@interface MPAdView : UIView

@property (nonatomic, assign) id<MPAdViewDelegate> delegate;
@property (nonatomic, copy) NSString *adUnitId;
@property (nonatomic, copy) CLLocation *location;
@property (nonatomic, retain) NSString *keywords;
@property (nonatomic, assign) BOOL ignoresAutorefresh;
@property (nonatomic, assign, getter = isTesting) BOOL testing;

/*
 * Returns an MPAdView with the given ad unit ID.
 */
- (id)initWithAdUnitId:(NSString *)adUnitId size:(CGSize)size;

/*
 * Ad sizes may vary between different ad networks. This method returns the actual
 * size of the underlying ad, which you can use to adjust the size of the MPAdView
 * to avoid clipping or border issues.
 */
- (CGSize)adContentViewSize;

/*
 * Loads a new ad using a default URL constructed from the ad unit ID.
 */
- (void)loadAd;

/*
 * Tells the ad view to get another ad using its current URL. Note: if the ad view
 * is already loading an ad, this call does nothing; use -forceRefreshAd instead
 * if you want to cancel any existing ad requests.
 */
- (void)refreshAd;

/*
 * Tells the ad view to get another ad using its current URL, and cancels any existing
 * ad requests.
 */
- (void)forceRefreshAd;

/*
 * Replaces the content of the MPAdView with the specified view and retains the view.
 *
 * This method is crucial for implementing adapters or custom events involving other
 * ad networks.
 */
- (void)setAdContentView:(UIView *)view;

/*
 * Informs the ad view that the device orientation has changed. You should call
 * this method when your application's orientation changes if you want your
 * underlying ads to adjust their orientation properly. You may want to use
 * this method in conjunction with -adContentViewSize, in case the orientation
 * change modifies the size of the underlying ad.
 */
- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation;

/*
 * Forces native ad networks to only use ads sized for the specified orientation. For instance,
 * if you call this with UIInterfaceOrientationPortrait, native networks (e.g. iAd) will never
 * return ads sized for the landscape orientation.
 */
- (void)lockNativeAdsToOrientation:(MPNativeAdOrientation)orientation;

/*
 * Allows native ad networks to use ads sized for any orientation. See -lockNativeAdsToOrientation:.
 */
- (void)unlockNativeAdsOrientation;

- (MPNativeAdOrientation)allowedNativeAdsOrientation;

#pragma mark - Deprecated

/*
 * Signals to the ad view that a custom event has caused ad content to load
 * successfully. You must call this method if you implement custom events.
 */
- (void)customEventDidLoadAd;

/*
 * Signals to the ad view that a custom event has resulted in a failed load.
 * You must call this method if you implement custom events.
 */
- (void)customEventDidFailToLoadAd;

/*
 * Signals to the ad view that a user has tapped on a custom-event-triggered ad.
 * You must call this method if you implement custom events, for proper click tracking.
 */
- (void)customEventActionWillBegin;

/*
 * Signals to the ad view that a user has stopped interacting with a custom-event-triggered ad.
 * You must call this method if you implement custom events.
 */
- (void)customEventActionDidEnd;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

#pragma mark -

@protocol MPAdViewDelegate <NSObject>

@required
/*
 * The ad view relies on this method to determine which view controller will be
 * used for presenting/dismissing modal views, such as the browser view presented
 * when a user clicks on an ad.
 */
- (UIViewController *)viewControllerForPresentingModalView;

@optional
/*
 * These callbacks notify you regarding whether the ad view (un)successfully
 * loaded an ad.
 */
- (void)adViewDidFailToLoadAd:(MPAdView *)view;
- (void)adViewDidLoadAd:(MPAdView *)view;

/*
 * These callbacks are triggered when the ad view is about to present/dismiss a
 * modal view. If your application may be disrupted by these actions, you can
 * use these notifications to handle them (for example, a game might need to
 * pause/unpause).
 */
- (void)willPresentModalViewForAd:(MPAdView *)view;
- (void)didDismissModalViewForAd:(MPAdView *)view;

/*
 * This method is called when the user is about to leave your application as a result of tapping on
 * an ad.
 */
- (void)willLeaveApplicationFromAd:(MPAdView *)view;

@end
