//
//  FakeInterstitialCustomEvent.m
//  MoPubSDK
//
//  Created by pivotal on 3/19/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "FakeInterstitialCustomEvent.h"

static FakeInterstitialCustomEvent *lastInterstitialCustomEvent;

@implementation FakeInterstitialCustomEvent

+ (void)beforeEach
{
    lastInterstitialCustomEvent = nil;
}

+ (FakeInterstitialCustomEvent *)lastInterstitialCustomEvent
{
    return lastInterstitialCustomEvent;
}

- (id)init
{
    self = [super init];
    if (self) {
        lastInterstitialCustomEvent = self;
    }
    return self;
}

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info
{
    self.customEventInfo = info;
}

- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController
{
    self.rootViewController = rootViewController;
}

@end
