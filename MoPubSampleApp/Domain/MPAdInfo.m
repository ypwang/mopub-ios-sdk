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
             [MPAdInfo infoWithTitle:@"Valid StoreKit Link" ID:@"c3a8fa2690c611e295fa123138070049" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"iAd Interstitial (iPad-only)" ID:@"7e7e9e50932411e281c11231392559e4" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"Millennial Phone Interstitial" ID:@"de4205fc932411e295fa123138070049" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"Google AdMob Interstitial" ID:@"16ae389a932d11e281c11231392559e4" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"Chartboost Interstitial" ID:@"a425ff78959911e295fa123138070049" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"Greystripe Interstitial" ID:@"b80aef0c95a911e295fa123138070049" type:MPAdInfoInterstitial],
             [MPAdInfo infoWithTitle:@"InMobi Interstitial" ID:@"f0cbed0095a911e295fa123138070049" type:MPAdInfoInterstitial]
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
