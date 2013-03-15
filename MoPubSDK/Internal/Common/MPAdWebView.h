//
//  MPAdWebView.h
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "UIWebView+MPAdditions.h"

enum {
    MPAdWebViewEventAdDidAppear     = 0,
    MPAdWebViewEventAdDidDisappear  = 1
};
typedef NSUInteger MPAdWebViewEvent;

@class MPAdConfiguration;
@class MPAdDestinationDisplayAgent;

@protocol MPAdWebViewDelegate;

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPAdWebView : UIView <UIWebViewDelegate>

@property (nonatomic, readonly, retain) UIWebView *webView;
@property (nonatomic, assign) id<MPAdWebViewDelegate> delegate;
@property (nonatomic, assign) id customMethodDelegate;
@property (nonatomic, assign, getter=isDismissed) BOOL dismissed;

- (id)initWithFrame:(CGRect)frame delegate:(id<MPAdWebViewDelegate>)delegate destinationDisplayAgent:(MPAdDestinationDisplayAgent *)agent;
- (void)loadConfiguration:(MPAdConfiguration *)configuration;
- (void)rotateToOrientation:(UIInterfaceOrientation)orientation;
- (void)invokeJavaScriptForEvent:(MPAdWebViewEvent)event;
- (void)forceRedraw;

@end
