//
//  FakeGSFullScreenAd.h
//  MoPubSDK
//
//  Created by pivotal on 3/25/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "GSFullscreenAd.h"
#import "GSAdDelegate.h"

@interface FakeGSFullscreenAd : GSFullscreenAd <FakeInterstitialAd>

@property (nonatomic, assign) UIViewController *presentingViewController;
@property (nonatomic, assign) NSString *GUID;

@property (nonatomic, assign) BOOL didFetch;
@property (nonatomic, assign) BOOL isAdReady;

- (void)simulateLoadingAd;
- (void)simulateFailingToLoad;
- (void)simulateUserDismissingAd;

@end
