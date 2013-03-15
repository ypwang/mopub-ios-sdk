//
//  MPAdWebViewAgent.h
//  MoPubSDK
//
//  Created by pivotal on 3/15/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MPAdDestinationDisplayAgent.h"

enum {
    MPAdWebViewEventAdDidAppear     = 0,
    MPAdWebViewEventAdDidDisappear  = 1
};
typedef NSUInteger MPAdWebViewEvent;

@protocol MPAdWebViewAgentDelegate;

@class MPAdConfiguration;
@class MPAdWebView;

@interface MPAdWebViewAgent : NSObject <UIWebViewDelegate, MPAdDestinationDisplayAgentDelegate>

@property (nonatomic, assign) id customMethodDelegate;
@property (nonatomic, assign, getter=isDismissed) BOOL dismissed;
@property (nonatomic, retain) MPAdWebView *view;

- (id)initWithAdWebView:(MPAdWebView *)view
               delegate:(id<MPAdWebViewAgentDelegate>)delegate
destinationDisplayAgent:(MPAdDestinationDisplayAgent *)agent;
- (void)loadConfiguration:(MPAdConfiguration *)configuration;
- (void)rotateToOrientation:(UIInterfaceOrientation)orientation;
- (void)invokeJavaScriptForEvent:(MPAdWebViewEvent)event;
- (void)forceRedraw;

@end

@class MPAdWebView;

@protocol MPAdWebViewAgentDelegate <NSObject>

@required
- (UIViewController *)viewControllerForPresentingModalView;
- (void)adDidClose:(MPAdWebView *)ad;
- (void)adDidFinishLoadingAd:(MPAdWebView *)ad;
- (void)adDidFailToLoadAd:(MPAdWebView *)ad;
- (void)adActionWillBegin:(MPAdWebView *)ad;
- (void)adActionWillLeaveApplication:(MPAdWebView *)ad;
- (void)adActionDidFinish:(MPAdWebView *)ad;

@end
