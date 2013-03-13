//
//  MPAdWebViewDelegate.h
//  MoPubSDK
//
//  Created by pivotal on 3/13/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MPAdWebView;

@protocol MPAdWebViewDelegate <NSObject>

@required
- (UIViewController *)viewControllerForPresentingModalView;
- (void)adDidClose:(MPAdWebView *)ad;
- (void)adDidFinishLoadingAd:(MPAdWebView *)ad;
- (void)adDidFailToLoadAd:(MPAdWebView *)ad;
- (void)adActionWillBegin:(MPAdWebView *)ad;
- (void)adActionWillLeaveApplication:(MPAdWebView *)ad;
- (void)adActionDidFinish:(MPAdWebView *)ad;

@end

