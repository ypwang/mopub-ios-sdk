//
//  FakeGADBannerView.m
//  MoPubSDK
//
//  Created by pivotal on 4/2/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeGADBannerView.h"

@implementation FakeGADBannerView

- (GADBannerView *)masquerade
{
    return (GADBannerView *)self;
}

- (void)loadRequest:(GADRequest *)request
{
    self.loadedRequest = request;
}

@end
