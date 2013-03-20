//
//  FakeMPAdWebView.h
//  MoPubSDK
//
//  Created by pivotal on 3/26/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPAdWebView.h"

@interface FakeMPAdWebView : MPAdWebView <FakeInterstitialAd>

- (BOOL)didAppear;

- (void)simulateLoadingAd;
- (void)simulateFailingToLoad;
- (void)simulateUserDismissingAd;

- (UIViewController *)presentingViewController;

@end
