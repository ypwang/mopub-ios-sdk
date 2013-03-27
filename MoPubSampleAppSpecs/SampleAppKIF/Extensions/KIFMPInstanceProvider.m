//
//  KIFMPInstanceProvider.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFMPInstanceProvider.h"
#import "GSFullscreenAd.h"
#import "GSAdDelegate.h"
#import "IMAdInterstitial.h"
#import "IMAdInterstitialDelegate.h"

static KIFMPInstanceProvider *sharedProvider = nil;

@implementation MPInstanceProvider (KIF)

+ (MPInstanceProvider *)sharedProvider
{
    if (!sharedProvider) {
        sharedProvider = [[KIFMPInstanceProvider alloc] init];
    }
    return sharedProvider;
}

@end

@implementation KIFMPInstanceProvider

- (GSFullscreenAd *)buildGSFullscreenAdWithDelegate:(id<GSAdDelegate>)delegate GUID:(NSString *)GUID
{
    return [[GSFullscreenAd alloc] initWithDelegate:delegate GUID:@"5f750a48-7e73-42e7-bede-839fda15f367"];
}

- (IMAdInterstitial *)buildIMAdInterstitialWithDelegate:(id<IMAdInterstitialDelegate>)delegate appId:(NSString *)appId;
{
    IMAdInterstitial *inMobiInterstitial = [[IMAdInterstitial alloc] init];
    inMobiInterstitial.delegate = delegate;
    inMobiInterstitial.imAppId = @"5d6694314fbe4ddb804eab8eb4ad6693";
    return inMobiInterstitial;
}

@end
