//
//  FakeMPSampleAppInstanceProvider.h
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPSampleAppInstanceProvider.h"

@class FakeMPAdView;

@interface FakeMPSampleAppInstanceProvider : MPSampleAppInstanceProvider

@property (nonatomic, assign) FakeMPAdView *lastFakeAdView;

@end
