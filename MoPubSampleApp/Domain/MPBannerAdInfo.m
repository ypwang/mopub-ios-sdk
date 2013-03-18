//
//  MPBannerAdInfo.m
//  MoPubSampleApp
//
//  Created by pivotal on 3/18/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPBannerAdInfo.h"

@implementation MPBannerAdInfo

+ (NSArray *)bannerAds
{
    return @[
             [MPBannerAdInfo infoWithTitle:@"Valid StoreKit Link" ID:@"b086a37c8fe911e295fa123138070049"]
             ];
}

+ (MPBannerAdInfo *)infoWithTitle:(NSString *)title ID:(NSString *)ID
{
    MPBannerAdInfo *info = [[MPBannerAdInfo alloc] init];
    info.title = title;
    info.ID = ID;
    return info;
}

@end
