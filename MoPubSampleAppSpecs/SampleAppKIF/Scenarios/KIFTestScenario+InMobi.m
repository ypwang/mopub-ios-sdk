//
//  KIFTestScenario+InMobi.m
//  MoPub
//
//  Copyright (c) 2013 MoPub. All rights reserved.
//

#import "KIFTestScenario+InMobi.h"

@implementation KIFTestScenario (InMobi)

+ (KIFTestScenario *)scenarioForInMobiInterstitial
{
    KIFTestScenario *scenario = [MPSampleAppTestScenario scenarioWithDescription:@"Test that an InMobi interstitial ad works."];
    NSIndexPath *indexPath = [MPAdSection indexPathForAd:@"InMobi Interstitial" inSection:@"Interstitial Ads"];
    [scenario addStep:[KIFTestStep stepToActuallyTapRowInTableViewWithAccessibilityLabel:@"Ad Table View"
                                                                             atIndexPath:indexPath]];

    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Load"]];
    [scenario addStep:[KIFTestStep stepToWaitUntilActivityIndicatorIsNotAnimating]];
    [scenario addStep:[KIFTestStep stepToTapViewWithAccessibilityLabel:@"Show"]];
    [scenario addStep:[KIFTestStep stepToWaitForPresenceOfViewWithClassName:@"UIWebView"]];
    [scenario addStep:[KIFTestStep stepToTapScreenAtPoint:CGPointMake(295, 25)]];
    [scenario addStep:[KIFTestStep stepToWaitForAbsenseOfViewWithClassName:@"UIWebView"]];

    [scenario addStep:[KIFTestStep stepToReturnToBannerAds]];

    return scenario;
}

@end
