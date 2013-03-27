//
//  FakeMPAdWebView.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeMPAdWebView.h"
#import "UIWebView+Spec.h"
#import "MPHTMLInterstitialViewController.h"

@implementation FakeMPAdWebView

- (BOOL)didAppear
{
    return [[self executedJavaScripts] indexOfObject:@"webviewDidAppear();"] != NSNotFound;
}

- (void)simulateLoadingAd
{
    [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"mopub://finishLoad"]]];
}

- (void)simulateFailingToLoad
{
    [self loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"mopub://failLoad"]]];
}

- (void)simulateUserDismissingAd
{
    [self.interstitialController.closeButton tap];
}

- (UIViewController *)presentingViewController
{
    return self.interstitialController.presentingViewController;
}

- (MPHTMLInterstitialViewController *)interstitialController
{
    //Ugly hack...
    return [self.delegate performSelector:@selector(delegate)];
}

@end
