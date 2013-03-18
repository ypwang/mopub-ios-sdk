//
//  MPSampleAppInstanceProvider.m
//  MoPubSampleApp
//
//  Created by pivotal on 3/18/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPSampleAppInstanceProvider.h"
#import "MPAdView.h"

static MPSampleAppInstanceProvider *sharedProvider = nil;

@implementation MPSampleAppInstanceProvider

+ (MPSampleAppInstanceProvider *)sharedProvider
{
    if (!sharedProvider) {
        sharedProvider = [[MPSampleAppInstanceProvider alloc] init];
    }
    return sharedProvider;
}

- (MPAdView *)buildMPAdViewWithAdUnitID:(NSString *)ID size:(CGSize)size
{
    return [[MPAdView alloc] initWithAdUnitId:ID size:size];
}

@end
