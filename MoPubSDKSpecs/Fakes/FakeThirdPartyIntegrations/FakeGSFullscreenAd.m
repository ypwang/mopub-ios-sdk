//
//  FakeGSFullScreenAd.m
//  MoPubSDK
//
//  Created by pivotal on 3/25/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeGSFullscreenAd.h"

@implementation FakeGSFullscreenAd

- (id)init
{
    return [super initWithDelegate:nil GUID:@"THE_GUID_WILL_COME"];
}

- (void)fetch
{
    self.didFetch = YES;
}

- (BOOL)displayFromViewController:(UIViewController *)a_viewController
{
    self.presentingViewController = a_viewController;
    [self.delegate greystripeWillPresentModalViewController];
    return YES;
}

- (void)simulateLoadingAd
{
    [self.delegate greystripeAdFetchSucceeded:self];
}

- (void)simulateFailingToLoad
{
    [self.delegate greystripeAdFetchFailed:self withError:0];
}

- (void)simulateUserDismissingAd
{
    self.presentingViewController = nil;
    [self.delegate greystripeDidDismissModalViewController];
}

@end
