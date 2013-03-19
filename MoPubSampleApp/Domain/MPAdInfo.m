//
//  MPAdInfo.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPAdInfo.h"

@implementation MPAdInfo

+ (NSArray *)bannerAds
{
    return @[
             [MPAdInfo infoWithTitle:@"Valid StoreKit Link" ID:@"b086a37c8fe911e295fa123138070049" type:MPAdInfoBanner],
             [MPAdInfo infoWithTitle:@"Invalid StoreKit Link" ID:@"4ebfdd8a90ba11e295fa123138070049" type:MPAdInfoBanner]
             ];
}

+ (NSArray *)interstitialAds
{
    return @[
             [MPAdInfo infoWithTitle:@"Valid StoreKit Link" ID:@"c3a8fa2690c611e295fa123138070049" type:MPAdInfoInterstitial]
             ];
}

+ (MPAdInfo *)infoWithTitle:(NSString *)title ID:(NSString *)ID type:(MPAdInfoType)type
{
    MPAdInfo *info = [[MPAdInfo alloc] init];
    info.title = title;
    info.ID = ID;
    info.type = type;
    return info;
}

@end
