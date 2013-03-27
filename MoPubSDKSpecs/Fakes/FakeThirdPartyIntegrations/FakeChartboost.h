//
//  FakeChartboost.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "Chartboost.h"

@interface FakeChartboost : Chartboost <FakeInterstitialAd>

@property (nonatomic, assign) UIViewController *presentingViewController;

@property (nonatomic, assign) BOOL didStartSession;
@property (nonatomic, assign) BOOL didStartCaching;
@property (nonatomic, assign) BOOL hasCachedInterstitial;

- (void)simulateLoadingAd;
- (void)simulateFailingToLoad;
- (void)simulateUserDismissingAd;

@end
