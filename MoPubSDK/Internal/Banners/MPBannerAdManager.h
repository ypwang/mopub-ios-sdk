//
//  MPBannerAdManager.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPAdServerCommunicator.h"
#import "MPBaseAdapter.h"

@protocol MPBannerAdManagerDelegate;

@interface MPBannerAdManager : NSObject <MPAdServerCommunicatorDelegate, MPAdapterDelegate>

@property (nonatomic, assign) id<MPBannerAdManagerDelegate> delegate;

- (id)initWithDelegate:(id<MPBannerAdManagerDelegate>)delegate;

- (void)loadAd;
- (void)forceRefreshAd;
- (void)rotateToOrientation:(UIInterfaceOrientation)orientation;

// Deprecated.
- (void)customEventDidLoadAd;
- (void)customEventDidFailToLoadAd;
- (void)customEventActionWillBegin;
- (void)customEventActionDidEnd;

@end
