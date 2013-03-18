//
//  FakeMPSampleAppInstanceProvider.h
//  MoPubSampleApp
//
//  Created by pivotal on 3/18/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPSampleAppInstanceProvider.h"

@class FakeMPAdView;

@interface FakeMPSampleAppInstanceProvider : MPSampleAppInstanceProvider

@property (nonatomic, assign) FakeMPAdView *lastFakeAdView;

@end
