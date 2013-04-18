//
//  FakeMMInterstitialAdView.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InterstitialIntegrationSharedBehaviors.h"

@class MMAdView;
@protocol MMAdDelegate;

@interface FakeMMInterstitialAdView : NSObject <FakeInterstitialAd>

@property (nonatomic, assign) id<MMAdDelegate> delegate;
@property (nonatomic, assign) NSString *apid;
@property (nonatomic, assign) BOOL hasCachedAd;
@property (nonatomic, assign) BOOL willSuccessfullyDisplayAd;

@property (nonatomic, assign) BOOL askedToFetchAd;

@property (nonatomic, assign) UIViewController *rootViewController;
@property (nonatomic, assign) UIViewController *presentingViewController;

- (MMAdView *)masquerade;
- (void)simulateSuccessfullyCachingAd;
- (void)simulateFailingToCacheAd;
- (void)simulateDismissingAd;

@end
