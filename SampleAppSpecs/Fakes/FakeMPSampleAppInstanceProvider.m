//
//  FakeMPSampleAppInstanceProvider.m
//  MoPubSampleApp
//
//  Created by pivotal on 3/18/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeMPSampleAppInstanceProvider.h"
#import "FakeMPAdView.h"

@implementation FakeMPSampleAppInstanceProvider

- (MPAdView *)buildMPAdViewWithAdUnitID:(NSString *)ID size:(CGSize)size
{
    self.lastFakeAdView = [[FakeMPAdView alloc] initWithAdUnitId:ID size:size];
    return self.lastFakeAdView;
}

@end
