//
//  MPLegacyBannerCustomEventAdapter.m
//  MoPubSDK
//
//  Created by pivotal on 4/4/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPLegacyBannerCustomEventAdapter.h"

@implementation MPLegacyBannerCustomEventAdapter

- (void)getAdWithConfiguration:(MPAdConfiguration *)configuration
{
    MPLogInfo(@"Looking for custom event selector named %@.", configuration.customSelectorName);
    
    SEL customEventSelector = NSSelectorFromString(configuration.customSelectorName);
    if ([self.delegate.adViewDelegate respondsToSelector:customEventSelector]) {
        [self.delegate.adViewDelegate performSelector:customEventSelector];
        return;
    }
    
    NSString *oneArgumentSelectorName = [configuration.customSelectorName
                                         stringByAppendingString:@":"];
    
    MPLogInfo(@"Looking for custom event selector named %@.", oneArgumentSelectorName);
    
    SEL customEventOneArgumentSelector = NSSelectorFromString(oneArgumentSelectorName);
    if ([self.delegate.adViewDelegate respondsToSelector:customEventOneArgumentSelector]) {
        [self.delegate.adViewDelegate performSelector:customEventOneArgumentSelector
                                           withObject:self.delegate.adView];
        return;
    }
    
    [self.delegate adapter:self didFailToLoadAdWithError:nil];
}

@end
