//
//  FakeBannerCustomEvent.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeBannerCustomEvent.h"

@implementation FakeBannerCustomEvent

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info
{
    self.size = size;
    self.customEventInfo = info;
}

@end
