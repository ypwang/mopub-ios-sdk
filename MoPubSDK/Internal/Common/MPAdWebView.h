//
//  MPAdWebView.h
//  MoPub
//
//  Copyright (c) 2012 MoPub, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "MPAdBrowserController.h"
#import "MPProgressOverlayView.h"
#import "MPAdWebViewDelegate.h"
#import "UIWebView+MPAdditions.h"

enum {
    MPAdWebViewEventAdDidAppear     = 0,
    MPAdWebViewEventAdDidDisappear  = 1
};
typedef NSUInteger MPAdWebViewEvent;

@class MPAdConfiguration;
@class MPAdDestinationDisplayAgent;

////////////////////////////////////////////////////////////////////////////////////////////////////

@interface MPAdWebView : UIView <UIWebViewDelegate>
{
    UIWebView *_webView;
    id<MPAdWebViewDelegate> _delegate;
    id _customMethodDelegate;

    MPAdConfiguration *_configuration;

    // Only used when the MPAdWebView is the backing view for an interstitial ad.
    BOOL _dismissed;
}

@property (nonatomic, readonly, retain) UIWebView *webView;
@property (nonatomic, assign) id<MPAdWebViewDelegate> delegate;
@property (nonatomic, assign) id customMethodDelegate;
@property (nonatomic, readonly, retain) MPAdBrowserController *browserController;
@property (nonatomic, assign, getter=isDismissed) BOOL dismissed;

- (id)initWithFrame:(CGRect)frame delegate:(id<MPAdWebViewDelegate>)delegate destinationDisplayAgent:(MPAdDestinationDisplayAgent *)agent;
- (void)loadConfiguration:(MPAdConfiguration *)configuration;
- (void)loadData:(NSData *)data MIMEType:(NSString *)MIMEType
textEncodingName:(NSString *)textEncodingName baseURL:(NSURL *)baseURL;
- (void)rotateToOrientation:(UIInterfaceOrientation)orientation;
- (void)invokeJavaScriptForEvent:(MPAdWebViewEvent)event;
- (void)forceRedraw;

@end
