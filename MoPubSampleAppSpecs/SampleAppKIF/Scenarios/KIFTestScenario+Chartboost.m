//
//  KIFTestScenario+Chartboost.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestScenario+Chartboost.h"

@implementation KIFTestScenario (Chartboost)

+ (KIFTestScenario *)scenarioForChartboostInterstitial
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that a Chartboost interstitial ad works."];
    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"Chartboost Interstitial" inSection:@"Interstitial Ads"];
    [scenario addStep:[KIFTestStep stepToTapRowInTableViewWithAccessibilityLabel:@"Ad Table View"
                                                                     atIndexPath:indexPath]];

    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Load"]];
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Show"]];
    [scenario addStep:[KIFTestStep stepToWaitForPresenceOfViewWithClassName:@"CBNativeInterstitialView"]];
    [scenario addStep:[KIFTestStep stepToLogImpressionForAdUnit:[MPAdSection adInfoAtIndexPath:indexPath].ID]];
    [scenario addStep:[KIFTestStep stepToTapScreenAtPoint:CGPointMake(285, 60)]];
    [scenario addStep:[KIFTestStep stepToWaitForAbsenseOfViewWithClassName:@"CBNativeInterstitialView"]];

    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];

    return scenario;
}

+ (KIFTestScenario *)scenarioForMultipleChartboostInterstitials
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that simultaneously loading multiple Chartboost interstitials works."];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Manual"]];
    [scenario addStep:[KIFTestStep stepToEnterText:@"a425ff78959911e295fa123138070049" intoViewWithAccessibilityLabel:@"Interstitial ID 1"]];
    [scenario addStep:[KIFTestStep stepToEnterText:@"201597ec97e811e295fa123138070049" intoViewWithAccessibilityLabel:@"Interstitial ID 2"]];
    [scenario addStep:[KIFTestStep stepToTapScreenAtPoint:CGPointMake(0,65)]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Interstitial Load 1"]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Interstitial Load 2"]];
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Interstitial Show 1"]];
    [scenario addStep:[KIFTestStep stepToWaitForPresenceOfViewWithClassName:@"CBNativeInterstitialView"]];
    [scenario addStep:[KIFTestStep stepToLogImpressionForAdUnit:@"a425ff78959911e295fa123138070049"]];
    [scenario addStep:[KIFTestStep stepToTapScreenAtPoint:CGPointMake(285, 60)]];
    [scenario addStep:[KIFTestStep stepToWaitForAbsenseOfViewWithClassName:@"CBNativeInterstitialView"]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Interstitial Show 2"]];
    [scenario addStep:[KIFTestStep stepToWaitForPresenceOfViewWithClassName:@"CBNativeInterstitialView"]];
    [scenario addStep:[KIFTestStep stepToLogImpressionForAdUnit:@"201597ec97e811e295fa123138070049"]];
    [scenario addStep:[KIFTestStep stepToTapScreenAtPoint:CGPointMake(285, 60)]];
    [scenario addStep:[KIFTestStep stepToWaitForAbsenseOfViewWithClassName:@"CBNativeInterstitialView"]];

    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];

    return scenario;
}

@end
