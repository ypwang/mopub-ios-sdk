//
//  FakeMMBannerAdView.m
//  MoPubSDK
//
//  Created by pivotal on 4/3/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeMMBannerAdView.h"

@implementation FakeMMBannerAdView

- (MMAdView *)masquerade
{
    return (MMAdView *)self;
}

- (void)refreshAd
{
    self.hasRefreshed = YES;
}

@end
