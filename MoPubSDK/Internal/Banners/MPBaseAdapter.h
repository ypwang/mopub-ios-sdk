//
//  MPBaseAdapter.h
//  MoPub
//
//  Created by Nafis Jamal on 1/19/11.
//  Copyright 2011 MoPub, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "MPAdView.h"

@protocol MPAdapterDelegate;
@class MPAdConfiguration;

@interface MPBaseAdapter : NSObject
{
    id<MPAdapterDelegate> _delegate;
}

@property (nonatomic, assign) id<MPAdapterDelegate> delegate;
@property (nonatomic, copy) NSURL *impressionTrackingURL;
@property (nonatomic, copy) NSURL *clickTrackingURL;

- (id)initWithAdapterDelegate:(id<MPAdapterDelegate>)delegate;

/*
 * Sets the adapter's delegate to nil.
 */
- (void)unregisterDelegate;

/*
 * -_getAdWithConfiguration wraps -getAdWithConfiguration in retain/release calls to prevent the
 * adapter from being prematurely deallocated.
 */
- (void)getAdWithConfiguration:(MPAdConfiguration *)configuration containerSize:(CGSize)size;
- (void)_getAdWithConfiguration:(MPAdConfiguration *)configuration containerSize:(CGSize)size;

- (void)didStopLoading;
- (void)didDisplayAd;

/*
 * Your subclass should implement this method if your native ads vary depending on orientation.
 */
- (void)rotateToOrientation:(UIInterfaceOrientation)newOrientation;

- (void)trackImpression;

- (void)trackClick;

@end

////////////////////////////////////////////////////////////////////////////////////////////////////

@protocol MPAdapterDelegate

@required

- (MPAdView *)banner;
- (id<MPAdViewDelegate>)bannerDelegate;
- (UIViewController *)viewControllerForPresentingModalView;
- (MPNativeAdOrientation)allowedNativeAdsOrientation;
- (CLLocation *)location;

/*
 * These callbacks notify you that the adapter (un)successfully loaded an ad.
 */
- (void)adapter:(MPBaseAdapter *)adapter didFailToLoadAdWithError:(NSError *)error;
- (void)adapter:(MPBaseAdapter *)adapter didFinishLoadingAd:(UIView *)ad;

/*
 * These callbacks notify you that the user interacted (or stopped interacting) with the native ad.
 */
- (void)userActionWillBeginForAdapter:(MPBaseAdapter *)adapter;
- (void)userActionDidFinishForAdapter:(MPBaseAdapter *)adapter;

/*
 * This callback notifies you that user has tapped on an ad which will cause them to leave the
 * current application (e.g. the ad action opens the iTunes store, Mobile Safari, etc).
 */
- (void)userWillLeaveApplicationFromAdapter:(MPBaseAdapter *)adapter;

@end
