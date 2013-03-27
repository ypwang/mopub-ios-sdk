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
    [scenario addStep:[KIFTestStep stepToTapScreenAtPoint:CGPointMake(285, 60)]];
    [scenario addStep:[KIFTestStep stepToWaitForAbsenseOfViewWithClassName:@"CBNativeInterstitialView"]];

    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];

    return scenario;
}

@end
