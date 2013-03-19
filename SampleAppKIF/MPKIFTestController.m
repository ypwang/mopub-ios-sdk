//
//  MPKIFTestController.m
//  MoPubSampleApp
//
//  Created by pivotal on 3/18/13.
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPKIFTestController.h"
#import "KIFTestScenario+StoreKitScenario.h"

@implementation MPKIFTestController

- (void)initializeScenarios
{
    [self addScenario:[KIFTestScenario scenarioForBannerAdWithStoreKitLink]];
}

@end
