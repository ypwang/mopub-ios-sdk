//
//  MPAdConfigurationFactory.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPAdConfigurationFactory.h"

@implementation MPAdConfigurationFactory

+ (NSMutableDictionary *)defaultBannerHeaders
{
    return [@{
            kAdTypeHeaderKey: kAdTypeHtml,
            kClickthroughHeaderKey: @"http://ads.mopub.com/m/clickThroughTracker?a=1",
            kFailUrlHeaderKey: @"http://ads.mopub.com/m/failURL",
            kHeightHeaderKey: @"50",
            kImpressionTrackerHeaderKey: @"http://ads.mopub.com/m/impressionTracker",
            kInterceptLinksHeaderKey: @"1",
            kLaunchpageHeaderKey: @"http://publisher.com",
            kRefreshTimeHeaderKey: @"30",
            kWidthHeaderKey: @"320"
            } mutableCopy];
}

+ (NSMutableDictionary *)defaultInterstitialHeaders
{
    return [@{
            kAdTypeHeaderKey: kAdTypeInterstitial,
            kClickthroughHeaderKey: @"http://ads.mopub.com/m/clickThroughTracker?a=1",
            kFailUrlHeaderKey: @"http://ads.mopub.com/m/failURL",
            kImpressionTrackerHeaderKey: @"http://ads.mopub.com/m/impressionTracker",
            kInterceptLinksHeaderKey: @"1",
            kLaunchpageHeaderKey: @"http://publisher.com",
            kInterstitialAdTypeHeaderKey: kAdTypeHtml,
            kOrientationTypeHeaderKey: @"p"
            } mutableCopy];
}

+ (MPAdConfiguration *)defaultBannerConfiguration
{
    return [self defaultBannerConfigurationWithHeaders:nil HTMLString:nil];
}

+ (MPAdConfiguration *)defaultInterstitialConfiguration
{
    return [self defaultInterstitialConfigurationWithHeaders:nil HTMLString:nil];
}

+ (MPAdConfiguration *)defaultInterstitialConfigurationWithCustomEventClassName:(NSString *)eventClassName
{
    return [MPAdConfigurationFactory defaultInterstitialConfigurationWithHeaders:@{kCustomEventClassNameHeaderKey: eventClassName}
                                                                      HTMLString:nil];
}

+ (MPAdConfiguration *)defaultBannerConfigurationWithHeaders:(NSDictionary *)dictionary
                                                  HTMLString:(NSString *)HTMLString
{
    NSMutableDictionary *headers = [self defaultBannerHeaders];
    [headers addEntriesFromDictionary:dictionary];

    HTMLString = HTMLString ? HTMLString : @"Publisher's Ad";

    return [[[MPAdConfiguration alloc] initWithHeaders:headers
                                                  data:[HTMLString dataUsingEncoding:NSUTF8StringEncoding]] autorelease];
}

+ (MPAdConfiguration *)defaultInterstitialConfigurationWithHeaders:(NSDictionary *)dictionary
                                                        HTMLString:(NSString *)HTMLString
{
    NSMutableDictionary *headers = [self defaultInterstitialHeaders];
    [headers addEntriesFromDictionary:dictionary];

    HTMLString = HTMLString ? HTMLString : @"Publisher's Interstitial";

    return [[[MPAdConfiguration alloc] initWithHeaders:headers
                                                  data:[HTMLString dataUsingEncoding:NSUTF8StringEncoding]] autorelease];
}



@end
