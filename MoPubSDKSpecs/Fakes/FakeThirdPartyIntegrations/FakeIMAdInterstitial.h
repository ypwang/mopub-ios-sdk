//
//  FakeGSFullScreenAd.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "IMAdInterstitial.h"
#import "IMAdInterstitialDelegate.h"

@interface FakeIMAdInterstitial : IMAdInterstitial <FakeInterstitialAd>

@property (nonatomic, assign) IMAdRequest *request;
@property (nonatomic, assign) UIViewController *presentingViewController;
@property (nonatomic, assign) BOOL willPresentSuccessfully;

- (void)simulateLoadingAd;
- (void)simulateFailingToLoad;
- (void)simulateUserDismissingAd;

@end
