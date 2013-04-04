//
//  FakeBannerCustomEvent.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPBannerCustomEvent.h"

@interface FakeBannerCustomEvent : MPBannerCustomEvent

@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) NSDictionary *customEventInfo;

@end
