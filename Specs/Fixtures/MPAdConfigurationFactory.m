//
//  MPAdConfigurationFactory.m
//  MoPubSDK
//
//  Created by pivotal on 3/14/13.
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

+ (MPAdConfiguration *)defaultBannerConfiguration
{
    return [self defaultBannerConfigurationWithHeaders:nil HTMLString:nil];
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

@end
