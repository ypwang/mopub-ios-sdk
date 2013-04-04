//
//  FakeBannerCustomEvent.h
//  MoPubSDK
//
//  Created by pivotal on 4/4/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPBannerCustomEvent.h"

@interface FakeBannerCustomEvent : MPBannerCustomEvent

@property (nonatomic, assign) CGSize size;
@property (nonatomic, assign) NSDictionary *customEventInfo;

@end
