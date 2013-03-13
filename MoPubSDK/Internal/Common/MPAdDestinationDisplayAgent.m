//
//  MPAdDestinationDisplayAgent.m
//  MoPubSDK
//
//  Created by pivotal on 3/12/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPAdDestinationDisplayAgent.h"
#import "MPGlobal.h"
#import "UIViewController+MPAdditions.h"

@interface MPAdDestinationDisplayAgent ()

@property (nonatomic, assign) MPAdWebView *adWebView;
@property (nonatomic, assign) id<MPAdWebViewDelegate> delegate;
@property (nonatomic, retain) MPURLResolver *resolver;
@property (nonatomic, assign) BOOL used;
@property (nonatomic, assign) BOOL cancelled;

- (void)presentStoreKitControllerWithItemIdentifier:(NSString *)identifier fallbackURL:(NSURL *)URL;

@end

@implementation MPAdDestinationDisplayAgent

@synthesize adWebView = _adWebView;
@synthesize delegate = _delegate;
@synthesize resolver = _resolver;

+ (MPAdDestinationDisplayAgent *)agentWithAdWebView:(MPAdWebView *)adWebView
                                        URLResolver:(MPURLResolver *)resolver
                                           delegate:(id<MPAdWebViewDelegate>)delegate
{
    MPAdDestinationDisplayAgent *agent = [[MPAdDestinationDisplayAgent alloc] init];
    agent.adWebView = adWebView;
    agent.resolver = resolver;
    agent.delegate = delegate;
    return agent;
}

- (void)dealloc
{
    self.resolver = nil;
    [super dealloc];
}

- (void)displayDestinationForURL:(NSURL *)URL
{
    if (self.used) return;
    self.used = YES;

    [MPProgressOverlayView presentOverlayInWindow:MPKeyWindow()
                                         animated:MP_ANIMATED
                                         delegate:self];
    [self.delegate adActionWillBegin:self.adWebView];

    [self.resolver startResolvingWithURL:URL delegate:self];
}

#pragma mark - <MPURLResolverDelegate>

- (void)showWebViewWithHTMLString:(NSString *)HTMLString baseURL:(NSURL *)URL
{
    [MPProgressOverlayView dismissOverlayFromWindow:MPKeyWindow()
                                           animated:MP_ANIMATED];

    MPAdBrowserController *browser = [[[MPAdBrowserController alloc] initWithURL:URL
                                                                      HTMLString:HTMLString
                                                                        delegate:self] autorelease];
    [[self.delegate viewControllerForPresentingModalView] mp_presentModalViewController:browser
                                                                               animated:MP_ANIMATED];
}

- (void)showStoreKitProductWithParameter:(NSString *)parameter fallbackURL:(NSURL *)URL
{
    if ([MPStoreKitProvider deviceHasStoreKit]) {
        [self presentStoreKitControllerWithItemIdentifier:parameter fallbackURL:URL];
    } else {
        [self openURLInApplication:URL];
    }
}

- (void)openURLInApplication:(NSURL *)URL
{
    [MPProgressOverlayView dismissOverlayFromWindow:MPKeyWindow()
                                           animated:MP_ANIMATED];

    [self.delegate adActionWillLeaveApplication:self.adWebView];

    [[UIApplication sharedApplication] openURL:URL];
}

- (void)failedToResolveURLWithError:(NSError *)error
{
    [MPProgressOverlayView dismissOverlayFromWindow:MPKeyWindow()
                                           animated:MP_ANIMATED];

    [self.delegate adActionDidFinish:self.adWebView];
}

- (void)presentStoreKitControllerWithItemIdentifier:(NSString *)identifier fallbackURL:(NSURL *)URL
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= MP_IOS_6_0
    SKStoreProductViewController *controller = [MPStoreKitProvider buildController];
    controller.delegate = self;

    NSDictionary *parameters = [NSDictionary dictionaryWithObject:identifier
                                                           forKey:SKStoreProductParameterITunesItemIdentifier];
    [controller loadProductWithParameters:parameters completionBlock:^(BOOL success, NSError *error) {
        if (self.cancelled) return;

        if (success) {
            [MPProgressOverlayView dismissOverlayFromWindow:MPKeyWindow()
                                                   animated:MP_ANIMATED];
            [[self.delegate viewControllerForPresentingModalView] mp_presentModalViewController:controller
                                                                                       animated:MP_ANIMATED];
        } else {
            [self openURLInApplication:URL];
        }
    }];
#endif
}

#pragma mark - <MPSKStoreProductViewControllerDelegate>

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController
{
    [[self.delegate viewControllerForPresentingModalView] mp_dismissModalViewControllerAnimated:MP_ANIMATED];
    [self.delegate adActionDidFinish:self.adWebView];
}

#pragma mark - <MPAdBrowserControllerDelegate>

- (void)dismissBrowserController:(MPAdBrowserController *)browserController animated:(BOOL)animated
{
    [[self.delegate viewControllerForPresentingModalView] mp_dismissModalViewControllerAnimated:animated];
    [self.delegate adActionDidFinish:self.adWebView];
}

#pragma mark - <MPProgressOverlayViewDelegate>

- (void)overlayCancelButtonPressed
{
    self.cancelled = YES;
    [self.resolver cancel];
    [self.delegate adActionDidFinish:self.adWebView];
}

@end
