//
//  MPKIFTestController.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "MPKIFTestController.h"
#import "KIFTestScenario+StoreKitScenario.h"
#import "KIFTestScenario+Millennial.h"
#import "KIFTestScenario+GAD.h"
#import "KIFTestScenario+Chartboost.h"
#import "KIFTestScenario+Greystripe.h"
#import "KIFTestScenario+InMobi.h"

@implementation MPKIFTestController

- (BOOL)flakyTestMode
{
    return getenv("KIF_FLAKY_TESTS") ? YES : NO;
}

- (void)initializeScenarios
{
    [self addStoreKitScenarios];
    [self addiAdScenarios];
    [self addMillennialScenarios];
    [self addAdMobScenarios];
    [self addGreystripeScenarios];
    [self addChartboostScenarios];
    [self addInMobiScenarios];
}

- (void)addStoreKitScenarios
{
    [self addScenario:[KIFTestScenario scenarioForBannerAdWithStoreKitLink]];
    [self addScenario:[KIFTestScenario scenarioForBannerAdWithInvalidStoreKitLink]];
    [self addScenario:[KIFTestScenario scenarioForInterstitialAdWithStoreKitLink]];
}

- (void)addiAdScenarios
{
    //nothing to see here iAd is too slow/purposefully flakey to be testable
}

- (void)addMillennialScenarios
{
    [self addScenario:[KIFTestScenario scenarioForMillennialInterstitial]];
}

- (void)addAdMobScenarios
{
    [self addScenario:[KIFTestScenario scenarioForGADInterstitial]];
}

- (void)addChartboostScenarios
{
    [self addScenario:[KIFTestScenario scenarioForChartboostInterstitial]];
    [self addScenario:[KIFTestScenario scenarioForMultipleChartboostInterstitials]];
}

- (void)addGreystripeScenarios
{
    if (self.flakyTestMode) {
        [self addScenario:[KIFTestScenario scenarioForGreystripeInterstitial]];
    }
}

- (void)addInMobiScenarios
{
    if (self.flakyTestMode) {
        [self addScenario:[KIFTestScenario scenarioForInMobiInterstitial]];
    }
}

@end
